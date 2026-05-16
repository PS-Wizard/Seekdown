#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

ROOT = Path(__file__).resolve().parent.parent
EVAL_CSV = ROOT / 'experiments/results/eval/full_corpus_metrics.csv'
BENCH_CSV = ROOT / 'experiments/results/benchmarks/benchmark_matrix.csv'
OUT = ROOT / 'experiments/visualizations'
PNG = OUT / 'png'
SVG = OUT / 'svg'
DATA = OUT / 'data'

CORPUS_ORDER = ['subset_2500', 'subset_5000', 'subset_7500', 'subset_10000', 'full']
FAMILY_ORDER = ['section', 'chunk80', 'chunk120', 'chunk200']
MODEL_ORDER = ['boolean', 'tfidf', 'bm25', 'bm25plus', 'pivoted']
CORPUS_TICK_LABELS = ['2.5k', '5k', '7.5k', '10k', 'full']

plt.style.use('seaborn-v0_8-whitegrid')
plt.rcParams.update({
    'figure.dpi': 150,
    'savefig.dpi': 220,
    'font.family': 'DejaVu Sans',
    'font.size': 10,
    'axes.titlesize': 12,
    'axes.labelsize': 11,
    'xtick.labelsize': 9,
    'ytick.labelsize': 9,
    'legend.fontsize': 9,
    'legend.title_fontsize': 9,
})


def reset_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)
    for child in path.iterdir():
        if child.is_file():
            child.unlink()


def ensure_dirs() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for path in (PNG, SVG, DATA):
        reset_dir(path)


def save(fig: plt.Figure, name: str) -> None:
    fig.savefig(PNG / f'{name}.png', bbox_inches='tight')
    fig.savefig(SVG / f'{name}.svg', bbox_inches='tight')
    plt.close(fig)


def family_from(row: pd.Series) -> str:
    if row['mode'] == 'section':
        return 'section'
    return f"chunk{int(row['chunk_size'])}"


def family_label(family: str) -> str:
    return 'section' if family == 'section' else family.replace('chunk', 'chunk ')


def model_label(model: str) -> str:
    return {
        'boolean': 'boolean',
        'tfidf': 'tf-idf',
        'bm25': 'bm25',
        'bm25plus': 'bm25+',
        'pivoted': 'pivoted',
    }[model]


def system_label(family: str, model: str) -> str:
    return f'{family_label(family)} · {model_label(model)}'


def short_system_label(system_id: str) -> str:
    mode, model = system_id.split('_', 1)
    model_short = {
        'boolean': 'bool',
        'tfidf': 'tfidf',
        'bm25': 'bm25',
        'bm25plus': 'bm25+',
        'pivoted': 'pivot',
    }[model]
    prefix = 'sec' if mode == 'section' else mode.replace('chunk', 'c')
    return f'{prefix}-{model_short}'


def load_data() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    eval_df = pd.read_csv(EVAL_CSV)
    bench_df = pd.read_csv(BENCH_CSV)

    eval_df['chunk_size'] = pd.to_numeric(eval_df['chunk_size'], errors='coerce')
    bench_df['chunk_size'] = pd.to_numeric(bench_df['chunk_size'], errors='coerce')

    for col in ['map', 'mrr', 'p10', 'ndcg10', 'recall10']:
        eval_df[col] = pd.to_numeric(eval_df[col], errors='coerce')
    for col in ['documents', 'queries', 'repeat', 'total_runs', 'build_ms', 'mean_ms', 'median_ms', 'p95_ms', 'qps', 'wall_ms']:
        bench_df[col] = pd.to_numeric(bench_df[col], errors='coerce')

    eval_df['family'] = eval_df.apply(family_from, axis=1)
    bench_df['family'] = bench_df.apply(family_from, axis=1)
    bench_df['corpus_id'] = pd.Categorical(bench_df['corpus_id'], categories=CORPUS_ORDER, ordered=True)

    full_bench = bench_df[bench_df['corpus_id'] == 'full'].copy()
    full_df = eval_df.merge(
        full_bench[['system_id', 'build_ms', 'median_ms', 'p95_ms', 'qps']],
        on='system_id',
        how='left',
    )
    full_df['display_label'] = full_df.apply(lambda row: system_label(row['family'], row['model']), axis=1)
    full_df['short_label'] = full_df['system_id'].map(short_system_label)

    eval_df.to_csv(DATA / 'eval_metrics.csv', index=False)
    bench_df.to_csv(DATA / 'benchmark_matrix.csv', index=False)
    full_df.to_csv(DATA / 'full_corpus_merged_metrics.csv', index=False)
    return eval_df, bench_df, full_df


def plot_effectiveness_matrix(eval_df: pd.DataFrame) -> None:
    matrix = eval_df.pivot(index='model', columns='family', values='ndcg10').loc[MODEL_ORDER, FAMILY_ORDER]

    fig, ax = plt.subplots(figsize=(7.2, 5.0))
    sns.heatmap(matrix, cmap='Blues', annot=True, fmt='.3f', linewidths=0.8, cbar=True, ax=ax)
    ax.set_xlabel('')
    ax.set_ylabel('')
    ax.set_xticklabels([family_label(family) for family in FAMILY_ORDER], rotation=0)
    ax.set_yticklabels([model_label(model) for model in MODEL_ORDER], rotation=0)
    save(fig, 'effectiveness_matrix_ndcg')


