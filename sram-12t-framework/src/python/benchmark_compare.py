"""
benchmark_compare.py
====================
Generates the comprehensive benchmark chart (Table VI equivalent)
for the Unified 12T SRAM Framework paper.

Produces:
  - Bar charts for RSNM, WM, Leakage, Read Energy, Write Energy, Area
  - Radar/spider chart showing overall performance profile
  - CSV export of all benchmark data
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd
import os

# ── Benchmark Data (Table VI of paper) ────────────────────────
CELLS = ['6T', '8T', '10T', 'SR-12T', 'SCM-12T', 'DSPS-12T', 'Proposed']
COLORS = ['#aaaaaa', '#5b9bd5', '#ed7d31', '#70ad47', '#ffc000', '#7030a0', '#c00000']
HIGHLIGHT = 'Proposed'

DATA = {
    'Technology (nm)':   [45,   65,   90,   40,    65,    45,    45],
    'VDDmin (V)':        [0.80, 0.50, 0.40, 0.35,  0.30,  0.45,  0.30],
    'RSNM (mV)':         [150,  220,  180,  89.2,  390,   200,   96.1],
    'WM (mV)':           [220,  250,  175,  135.2, 650,   195,   175.1],
    'Leakage (nW)':      [0.16, 0.22, 0.38, 0.161, 0.18,  0.24,  0.163],
    'Read Energy (fJ)':  [145,  80,   62,   49.3,  14.2,  55,    38.2],
    'Write Energy (fJ)': [68,   55,   48,   49.3,  28.5,  52,    35.1],
    'Area (um2)':        [1.30, 1.63, 2.00, 2.308, 4.15,  3.5,   2.38],
}

BOOL_DATA = {
    'Row HS-free':       [False, False, 'Partial', True,  'Partial', True, True],
    'Col HS-free':       [False, True,  True,      True,  None,      True, True],
    'MC Analysis':       [True,  True,  True,      'Part',True,      False,True],
    'Std-Cell Compat.':  [False, False, False,     False, True,      False,True],
}

os.makedirs('results/figures', exist_ok=True)
os.makedirs('results/tables', exist_ok=True)


def bar_comparison(metric: str, ylabel: str = None,
                   lower_is_better: bool = False,
                   note: str = None):
    """Generate a bar chart comparing one metric across all cells."""
    values = DATA[metric]
    ylabel = ylabel or metric

    fig, ax = plt.subplots(figsize=(10, 5))

    bars = ax.bar(CELLS, values, color=COLORS, edgecolor='white', linewidth=0.8)

    # Highlight proposed cell
    for i, (bar, cell) in enumerate(zip(bars, CELLS)):
        if cell == HIGHLIGHT:
            bar.set_edgecolor('#333333')
            bar.set_linewidth(2.5)

    # Value labels
    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() * 1.02,
                f'{val}', ha='center', va='bottom', fontsize=9)

    ax.set_ylabel(ylabel, fontsize=12)
    ax.set_title(f'{metric} — State-of-the-Art Comparison', fontsize=13)
    ax.grid(axis='y', alpha=0.3)

    if note:
        ax.text(0.99, 0.97, note, transform=ax.transAxes,
                ha='right', va='top', fontsize=8, color='gray')

    direction = '↓ lower is better' if lower_is_better else '↑ higher is better'
    ax.text(0.01, 0.97, direction, transform=ax.transAxes,
            ha='left', va='top', fontsize=8, color='gray', style='italic')

    plt.tight_layout()
    safe_name = metric.replace('/', '_').replace(' ', '_').replace('(', '').replace(')', '')
    path = f'results/figures/bar_{safe_name}.png'
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"[CHART] Saved: {path}")


def radar_chart():
    """Spider/radar chart comparing normalised performance across metrics."""
    # Metrics to include (normalised 0–1, higher = better)
    metrics = ['RSNM', 'WM', 'Low\nLeakage', 'Low Read\nEnergy',
               'Low Write\nEnergy', 'Small\nArea', 'VDDmin\nLow']

    # Normalise (invert lower-is-better metrics)
    rsnm_n  = [v / max(DATA['RSNM (mV)'])          for v in DATA['RSNM (mV)']]
    wm_n    = [v / max(DATA['WM (mV)'])             for v in DATA['WM (mV)']]
    leak_n  = [1 - (v / max(DATA['Leakage (nW)']))  for v in DATA['Leakage (nW)']]
    re_n    = [1 - (v / max(DATA['Read Energy (fJ)'])) for v in DATA['Read Energy (fJ)']]
    we_n    = [1 - (v / max(DATA['Write Energy (fJ)'])) for v in DATA['Write Energy (fJ)']]
    area_n  = [1 - (v / max(DATA['Area (um2)']))    for v in DATA['Area (um2)']]
    vdd_n   = [1 - (v / max(DATA['VDDmin (V)']))    for v in DATA['VDDmin (V)']]

    norm_data = list(zip(rsnm_n, wm_n, leak_n, re_n, we_n, area_n, vdd_n))

    N = len(metrics)
    angles = np.linspace(0, 2 * np.pi, N, endpoint=False).tolist()
    angles += angles[:1]  # Close the polygon

    fig, ax = plt.subplots(figsize=(8, 8), subplot_kw=dict(polar=True))

    for i, (cell, vals, color) in enumerate(zip(CELLS, norm_data, COLORS)):
        v = list(vals) + [vals[0]]
        lw = 3 if cell == HIGHLIGHT else 1.5
        ax.plot(angles, v, color=color, linewidth=lw, label=cell)
        if cell == HIGHLIGHT:
            ax.fill(angles, v, color=color, alpha=0.15)

    ax.set_thetagrids(np.degrees(angles[:-1]), metrics, fontsize=10)
    ax.set_ylim(0, 1)
    ax.set_yticks([0.25, 0.5, 0.75, 1.0])
    ax.set_yticklabels(['0.25', '0.50', '0.75', '1.00'], fontsize=7)
    ax.set_title('Normalised Performance Radar\n(Higher = Better on Each Axis)',
                 fontsize=12, pad=20)
    ax.legend(loc='upper right', bbox_to_anchor=(1.35, 1.15), fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('results/figures/radar_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("[CHART] Saved: results/figures/radar_comparison.png")


def export_csv():
    """Export Table VI data to CSV."""
    df = pd.DataFrame(DATA, index=CELLS)
    for k, v in BOOL_DATA.items():
        df[k] = v
    df.index.name = 'Cell'
    path = 'results/tables/table6_benchmark.csv'
    df.to_csv(path)
    print(f"[CSV] Exported: {path}")
    return df


def main():
    print("=" * 55)
    print("  Unified 12T SRAM — Benchmark Chart Generator")
    print("=" * 55)

    # Individual metric bar charts
    bar_comparison('RSNM (mV)', 'RSNM (mV)', lower_is_better=False,
                   note='@VDD=0.35V, 40nm FS/SF corner')
    bar_comparison('WM (mV)', 'Write Margin (mV)', lower_is_better=False,
                   note='Worst-case SNFP corner')
    bar_comparison('Leakage (nW)', 'Leakage Power (nW)', lower_is_better=True,
                   note='@VDD=0.35V')
    bar_comparison('Read Energy (fJ)', 'Read Energy (fJ)', lower_is_better=True)
    bar_comparison('Write Energy (fJ)', 'Write Energy (fJ)', lower_is_better=True)
    bar_comparison('Area (um2)', 'Bit-Cell Area (µm²)', lower_is_better=True)

    # Radar chart
    radar_chart()

    # CSV export
    df = export_csv()
    print("\n[TABLE VI — Preview]")
    print(df[['RSNM (mV)', 'WM (mV)', 'Leakage (nW)',
              'Read Energy (fJ)', 'Write Energy (fJ)', 'Area (um2)']].to_string())


if __name__ == '__main__':
    main()
