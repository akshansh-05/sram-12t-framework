# Cell Architecture: Proposed Unified 12T SRAM Cell

## Overview

The proposed unified 12T SRAM cell is composed of four functional groups:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROPOSED UNIFIED 12T CELL                    │
│                                                                 │
│  VDD                    VDD                                     │
│   │                      │                                      │
│  [P1]──────Q̄──────────[P2]                                     │
│   │    ┌───┘    └───┐    │       ← Storage Latch (HVT)         │
│  [N1]  │            │  [N2]                                     │
│   │    └──── Q ─────┘    │                                      │
│  GND                    GND                                     │
│                                                                 │
│  [P3] (gate=Q)         [P4] (gate=Q̄)                          │
│   ↕ DSPS Write Assist (RVT) ↕                                  │
│                                                                 │
│  WWLA──[N3]──Q      Q̄──[N4]──WWLB   ← Write Access (RVT)     │
│              │       │                                          │
│             BL      BLB                                         │
│                                                                 │
│  RBL──[N6]──[N5]──GND   (N5 gate=Q̄, N6 gate=RWL)            │
│  RBLB─[N8]──[N7]──GND   (N7 gate=Q,  N8 gate=RWL)            │
│              ↑ Read Path (RVT) — fully decoupled               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Transistor Table

| Device(s) | Type | Vth Flavour | W/L (65 nm node) | Function | Active Mode |
|---|---|---|---|---|---|
| P1, P2 | PMOS | HVT | 80 nm / 60 nm | Latch pull-up | All |
| N1, N2 | NMOS | HVT | 80 nm / 60 nm | Latch pull-down | All |
| P3, P4 | PMOS | RVT | Min. size | DSPS write assist | Write |
| N3, N4 | NMOS | RVT | Min. size | Write access | Write |
| N5, N6 | NMOS | RVT | Min. size | Read path (RBL) | Read |
| N7, N8 | NMOS | RVT | Min. size | Read path (RBLB) | Read |

**HVT** = High-Threshold Voltage (reduces leakage in hold mode)
**RVT** = Regular-Threshold Voltage (provides drive strength for access/assist)

---

## Signal Ports

| Port | Direction | Description |
|---|---|---|
| VDD | Power | Supply rail |
| GND | Power | Ground rail |
| WWLA | Input | Write Word-Line A (selects N3, controls P3 feedback) |
| WWLB | Input | Write Word-Line B (selects N4, controls P4 feedback) |
| RWL | Input | Read Word-Line (enables N6, N8) |
| BL | Bidirectional | Write bitline |
| RBL | Output | Read bitline (true) |
| RBLB | Output | Read bitline (complement) |
| VVSS | Input | Virtual-VSS (~100 mV in hold, 0 V in active) |

---

## Functional Block Descriptions

### 1. Storage Latch — P1, P2, N1, N2 (HVT)

A standard cross-coupled CMOS inverter pair forming the bistable latch:
- **Q** — primary storage node (left side)
- **Q̄** — complementary storage node (right side)
- Cross coupling: Q̄ → gates of P1 and N1; Q → gates of P2 and N2

HVT devices are used for both PMOS and NMOS to maximise hold-mode leakage suppression. The stack topology (P3-P1-N1 or P4-P2-N2) provides additional leakage reduction during hold mode via the Virtual-VSS biasing.

### 2. DSPS Write Assist — P3, P4 (RVT)

**Data-Dependent Stack PMOS Switching (DSPS):**

- P3 has its gate connected to **Q**
- P4 has its gate connected to **Q̄**

During a write-"0" to node Q (Q: 1→0):
1. WWLA is asserted; BL is pulled to 0 V
2. N3 turns ON; Q begins to discharge
3. Initially Q = 1, so P3's gate is at VDD → P3 is OFF
4. As Q drops below VDD − |VthP3|, P3 turns ON
5. P3 creates a low-impedance path from VDD to Q̄, strengthening the pull-up
6. This accelerates the data flip and improves write margin at SNFP corners

The DSPS mechanism is **self-referencing**: it responds to the currently stored value without requiring any external write-assist voltage rail (no negative bitline, no boosted WL).

**Write assist margin at 350 mV:**
- |VthP| ≈ 300 mV at nominal 40 nm
- P3 activates when Q ≈ 50 mV → provides ~80 mV write boost
- Resulting WM = 175 mV at SNFP corner (30% improvement over SR-Latch-12T)

### 3. Write Access Transistors — N3, N4 (RVT)

- **N3** is controlled by WWLA; connects BL to storage node Q
- **N4** is controlled by WWLB; connects BL to storage node Q̄
- Asymmetric WWL signalling: WWLA targets cells storing "1" on Q; WWLB targets cells storing "1" on Q̄
- This asymmetry is resolved at the row-level decoder (minimal peripheral overhead)

### 4. Decoupled Read Path — N5–N8 (RVT)

Two series stacks provide differential read-out:

**RBL path:** `RBL → N6(gate=RWL) → N5(gate=Q̄) → GND`
**RBLB path:** `RBLB → N8(gate=RWL) → N7(gate=Q) → GND`

**Critical property:** Storage nodes Q and Q̄ only control the *gate* of N5/N7 — they do not source or sink the read current. The storage latch is therefore **completely isolated from the bitline during read**, guaranteeing:

- **RSNM = HSNM by topology** (not by transistor sizing)
- Zero read-disturb for all operating conditions
- No sizing compromise between read stability and write ability

### 5. Virtual-VSS (VVSS) Leakage Suppression

Following the DSPS-12T approach:
- During **hold mode** and **half-select**: VVSS pre-charged to ε ≈ 100 mV
- This introduces reverse body bias on N1, N2, increasing effective Vth by ≈18 mV
- Sub-threshold current reduces by factor ≈2 at room temperature
- During **active read/write**: VVSS clamped to GND by row decoder

The body-effect Vth shift is given by:
```
ΔVth ≈ γ(√(2φF + Vε) − √(2φF))
```
where γ = 0.4 V^(1/2) and φF = 0.35 V for 45 nm PTM.

---

## Comparison with Prior 12T Architectures

| Feature | DSPS-12T | SCM-12T | SR-Latch-12T | **Proposed** |
|---|---|---|---|---|
| VVSS leakage suppression | ✅ | ❌ | Partial | ✅ |
| DSPS write assist | ✅ | ❌ | ❌ | ✅ |
| Fully decoupled read path | ✅ | ✅ | ✅ | ✅ |
| HVT latch transistors | ❌ | ✅ | Partial | ✅ |
| Asymmetric WWLA/WWLB | ❌ | ❌ | ❌ | ✅ |
| Differential read bitlines | ❌ | Partial | ✅ | ✅ |
| Standard-cell ports only | ❌ | ✅ | ❌ | ✅ |

---

*See [`operating_modes.md`](operating_modes.md) for detailed signal-level analysis of each operating mode.*
