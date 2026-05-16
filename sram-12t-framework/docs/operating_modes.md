# Operating Modes Analysis

This document provides detailed signal-level analysis for all five operating modes of the proposed unified 12T SRAM cell.

---

## Signal State Summary

| Mode | WWLA | WWLB | RWL | BL | VVSS | Key Transistors Active |
|---|---|---|---|---|---|---|
| Hold | 0 | 0 | 0 | VDD (pre) | ~100 mV | P1/P2 or N1/N2 (data-dependent) |
| Read | 0 | 0 | VDD | VDD (pre) | GND | N5/N6 or N7/N8 |
| Write "0" to Q | VDD | 0 | 0 | 0 | GND | N3, P3 (delayed) |
| Write "1" to Q | VDD | 0 | 0 | VDD | GND | N3, N1 |
| Row Half-Select | VDD | 0 | 0 | VDD (pre) | ~100 mV | N3 (no discharge) |
| Col Half-Select | 0 | 0 | 0 | Swinging | ~100 mV | All OFF |

---

## Mode 1: Hold Mode

**All word-lines grounded. VVSS ≈ 100 mV.**

```
WWLA = 0V    WWLB = 0V    RWL = 0V
BL = VDD (precharged)
VVSS = ~100 mV (precharged by peripheral)
```

**State:** N3, N4, N5, N6, N7, N8 are all OFF.

