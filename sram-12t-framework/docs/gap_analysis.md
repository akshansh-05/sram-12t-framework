# Gap Analysis: Four Representative 12T SRAM Families

This document provides the full seven-dimensional gap analysis across the four 12T SRAM design families evaluated in the paper.

## Overview

Twelve-transistor (12T) cells have emerged as a promising sweet-spot providing complete path decoupling, half-select immunity, and low-voltage operability. However, the existing 12T literature is fragmented across four distinct design philosophies, each with unresolved weaknesses.

---

## Seven Design Dimensions

The gap analysis evaluates each cell across these dimensions:

1. **Read Static Noise Margin (RSNM)** — stability of stored data during read access
2. **Write Margin (WM)** — minimum VDD or WL overdrive for a successful write
3. **Half-Select Immunity** — robustness of unaddressed cells during array writes (row and column)
4. **Leakage Power** — sub-threshold and gate-oxide leakage in hold mode
5. **Active Energy** — read and write energy per operation
6. **PVT / Monte-Carlo Robustness** — statistical yield across process-voltage-temperature variation
7. **Area Efficiency** — bit-cell footprint relative to 6T baseline

---

## Cell 1: DSPS-12T

**Reference:** R. Navajothi and A. K. Rahuman, *"Implementation of high performance 12T SRAM cell,"* Proc. IEEE ICEICE, Jan. 2017.

### Strengths

- **Virtual-VSS (VVSS):** Suppresses leakage during hold and half-select by pre-charging the virtual ground node to ~100 mV, introducing reverse body bias on pull-down transistors.
- **DSPS Write Assist:** Data-Dependent Stack PMOS Switching — P3/P4 transistors respond to the currently stored value, providing write boost without a separate external voltage rail.
- **Single-ended read decoupling:** Transistors N5/N6 isolate the storage latch from the bitline during read.
- **Full half-select immunity:** Both row and column half-select scenarios are addressed.

### Identified Weaknesses

| Weakness | Detail |
|---|---|
| No Monte Carlo analysis | RSNM/WM yield at elevated PVT corners is unknown |
| Qualitative half-select only | "QB will not find a discharge path" — no SNM butterfly curves or N-curve measurements |
| Narrow comparison baseline | Only 11T vs. 12T within the same design family; 8T, 9T, 10T baselines omitted |
| Voltage ambiguity | Reported 0.230–0.311 mW read/write power suggests 5 V supply (45 nm PTM default); direct comparison with sub-threshold cells at 0.35 V is inappropriate |

---

## Cell 2: SCM-12T

**Reference:** J. Sun and H. Jiao, *"A 12T low-power standard-cell based SRAM circuit for ultra-low-voltage operations,"* Proc. IEEE ISCAS, May 2019.

### Strengths

- **91.8% read energy reduction** via two-stage read-out (Sub-RBL + Global-RBL with tri-state buffer multiplexing)
- **45.6% write energy reduction** via column-shared gating transistors (PT/NT) that lower write-bitline capacitance
- **Standard-cell design intent** — avoids analog precharge circuits and custom sense amplifiers
- Implemented in **65 nm industrial CMOS**

### Identified Weaknesses

| Weakness | Detail |
|---|---|
| Non-minimum gating transistors | PT sized 5670/60 nm and NT sized 4050/60 nm (~70× minimum width), creating non-uniform row capacitance and complicating standard-cell characterisation |
| Write speed penalty | 28.7% longer write delay at VDD = 1.2 V due to additional NAND/NOR peripheral logic |
| Leakage overhead | +7.9% leakage at VDD = 300 mV due to minimum-length transistors throughout (no stacking) |
| Implicit half-select risk | Shared PT/NT across entire column means unselected rows share gate drive of a selected write; no half-select immunity analysis reported |

---

## Cell 3: SR-Latch-12T

**Reference:** Y.-W. Chou et al., *"SR-latch-based 12T SRAM cell design for low power application,"* Proc. IEEE ICECS, Nov. 2024.

