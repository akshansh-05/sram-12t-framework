# Unified 12T SRAM Design Framework

> A Comparative Analysis and Unified Design Framework for High-Performance Low-Power 12T SRAM Cells: Addressing Half-Select Immunity, Sub-Threshold Stability, and Energy Efficiency in Nanoscale CMOS

[![IEEE TVLSI](https://img.shields.io/badge/Submitted-IEEE%20TVLSI-blue)](#)
[![Technology](https://img.shields.io/badge/Technology-40nm%20%7C%2045nm%20%7C%2065nm-green)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Key Results](#key-results)
- [Repository Structure](#repository-structure)
- [Cell Architecture](#cell-architecture)
- [Design Objectives](#design-objectives)
- [Gap Analysis Summary](#gap-analysis-summary)
- [Simulation Setup](#simulation-setup)
- [Benchmark Results](#benchmark-results)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Citation](#citation)

---

## Overview

Static Random-Access Memory (SRAM) cells occupy **70–80% of active die area** in modern SoC processors. As supply voltages scale toward the sub-threshold regime (VDD < 0.5 V), the conventional 6T cell fails due to:

1. **Read/Write stability conflict** — shared bitline degrades RSNM
2. **Half-select disturb** — unaddressed cells are disturbed during array-level operations
3. **Leakage dominance** — ION/IOFF ratio collapses at low VDD

This project presents:
- A **systematic gap analysis** of four representative 12T SRAM families (DSPS-12T, SCM-12T, SR-Latch-12T, SER-12T)
- A **unified 12T SRAM cell** that resolves all identified weaknesses simultaneously
- Simulation results in **HSPICE** using 40 nm / 45 nm / 65 nm PTM technology models

---

## Key Results

| Metric | Proposed Unified 12T | Best Prior Work |
|---|---|---|
| RSNM @ 0.35 V | **96.1 mV** | 89.2 mV (SR-Latch-12T) |
| WM @ SNFP corner | **175.1 mV** | 135.2 mV (SR-Latch-12T) |
| Leakage @ 0.35 V | **0.163 nW** | 0.161 nW (SR-Latch-12T) |
| Read Energy | **38.2 fJ** | 14.2 fJ (SCM-12T) |
| Write Energy | **35.1 fJ** | 28.5 fJ (SCM-12T) |
| Area | **2.38 µm²** | 2.308 µm² (SR-Latch-12T) |
| Row Half-Select Free | **Yes** | Partial |
| Column Half-Select Free | **Yes** | Yes |
| Monte Carlo Validated | **Yes (1000-pt)** | Partial |
| Std-Cell Compatible | **Yes** | No |

> The proposed cell is the **only design** in the comparison set to satisfy all five requirements simultaneously.

---

## Repository Structure

```
sram-12t-framework/
│
├── README.md                        # This file
├── LICENSE
│
├── docs/
│   ├── gap_analysis.md              # Seven-dimensional gap analysis
│   ├── cell_architecture.md         # Transistor-level design description
│   ├── operating_modes.md           # Hold / Read / Write / Half-select analysis
│   ├── circuit_analysis.md          # RSNM, WM, leakage, power-delay derivations
│   └── references.md                # Full bibliography
│
├── src/
│   ├── spice/
│   │   ├── unified_12T_cell.sp      # Main HSPICE netlist
│   │   ├── tb_read.sp               # Read mode testbench
│   │   ├── tb_write.sp              # Write mode testbench
│   │   ├── tb_half_select_row.sp    # Row half-select testbench
│   │   ├── tb_half_select_col.sp    # Column half-select testbench
│   │   └── tb_montecarlo.sp         # 1000-point Monte Carlo testbench
│   │
│   ├── verilog/
│   │   ├── sram_array.v             # Behavioural SRAM array model
│   │   ├── row_decoder.v            # WWLA / WWLB row decoder
│   │   └── sense_amplifier.v        # Digital sense amplifier (std-cell based)
│   │
│   └── python/
│       ├── snm_analysis.py          # SNM butterfly curve plotter
│       ├── monte_carlo_plot.py      # Monte Carlo distribution visualiser
│       ├── benchmark_compare.py     # Table VI benchmark chart generator
│       └── energy_model.py          # Analytical energy model (Eq. 4)
│
├── results/
│   ├── tables/
│   │   ├── table1_gap_analysis.csv
│   │   ├── table3_snm_wm.csv
│   │   ├── table4_power.csv
│   │   ├── table5_half_select.csv
│   │   └── table6_benchmark.csv
│   │
│   └── figures/
│       ├── snm_butterfly_tt.png     # Butterfly curve @ TT corner
│       ├── monte_carlo_rsnm.png     # MC RSNM distribution
│       └── wm_corner_sweep.png      # WM across process corners
│
├── scripts/
│   ├── run_all_sims.sh              # Master simulation runner
│   ├── extract_metrics.py           # Post-process HSPICE .lis output
│   └── setup_ptm.sh                 # Download and configure PTM models
│
└── tests/
    ├── test_hold_mode.sp
    ├── test_read_disturb.sp
    └── test_write_assist.sp
```

---

## Cell Architecture

The proposed cell contains **12 transistors** across four functional groups:

| Device(s) | Type | Function | Active Mode |
|---|---|---|---|
| P1, P2 | PMOS (HVT) | Latch pull-up | All |
| N1, N2 | NMOS (HVT) | Latch pull-down | All |
| P3, P4 | PMOS (RVT) | DSPS write assist | Write |
| N3, N4 | NMOS (RVT) | Write access | Write |
| N5, N6 | NMOS (RVT) | Read path (RBL) | Read |
| N7, N8 | NMOS (RVT) | Read path (RBLB) | Read |

### Signal Ports

```
VDD, GND        — Power rails
WWLA, WWLB     — Asymmetric write word-lines (row-based)
RWL             — Read word-line
BL              — Write bitline
RBL, RBLB      — Differential read bitlines
VVSS            — Virtual-VSS (leakage suppression, ≈100 mV in hold)
```

---

## Design Objectives

The five non-negotiable design objectives derived from the gap analysis:

1. **Full half-select immunity** under both row (WWL-based) and column (BL-based) partial activation
2. **Decoupled read path** so that RSNM = HSNM by construction
3. **Write assist without extra supply rails** via Data-Dependent Stack PMOS Switching (DSPS)
4. **Stacked transistors** for leakage suppression in hold mode (no Tri-buf area penalty)
5. **Standard-cell compatibility** — all signal ports are digital; no analog precharge or custom sense amplifier required

---

## Gap Analysis Summary

| Design Dimension | DSPS-12T | SCM-12T | SR-Latch-12T | SER-12T | **Proposed** |
|---|---|---|---|---|---|
| Read Stability (RSNM) | Good | Excellent | Good (89.2 mV) | Moderate | **96.1 mV** |
| Write Margin | Good | Excellent | Poor (SNFP) | Moderate | **175.1 mV** |
| Row Half-Select | Full | Partial | Full | Not analysed | **Full** |
| Column Half-Select | Full | N/A | Full | Not analysed | **Full** |
| Leakage | Good | +7.9% overhead | Best (0.161 nW) | Moderate | **0.163 nW** |
| Monte Carlo PVT | ❌ None | Partial | Limited | ❌ None | **✅ 1000-pt** |
| Std-Cell Compatible | ❌ | ❌ | ❌ | ❌ | **✅** |
| Technology | 45 nm | 65 nm | 40 nm | 180 nm | **40/45/65 nm** |

See [`docs/gap_analysis.md`](docs/gap_analysis.md) for the full seven-dimensional analysis.

---

## Simulation Setup

- **Simulator:** HSPICE
- **Technology:** 45 nm and 65 nm Predictive Technology Model (PTM) — [http://ptm.asu.edu](http://ptm.asu.edu)
- **Array size:** 4 Kib (128 rows × 32 columns)
- **Supply voltages evaluated:** 0.3 V, 0.5 V, 1.0 V
- **Temperature range:** −40°C, 27°C, 125°C
- **Process corners:** TT, FF, SS, FS (Fast-N Slow-P), SF (Slow-N Fast-P)
- **Monte Carlo:** 1000-point runs at TT, FS, SF corners at VDD ∈ {0.3, 0.5, 1.0} V

---

## Benchmark Results

The comprehensive benchmark (Table VI of the paper) against 6T, 8T, 10T, SR-12T, SCM-12T, and DSPS-12T:

| Parameter | 6T | 8T | 10T | SR-12T | SCM-12T | DSPS-12T | **Proposed** |
|---|---|---|---|---|---|---|---|
| Technology | 45 nm | 65 nm | 90 nm | 40 nm | 65 nm | 45 nm | **45/65 nm** |
| VDDmin (V) | 0.80 | 0.50 | 0.40 | 0.35 | 0.30 | 0.45 | **0.30** |
| RSNM (mV) | ~150 | 220 | 180 | 89.2 | 390 | ~200 | **96.1** |
| WM (mV) | 220 | 250 | 175 | 135.2 | 650 | 195 | **175.1** |
| Leakage (nW) | 0.16 | 0.22 | 0.38 | 0.161 | 0.18 | 0.24 | **0.163** |
| Read Energy (fJ) | 145 | 80 | 62 | 49.3 | 14.2 | 55 | **38.2** |
| Write Energy (fJ) | 68 | 55 | 48 | 49.3 | 28.5 | 52 | **35.1** |
| Area (µm²) | 1.30 | 1.63 | 2.00 | 2.308 | 4.15 | ~3.5 | **2.38** |
| Row HS-free | No | No | Partial | Yes | Partial | Yes | **Yes** |
| Col HS-free | No | Yes | Yes | Yes | N/A | Yes | **Yes** |
| MC Analysis | Yes | Yes | Yes | Partial | Yes | No | **Yes** |
| Std-Cell Compat. | No | No | No | No | Yes | No | **Yes** |

---

## Getting Started

### Prerequisites

- HSPICE (or compatible SPICE simulator — Ngspice instructions in [`docs/`](docs/))
- Python 3.9+ with `numpy`, `matplotlib`, `pandas`
- PTM model files (auto-downloaded by setup script)

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-org/sram-12t-framework.git
cd sram-12t-framework

# 2. Download PTM model files
bash scripts/setup_ptm.sh

# 3. Install Python dependencies
pip install -r requirements.txt

# 4. Run all SPICE simulations
bash scripts/run_all_sims.sh

# 5. Extract and plot metrics
python scripts/extract_metrics.py --all
python src/python/benchmark_compare.py
```

### Running Individual Testbenches

```bash
# Read mode SNM
hspice src/spice/tb_read.sp -o results/read_sim

# Write mode with DSPS assist
hspice src/spice/tb_write.sp -o results/write_sim

# Half-select immunity (10,000-operation stress test)
hspice src/spice/tb_half_select_row.sp -o results/hs_row
hspice src/spice/tb_half_select_col.sp -o results/hs_col

# 1000-point Monte Carlo
hspice src/spice/tb_montecarlo.sp -o results/mc_sim
```

---

## Documentation

| Document | Description |
|---|---|
| [`docs/gap_analysis.md`](docs/gap_analysis.md) | Full seven-dimensional gap analysis of DSPS, SCM, SR-Latch, and SER 12T cells |
| [`docs/cell_architecture.md`](docs/cell_architecture.md) | Transistor-level description with operating modes |
| [`docs/operating_modes.md`](docs/operating_modes.md) | Hold, Read, Write, Row HS, Column HS mode derivations |
| [`docs/circuit_analysis.md`](docs/circuit_analysis.md) | RSNM, WM, leakage, and power-delay product equations |
| [`docs/references.md`](docs/references.md) | Complete bibliography (22 references) |

---

## Application Domains

The proposed cell is well-suited for:

- **Ultra-low-power IoT / wearable sensors** — VDDmin = 0.35 V, leakage = 0.163 nW
- **Biomedical implants** — RSNM > 90 mV, full half-select immunity for reliable data retention
- **Radiation-tolerant aerospace memory** — decoupled topology, HVT latch, no shared read/write paths
- **Near-threshold AI inference engines** — standard-cell compatibility for neural network weight storage

---

## Future Work

- [ ] Extend to FinFET technology nodes (7 nm–16 nm)
- [ ] Single-WWL variant using SR-Latch concept to reduce decoder complexity
- [ ] Silicon measurement via 40 nm TSMC GP tapeout
- [ ] Single-event upset (SEU) hardening for space applications

---

## Citation

If you use this work, please cite:

```bibtex
@article{unified12T2026,
  title   = {A Comparative Analysis and Unified Design Framework for High-Performance
             Low-Power 12T SRAM Cells: Addressing Half-Select Immunity,
             Sub-Threshold Stability, and Energy Efficiency in Nanoscale CMOS},
  author  = {[Author Names Withheld for Review]},
  journal = {IEEE Transactions on Very Large Scale Integration (VLSI) Systems},
  year    = {2026},
  note    = {Manuscript received May 16, 2026}
}
```

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