**Data retention via latch:**
- If Q = 1, Q̄ = 0: P2 ON (reinforces Q̄ = 0), P1 OFF, N1 OFF, N2 ON (reinforces Q = 1 via P3's off state)
- P3 gate = Q = 1 → P3 is OFF → no contention with N1
- P4 gate = Q̄ = 0 → P4 is ON → reinforces Q̄ = 0 (no contention because N2 is already pulling Q̄ down)

**Leakage path:**
```
Ileak = Isub,P1 + Isub,N1 + IGIDL,P1 + Igate,N1
```

The 100 mV VVSS reverse-biases N1 and N2 (source above GND), increasing their effective Vth by:
```
ΔVth ≈ γ(√(2φF + Vε) − √(2φF)) ≈ 18 mV
```
This reduces sub-threshold leakage by approximately **2× at 27°C**.

**Simulated leakage:** 0.163 nW at VDD = 350 mV (45 nm PTM, TT corner)

---

## Mode 2: Read Mode

**RWL raised to VDD. All write word-lines remain at 0. VVSS clamped to GND.**

```
RWL = VDD    WWLA = 0V    WWLB = 0V
RBL = VDD (precharged)    RBLB = VDD (precharged)
VVSS = 0V (clamped by row decoder)
```

### Case: Cell stores Q = 0, Q̄ = 1

1. N5 gate = Q̄ = 1 → N5 **ON**
2. N6 gate = RWL = VDD → N6 **ON**
3. **Discharge path:** RBL → N6 → N5 → GND → RBL begins to drop
4. N7 gate = Q = 0 → N7 **OFF**
5. N8 gate = RWL = VDD → N8 ON, but N7 OFF → no RBLB discharge path
6. RBLB remains at VDD

**Differential voltage RBLB − RBL is sensed by digital sense amplifier.**

### Why RSNM = HSNM

Q and Q̄ are **NOT** connected to BL or any current path during read — they only drive the gates of N5 and N7. Therefore:
- No read current flows through the latch
- No voltage disturbance on Q or Q̄
- The read operation is **topologically read-disturb free**

**Simulated RSNM:** 96.1 mV at FS corner, VDD = 350 mV

---

## Mode 3: Write Mode

### Write "0" to Q (Q: 1 → 0)

```
WWLA = VDD    BL = 0V    VVSS = GND
```

**Step-by-step sequence:**

1. WWLA = VDD → N3 turns ON
2. N3 connects BL (= 0V) to Q → Q begins to discharge toward 0
3. Initially Q = 1 → P3 gate = 1 = VDD → P3 is **OFF** (no assist yet)
4. Q drops; when Q < VDD − |VthP3|:
   - At VDD = 350 mV, |VthP3| ≈ 300 mV → P3 activates at Q ≈ 50 mV
   - P3 turns **ON** → low-impedance path VDD → P3 → Q̄
   - Q̄ is pulled high, reinforcing the inverter feedback (Q̄ → 1)
5. The strengthened Q̄ = 1 drives N2 harder, pulling Q further toward 0
6. Positive feedback completes the write flip

**DSPS write boost:** ΔVassist ≈ 80 mV at VDD = 350 mV

**Write delay:** 0.25 ns @ 1.0 V, 1.2 ns @ 350 mV (45 nm PTM, TT corner)

### Write "1" to Q (Q: 0 → 1)

```
WWLA = VDD    BL = VDD    VVSS = GND
```

1. WWLA = VDD → N3 turns ON
2. N3 connects BL (= VDD) to Q → Q driven high
3. Q = 0 initially → P3 gate = 0 → P3 turns **ON** immediately
4. P3 reinforces Q̄ = 0 (which complements the intended Q = 1 state)
5. Q̄ → 0 turns ON P1, further strengthening Q = 1
6. Write completes with assistance from both P3 and the latch feedback

**Simulated WM at SNFP corner:** 175.1 mV (30% higher than SR-Latch-12T's 135.2 mV)

---

## Mode 4: Row Half-Select

**WWLA is asserted (targeting another column in the same row), but BL is NOT driven — it remains precharged at VDD.**

```
WWLA = VDD    BL = VDD (precharged)    VVSS = ~100 mV
RWL = 0V    WWLB = 0V
```

### Case A: Half-selected cell stores Q = 1

1. WWLA = VDD → N3 turns ON
2. N3 connects BL (= VDD = Q) to Q — same voltage, no current flows
3. P3 gate = Q = 1 → P3 is **OFF** → no path disturbs Q̄
4. **Result: Cell state unchanged ✅**

### Case B: Half-selected cell stores Q = 0

1. WWLA = VDD → N3 turns ON
2. N3 connects BL (= VDD) to Q — attempts to raise Q from 0 to 1
3. P3 gate = Q = 0 → P3 is **ON** → P3 reinforces Q̄ = 1 (correct data)
4. Q̄ = 1 drives N2 harder, fighting the BL-induced Q rise
5. VVSS = 100 mV provides reverse body bias, further stiffening the latch
6. **The latch retains Q = 0 ✅** — the DSPS mechanism reinforces correct data

**Verified by:** 10,000-operation exhaustive simulation over all four (Qtarget, Qhalf-select) combinations in a 128×32 array — **zero data corruption events.**

---

## Mode 5: Column Half-Select

**A different row (row r′) is being written. The targeted column's BL swings. The current cell is in row r ≠ r′.**

```
WL[r'] = VDD    WWLA[r'] = VDD    (other row)
WWLA[r] = 0V    WWLB[r] = 0V     (this row — UNSELECTED)
BL = Swinging (driven by write to row r')
VVSS = ~100 mV
```

**Analysis:**
- N3 and N4 are controlled by **WWLA and WWLB** — row-based signals
- Since the current cell's row is not selected: WWLA = 0V, WWLB = 0V
- → N3 is **OFF**, N4 is **OFF**
- Even though BL is swinging, **no bitline voltage is injected into the storage latch**

**Column half-select immunity is guaranteed by topology** — the write access transistors are row-gated, not column-gated.

**Contrast with SCM-12T:** Shared column gating (PT/NT) means a selected column can disturb cells in unselected rows; no immunity analysis is provided for SCM-12T.

---

## Half-Select Immunity Summary

| Cell | Row HS Mechanism | Column HS Mechanism |
|---|---|---|
| 6T | None (WL raises access Tx) | None |
| 8T | None | BL decoupled by column gating |
| 10T | Partial (write HS remains) | Yes |
| SR-Latch-12T | Separate WWLA/WWLB | Separate RWL |
| SCM-12T | Partial (shared PT/NT risk) | Not analysed |
| DSPS-12T | DSPS self-protection | Row-gated write |
| **Proposed** | **DSPS + VVSS stiffening** | **WWLA/WWLB row-gating** |

---

*See [`circuit_analysis.md`](circuit_analysis.md) for the mathematical derivation of RSNM, WM, and leakage metrics.*
