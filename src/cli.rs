use std::env;
use std::path::Path;

use crate::bench::benchmark_queries;
use crate::eval::pool::{generate_pool, parse_specs};
use crate::eval::runner::generate_run_file;
use crate::eval::trec::convert_pool_to_qrels;
use crate::output::print_results;
use crate::query::{search_dataset, LoadMode, SearchOptions};
use crate::ranking::RankingModel;

pub fn run() {
    let args: Vec<String> = env::args().collect();
    match try_run(&args) {
        Ok(()) => {}
        Err(message) => {
            eprintln!("{message}");
            print_usage();
            std::process::exit(1);
        }
    }
}

fn try_run(args: &[String]) -> Result<(), String> {
    let Some(command) = args.get(1).map(String::as_str) else {
        return Err(String::from("missing command"));
    };

    match command {
        "search" => run_search(args),
        "run" => run_batch(args),
        "bench" => run_benchmark(args),
        "pool" => run_pool(args),
        "qrels" => run_qrels(args),
        _ => Err(format!("unknown command: {command}")),
    }
}

fn run_search(args: &[String]) -> Result<(), String> {
    if args.len() < 4 {
        return Err(String::from("missing command or arguments"));
    }

    let dataset_dir = Path::new(&args[2]);
    let query = &args[3];
    let options = parse_common_search_flags(&args[4..])?;

    let results = search_dataset(&SearchOptions {
        dataset_dir,
        query,
        mode: options.mode,
        ranking_model: options.ranking_model,
        top_k: options.top_k,
        chunk_size: options.chunk_size,
    })
    .map_err(|error| format!("search failed: {error}"))?;

    print_results(query, &results);
    Ok(())
}

fn run_batch(args: &[String]) -> Result<(), String> {
    if args.len() < 5 {
        return Err(String::from("missing dataset, queries, or output path"));
    }

    let dataset_dir = Path::new(&args[2]);
    let queries_path = Path::new(&args[3]);
    let options = parse_common_search_flags(&args[4..])?;
    let mut out_path = None;
    let mut run_name = String::from("seekdown_run");

    let mut index = 4;
    while index < args.len() {
        match args[index].as_str() {
            "--out" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --out"))?;
                out_path = Some(Path::new(value));
            }
            "--name" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --name"))?;
                run_name = value.clone();
            }
            "--mode" | "--model" | "--top-k" | "--chunk-size" => {
                index += 1;
            }
            flag => return Err(format!("unknown flag: {flag}")),
        }
        index += 1;
    }

    let out_path = out_path.ok_or_else(|| String::from("missing --out path"))?;
    let rows = generate_run_file(
        dataset_dir,
        queries_path,
        out_path,
        options.mode,
        options.ranking_model,
        options.top_k,
        options.chunk_size,
        &run_name,
    )
    .map_err(|error| format!("run generation failed: {error}"))?;

    println!("wrote {rows} run rows to {}", out_path.display());
    Ok(())
}

fn run_benchmark(args: &[String]) -> Result<(), String> {
    if args.len() < 4 {
        return Err(String::from("missing dataset or queries path"));
    }

    let dataset_dir = Path::new(&args[2]);
    let queries_path = Path::new(&args[3]);
    let options = parse_common_search_flags(&args[4..])?;
    let mut repeat = 100_usize;

    let mut index = 4;
    while index < args.len() {
        match args[index].as_str() {
            "--repeat" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --repeat"))?;
                repeat = value.parse().map_err(|_| format!("invalid repeat: {value}"))?;
            }
            "--mode" | "--model" | "--top-k" | "--chunk-size" => {
                index += 1;
            }
            flag => return Err(format!("unknown flag: {flag}")),
        }
        index += 1;
    }

    let summary = benchmark_queries(
        dataset_dir,
        queries_path,
        options.mode,
        options.ranking_model,
        options.top_k,
        options.chunk_size,
        repeat,
    )
    .map_err(|error| format!("benchmark failed: {error}"))?;

    println!(
        "documents={} queries={} repeat={} total={} build={:.4}ms",
        summary.documents, summary.queries, summary.repeat, summary.total_runs, summary.build_ms
    );
    println!(
        "mean={:.4}ms median={:.4}ms p95={:.4}ms qps={:.2}",
        summary.mean_ms, summary.median_ms, summary.p95_ms, summary.qps
    );
    Ok(())
}

