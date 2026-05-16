# Circuit Analysis: RSNM, Write Margin, Leakage, and Power-Delay

This document provides the mathematical derivations and simulation correlations for the key circuit metrics of the proposed unified 12T SRAM cell.

---

## 1. Read Static Noise Margin (RSNM)

### Definition

Static Noise Margin (SNM) quantifies the maximum symmetric DC noise voltage that a cross-coupled inverter pair can tolerate without data loss [Seevinck et al., 1987].

- **Hold SNM (HSNM):** Evaluated with access transistors OFF (isolated latch)
- **Read SNM (RSNM):** Conventionally evaluated with access transistors ON (6T cell degrades during read)

### Key Result: RSNM = HSNM

For the proposed cell, since the storage nodes Q and Q̄ **only drive the gates** of read transistors N5 and N7 (no current flows through the latch during read), the latch voltage transfer curves are completely undisturbed during read access.

**Therefore:** RSNM = HSNM by construction — a topological guarantee, not a sizing choice.

### HSNM Computation

Using the α-power law transistor model:

```
HSNM = f( (W/L)_P / (W/L)_N,  Vth_P / Vth_N,  VDD )
```

For symmetric sizing ((W/L)_P = (W/L)_N = 1) with HVT latch transistors (|Vth| ≈ 480 mV at 45 nm PTM):

| VDD | Simulated HSNM | Reference (SCM-12T) | Error |
|---|---|---|---|
| 1.0 V | 392 mV | 390 mV | <1% |
| 0.5 V | 181 mV | — | — |
| 0.35 V | 96.1 mV | 89.2 mV (SR-12T) | +7.8% |

### Comparison at VDD = 0.35 V, 40 nm Corner

| Cell | RSNM (mV) | Process Corner |
|---|---|---|
| 6T | N/A (unstable) | TT |
| 8T (RD) | 64.4 | FS |
| FD-10T | 65.6 | FS/SF |
| DFL-10T | 21.6 | FS/SF |
| PCA-12T | 92.9 | FS/SF |
| DWA-12T | 72.2 | FS/SF |
| SR-Latch-12T | 89.2 | FS/SF |
| **Proposed Unified 12T** | **96.1** | FS/SF |

---

## 2. Write Margin (WM)

### Definition

Write Margin is the minimum word-line overdrive ΔV_WL = V_WL − Vth_N3 required to change the stored value.

Equivalently: the range of VDD over which the cell can still be written (write-ability margin).

In the sub-threshold regime:
```
I_DS ∝ exp(V_GS / n·V_T)
```
Small Vth variations create orders-of-magnitude current imbalances that severely degrade WM [Carlson, 2008].

### DSPS-Assisted Write Margin

The total write margin with DSPS assist is:
```
WM_DSPS = WM_base + ΔV_assist
```

where ΔV_assist is the DSPS-induced voltage boost on Q̄ during a write-"0" to Q.

**ΔV_assist is maximised when:** |V_GS,P3| > |Vth_P3|
i.e., when Q drops below VDD − |Vth_P|

At VDD = 350 mV, 40 nm nominal:
- |Vth_P| ≈ 300 mV
- P3 activates at Q ≈ 50 mV
- **ΔV_assist ≈ 80 mV**

### SNFP Corner Analysis

The Slow-N Fast-P (SNFP) corner is the worst case for write margin because:
- NMOS access transistors (N3) have elevated Vth → weaker drive current
- PMOS pull-up (P1) retains full or enhanced strength → stronger contention

| Cell | WM at SNFP (mV) | Technology |
|---|---|---|
| SR-Latch-12T (NMOS-only pass) | 135.2 | 40 nm |
| DWA-12T | 216 | 40 nm |
| **Proposed Unified 12T** | **175.1** | 40/45 nm |

The proposed cell improves WM by **30% over SR-Latch-12T** at the worst-case corner.

---

## 3. Leakage Current Analysis

### Leakage Components (Hold Mode)

```
I_leak = I_sub,P1 + I_sub,N1 + I_GIDL,P1 + I_gate,N1
```

| Component | Description |
|---|---|
| I_sub,P1 | PMOS sub-threshold drain current |
| I_sub,N1 | NMOS sub-threshold drain current |
| I_GIDL,P1 | Gate-induced drain leakage (PMOS) |
| I_gate,N1 | Gate oxide tunnelling current |

### Virtual-VSS Body Effect

Pre-charging VVSS to Vε ≈ 100 mV reverse-biases the source of N1 and N2 (source voltage > GND).

The effective Vth increase is:
```
ΔVth ≈ γ · (√(2φF + Vε) − √(2φF))
```

For 45 nm PTM: γ = 0.4 V^(1/2), φF = 0.35 V, Vε = 0.1 V:
```
ΔVth ≈ 0.4 · (√(0.70 + 0.10) − √(0.70))
     = 0.4 · (0.894 − 0.837)
     = 0.4 · 0.057
     ≈ 18 mV
```