### Strengths

- **Record leakage:** 0.161 nW at 350 mV — best among all 12T variants
- **Pre-discharge bitlines + stacked transmission transistors** for leakage and active energy reduction
- **Full half-select immunity** via separate WL and RWL signals
- **Sub-threshold operation at 350 mV** in 40 nm GP CMOS with RSNM = 89.2 mV

### Identified Weaknesses

| Weakness | Detail |
|---|---|
| Worst-case write margin | WM = 135.2 mV at SNFP corner — lowest among all compared 12T cells; DWA-12T achieves 216 mV on same node |
| NMOS-only pass transistors | M2/M3 suffer Vth elevation in SNFP corner while PMOS pull-up retains strength → write contention |
| Peripheral overhead not counted | VGND generator (two-input NOR + inverter per row) area not included in reported 2.308 µm² bit-cell area |
| No silicon measurement | 1-Kb chip is post-simulation only; PCA-12T (direct competitor) has silicon validation |

---

## Cell 4: SER-12T

**Reference:** G. Srinidhi et al., *"Unveiling the potential of 12T SRAM for enhanced performance and efficiency,"* Proc. IEEE ICAAIC, May 2024.

### Strengths

- Targets radiation hardening and biomedical applications
- Addresses soft-error rate (SER) through dual-node storage redundancy
- Demonstrates concept of 12T cell for 180 nm CMOS IoT/biomedical context

### Identified Weaknesses

| Weakness | Detail |
|---|---|
| Unsuitable technology node | At 180 nm, sub-threshold slope ≈ 80–90 mV/dec vs. ≈65 mV/dec at 40–65 nm; sub-threshold operation at VDD < 400 mV is impractical |
| Incorrect baseline | 10T predecessor cell fails to retain storage node values after read/write — suggests incorrect sizing or inconsistent simulation conditions, undermining improvement claims |
| No statistical analysis | No Monte Carlo, no process-corner sweep, no half-select analysis reported |
| Non-reproducible energy figures | 1.55×10⁻¹⁷ J quoted without specifying VDD, frequency, or word width |

---

## Summary Table

| Design Dimension | DSPS-12T | SCM-12T | SR-Latch-12T | SER-12T |
|---|---|---|---|---|
| Read Stability (RSNM) | Good (decoupled) | Excellent (= HSNM) | Good (89.2 mV @ 0.35 V) | Moderate (180 nm) |
| Write Margin (WM) | Good (DSPS assist) | Excellent | **Poor at SNFP corner** | Moderate |
| Row Half-Select | Full | **Partial** | Full | **Not analysed** |
| Column Half-Select | Full | **N/A** | Full | **Not analysed** |
| Leakage Power | Good (Virtual-VSS) | **+7.9% overhead** | **Best (0.161 nW)** | Moderate |
| Active Energy | Moderate | **Best (−91.8% read)** | Good | Moderate |
| PVT / Monte Carlo | **Not performed** | Limited | Limited (corners only) | **Not performed** |
| Area Efficiency | Moderate | Good (−22.9% vs Tri-buf) | Good (2.308 µm²) | **Not reported** |
| Technology Node | 45 nm PTM | 65 nm industrial | 40 nm GP | **180 nm** |

---

## Derived Design Requirements

The gap analysis directly motivates the five non-negotiable objectives for the proposed unified cell:

1. **Full half-select immunity** (gap in SCM-12T and SER-12T)
2. **Decoupled read path with RSNM = HSNM** (partially addressed by all four)
3. **DSPS write assist without extra supply rails** (gap in SR-Latch-12T and SER-12T)
4. **Stacked transistors for leakage suppression** (gap in SCM-12T)
5. **Standard-cell compatibility with Monte Carlo PVT validation** (gap in DSPS-12T, SR-Latch-12T, SER-12T)

---

*See [`cell_architecture.md`](cell_architecture.md) for how the proposed unified framework addresses each identified gap.*