fn run_pool(args: &[String]) -> Result<(), String> {
    if args.len() < 4 {
        return Err(String::from("missing dataset or queries path"));
    }

    let dataset_dir = Path::new(&args[2]);
    let queries_path = Path::new(&args[3]);
    let mut modes = String::from("section,chunk");
    let mut models = String::from("boolean,tfidf,bm25,bm25plus,pivoted");
    let mut top_k = 10_usize;
    let mut chunk_size = 120_usize;
    let mut out_path = None;

    let mut index = 4;
    while index < args.len() {
        match args[index].as_str() {
            "--modes" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --modes"))?;
                modes = value.clone();
            }
            "--models" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --models"))?;
                models = value.clone();
            }
            "--top-k" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --top-k"))?;
                top_k = value.parse().map_err(|_| format!("invalid top-k: {value}"))?;
            }
            "--chunk-size" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --chunk-size"))?;
                chunk_size = value.parse().map_err(|_| format!("invalid chunk-size: {value}"))?;
            }
            "--out" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --out"))?;
                out_path = Some(Path::new(value));
            }
            flag => return Err(format!("unknown flag: {flag}")),
        }
        index += 1;
    }

    let out_path = out_path.ok_or_else(|| String::from("missing --out path"))?;
    let specs = parse_specs(&modes, &models)?;
    let rows = generate_pool(dataset_dir, queries_path, out_path, &specs, top_k, chunk_size)
        .map_err(|error| format!("pool generation failed: {error}"))?;

    println!("wrote {rows} pooled rows to {}", out_path.display());
    Ok(())
}

fn run_qrels(args: &[String]) -> Result<(), String> {
    if args.len() < 3 {
        return Err(String::from("missing annotated pool path"));
    }

    let pool_path = Path::new(&args[2]);
    let mut out_path = None;
    let mut index = 3;

    while index < args.len() {
        match args[index].as_str() {
            "--out" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --out"))?;
                out_path = Some(Path::new(value));
            }
            flag => return Err(format!("unknown flag: {flag}")),
        }
        index += 1;
    }

    let out_path = out_path.ok_or_else(|| String::from("missing --out path"))?;
    let rows = convert_pool_to_qrels(pool_path, out_path)
        .map_err(|error| format!("qrels conversion failed: {error}"))?;

    println!("wrote {rows} qrels rows to {}", out_path.display());
    Ok(())
}

#[derive(Debug, Clone, Copy)]
struct CommonSearchFlags {
    mode: LoadMode,
    ranking_model: RankingModel,
    top_k: usize,
    chunk_size: usize,
}

fn parse_common_search_flags(args: &[String]) -> Result<CommonSearchFlags, String> {
    let mut mode = LoadMode::Section;
    let mut ranking_model = RankingModel::Boolean;
    let mut top_k = 5_usize;
    let mut chunk_size = 120_usize;

    let mut index = 0;
    while index < args.len() {
        match args[index].as_str() {
            "--mode" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --mode"))?;
                mode = LoadMode::parse(value).ok_or_else(|| format!("invalid mode: {value}"))?;
            }
            "--model" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --model"))?;
                ranking_model = RankingModel::parse(value)
                    .ok_or_else(|| format!("invalid model: {value}"))?;
            }
            "--top-k" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --top-k"))?;
                top_k = value.parse().map_err(|_| format!("invalid top-k: {value}"))?;
            }
            "--chunk-size" => {
                index += 1;
                let value = args.get(index).ok_or_else(|| String::from("missing value for --chunk-size"))?;
                chunk_size = value.parse().map_err(|_| format!("invalid chunk-size: {value}"))?;
            }
            "--out" | "--name" | "--repeat" => {
                index += 1;
            }
            flag => return Err(format!("unknown flag: {flag}")),
        }
        index += 1;
    }

    Ok(CommonSearchFlags {
        mode,
        ranking_model,
        top_k,
        chunk_size,
    })
}

fn print_usage() {
    eprintln!("usage:");
    eprintln!("  seekdown search <dataset_dir> <query> [--mode section|chunk] [--model boolean|tfidf|bm25|bm25plus|pivoted] [--top-k N] [--chunk-size N]");
    eprintln!("  seekdown run <dataset_dir> <queries.csv> --out <run.txt> [--name run_name] [--mode section|chunk] [--model boolean|tfidf|bm25|bm25plus|pivoted] [--top-k N] [--chunk-size N]");
    eprintln!("  seekdown bench <dataset_dir> <queries.csv> [--repeat N] [--mode section|chunk] [--model boolean|tfidf|bm25|bm25plus|pivoted] [--top-k N] [--chunk-size N]");
    eprintln!("  seekdown pool <dataset_dir> <queries.csv> --out <pool.csv> [--modes section,chunk] [--models boolean,tfidf,bm25,bm25plus,pivoted] [--top-k N] [--chunk-size N]");
    eprintln!("  seekdown qrels <annotated_pool.csv> --out <qrels.txt>");
}