**Sub-threshold current reduction factor:**
```
I_sub reduction = exp(ΔVth / n·VT) ≈ exp(18 mV / 26 mV) ≈ 2×  at 27°C
```

### Read-Path Leakage Contribution

During hold mode (RWL = 0):
- N6 and N8 are OFF (gate = 0V, source at RBL = VDD pre-charge)
- Their source-to-drain leakage is negligible compared to latch leakage
- N5 and N7 are controlled by Q and Q̄ — one is ON, but stacked above an OFF transistor → stack effect minimises leakage

### Simulated Leakage Comparison at 350 mV

| Cell | Leakage (nW) | Notes |
|---|---|---|
| 6T | 0.161 | Unstable at this VDD |
| PCA-12T | 0.362 | — |
| DWA-12T | 0.804 | — |
| SR-Latch-12T | 0.161 | Best-in-class |
| SCM-12T (300 mV) | ~1.09× Tri-buf | Minimum-L devices, no stacking |
| **Proposed Unified 12T** | **0.163** | Within 1.3% of SR-Latch-12T |

The slight overhead vs. SR-Latch-12T comes from the four additional read transistors (N5–N8) absent in the SR-Latch design.

---

## 4. Power-Delay Product

### Read Energy Model

For a two-stage bitline read-out (following SCM-12T segmentation approach):

```
E_read = C_Sub-RBL · VDD + C_Global-RBL · VDD · n_BL
```

Where:
- `C_Sub-RBL` = capacitance of sub-array bitline (16 cells per segment)
- `C_Global-RBL` = global bitline capacitance
- `n_BL` = fraction of global bitline discharged per operation

**Segmentation benefit:** With 16 cells per Sub-RBL:
```
C_Sub-RBL ≈ C_Global-RBL / 8
```
This yields approximately **8× reduction** in read energy relative to single-stage bitline.

### Simulated Energy Comparison

| Cell | Read Energy (fJ) | Write Energy (fJ) | VDD |
|---|---|---|---|
| 6T | 145 | 68 | 1.0 V |
| 8T | 80 | 55 | 1.0 V |
| 10T | 62 | 48 | 1.0 V |
| SR-Latch-12T | 49.3 | 49.3 | 0.35 V |
| SCM-12T | 14.2 | 28.5 | 0.35 V |
| DSPS-12T | 55 | 52 | — |
| **Proposed** | **38.2** | **35.1** | 0.35 V |

### Propagation Delay

| Condition | Read Access Delay | Write Delay |
|---|---|---|
| VDD = 1.0 V (proposed) | 0.31 ns | 0.25 ns |
| VDD = 1.2 V (Tri-buf SCM) | 2.87 ns | — |
| VDD = 350 mV (proposed) | 8.4 ns | 1.2 ns |
| VDD = 350 mV (SR-Latch-12T) | — | 1.35 ns |

- **9.3× read delay improvement** over Tri-buf SCM (attributable to segmented bitline)
- **11.1% shorter write delay** than SR-Latch-12T (attributable to DSPS write boost)
- Sub-threshold delay at 300 mV: consistent with e^(1/nVT) scaling

---

## 5. Monte Carlo PVT Analysis

### Setup

- **Simulator:** HSPICE
- **Points:** 1000-point Monte Carlo
- **Corners:** TT, FF, SS, FS, SF
- **Temperature:** −40°C, 27°C, 125°C
- **VDD:** 0.3 V, 0.5 V, 1.0 V

### RSNM Statistics at VDD = 350 mV, TT Corner

| Statistic | Value |
|---|---|
| Mean RSNM (μ) | 96.1 mV |
| Standard deviation (σ) | 11.3 mV |
| μ − 3σ (minimum functional RSNM) | 62.2 mV |
| 3σ yield estimate | 99.7% |

### Worst-Case (SS corner, −40°C)

| Statistic | Value |
|---|---|
| Mean RSNM | 71.4 mV |
| 6σ yield | > 99% |

> Acceptable for embedded cache applications with standard ECC protection.

---

## 6. Area Estimate

Using minimum-size transistors (80 nm / 60 nm) at 65 nm node, in a 6-track standard-cell row:

```
Bit-cell area = 2.98 µm × 1.335 µm = 3.98 µm²  (65 nm)
```

Applying 40 nm scaling factor (≈ 0.6):
```
Projected area at 40 nm ≈ 2.4 µm²
```

Comparable to SR-Latch-12T's reported 2.308 µm² (note: SR-Latch area excludes VGND generator peripheral).

| Cell | Area (µm²) | Ratio vs. 6T |
|---|---|---|
| 6T | 1.30 | 1.0× |
| 8T | 1.63 | 1.3× |
| 10T | 2.00 | 1.5× |
| SR-Latch-12T | 2.308 | 1.8× |
| **Proposed** | **2.38** | **1.8×** |
| SCM-12T | 4.15 | 3.2× |

---

*See [`operating_modes.md`](operating_modes.md) for the signal-level analysis that supports these derivations.*