def plot_effectiveness_ranked(full_df: pd.DataFrame) -> None:
    ordered = full_df.sort_values(['ndcg10', 'map', 'mrr'], ascending=False)

    fig, ax = plt.subplots(figsize=(9.2, 7.6))
    sns.barplot(data=ordered, x='ndcg10', y='short_label', hue='family', dodge=False, ax=ax)
    ax.set_xlabel('nDCG@10')
    ax.set_ylabel('')
    ax.legend(title='segmentation', loc='lower right', frameon=True)
    save(fig, 'effectiveness_ranked_ndcg')


def plot_corpus_size_speed_chart(bench_df: pd.DataFrame, metric: str, ylabel: str, name: str) -> None:
    fig, ax = plt.subplots(figsize=(10.4, 6.2))

    for system_id, group in bench_df.groupby('system_id', sort=False):
        group = group.sort_values('corpus_id')
        ax.plot(CORPUS_TICK_LABELS, group[metric], marker='o', linewidth=1.6, alpha=0.9, label=short_system_label(system_id))

    ax.set_xlabel('Corpus size')
    ax.set_ylabel(ylabel)
    ax.legend(title='system', bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0.0, ncol=1, frameon=True)
    save(fig, name)


def compute_pareto(full_df: pd.DataFrame) -> pd.DataFrame:
    df = full_df[['system_id', 'family', 'model', 'ndcg10', 'median_ms', 'short_label']].copy()
    frontier_flags = []
    for _, row in df.iterrows():
        dominated = False
        for _, other in df.iterrows():
            if other['system_id'] == row['system_id']:
                continue
            if other['median_ms'] <= row['median_ms'] and other['ndcg10'] >= row['ndcg10'] and (
                other['median_ms'] < row['median_ms'] or other['ndcg10'] > row['ndcg10']
            ):
                dominated = True
                break
        frontier_flags.append(not dominated)
    df['pareto'] = frontier_flags
    return df


def plot_pareto(full_df: pd.DataFrame) -> None:
    df = compute_pareto(full_df)

    fig, ax = plt.subplots(figsize=(8.8, 6.2))
    sns.scatterplot(data=df, x='median_ms', y='ndcg10', hue='family', style='model', s=90, ax=ax)

    frontier = df[df['pareto']].sort_values('median_ms')
    ax.plot(frontier['median_ms'], frontier['ndcg10'], linestyle='--', linewidth=1.5, color='black')

    for row in frontier.itertuples(index=False):
        ax.annotate(row.short_label, (row.median_ms, row.ndcg10), textcoords='offset points', xytext=(6, 4), fontsize=8)

    ax.set_xlabel('Median latency on full corpus (ms)')
    ax.set_ylabel('nDCG@10')
    ax.legend(bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0.0, frameon=True)
    save(fig, 'pareto_frontier_quality_speed')


def plot_radar_top_systems(full_df: pd.DataFrame) -> None:
    metrics = ['map', 'mrr', 'ndcg10', 'p10', 'recall10', 'qps']
    labels = ['MAP', 'MRR', 'nDCG@10', 'P@10', 'Recall@10', 'QPS']
    top = full_df.sort_values('ndcg10', ascending=False).head(5).copy()
    norm = top[['short_label'] + metrics].copy()

    for metric in metrics:
        min_v = full_df[metric].min()
        max_v = full_df[metric].max()
        norm[metric] = 0.0 if max_v == min_v else (norm[metric] - min_v) / (max_v - min_v)

    angles = np.linspace(0, 2 * np.pi, len(metrics), endpoint=False).tolist()
    angles += angles[:1]

    fig, ax = plt.subplots(figsize=(8.6, 8.6), subplot_kw={'polar': True})
    for row in norm.itertuples(index=False):
        values = [getattr(row, metric) for metric in metrics]
        values += values[:1]
        ax.plot(angles, values, linewidth=1.8, label=row.short_label)
        ax.fill(angles, values, alpha=0.08)

    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(labels)
    ax.set_yticklabels([])
    ax.legend(loc='upper left', bbox_to_anchor=(1.05, 1.02), frameon=True)
    save(fig, 'radar_chart_top_systems')


def write_readme() -> None:
    text = """# Visualizations

Standard Matplotlib figure pack generated from:
- `experiments/results/eval/full_corpus_metrics.csv`
- `experiments/results/benchmarks/benchmark_matrix.csv`

Outputs:
- `png/` quick review
- `svg/` paper-ready vector files
- `data/` plotting tables

Figures:
1. `effectiveness_matrix_ndcg`
2. `effectiveness_ranked_ndcg`
3. `corpus_size_vs_median_latency`
4. `corpus_size_vs_qps`
5. `corpus_size_vs_p95_latency`
6. `corpus_size_vs_build_time`
7. `pareto_frontier_quality_speed`
8. `radar_chart_top_systems`
"""
    (OUT / 'README.md').write_text(text)


def main() -> None:
    ensure_dirs()
    eval_df, bench_df, full_df = load_data()
    plot_effectiveness_matrix(eval_df)
    plot_effectiveness_ranked(full_df)
    plot_corpus_size_speed_chart(bench_df, 'median_ms', 'Median latency (ms)', 'corpus_size_vs_median_latency')
    plot_corpus_size_speed_chart(bench_df, 'qps', 'Queries per second', 'corpus_size_vs_qps')
    plot_corpus_size_speed_chart(bench_df, 'p95_ms', 'P95 latency (ms)', 'corpus_size_vs_p95_latency')
    plot_corpus_size_speed_chart(bench_df, 'build_ms', 'Build time (ms)', 'corpus_size_vs_build_time')
    plot_pareto(full_df)
    plot_radar_top_systems(full_df)
    write_readme()


if __name__ == '__main__':
    main()
