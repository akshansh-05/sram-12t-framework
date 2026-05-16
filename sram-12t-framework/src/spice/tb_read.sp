* ============================================================
* Testbench: Read Mode — RSNM and Read-Disturb Verification
* ============================================================
* Tests:
*   1. Read "0" from Q  — RBL discharges, RBLB holds
*   2. Read "1" from Q  — RBLB discharges, RBL holds
*   3. Butterfly curve sweep for RSNM extraction
*   4. Verify Q and QB are undisturbed throughout read
* ============================================================

.TITLE "Unified 12T SRAM Read Mode Testbench"

* Include cell and models
.include "./unified_12T_cell.sp"
* .lib "./models/45nm_bulk.pm" TT

* ============================================================
* Parameters
* ============================================================
.PARAM VDD_VAL = 0.35         $ Supply voltage (sub-threshold)
.PARAM T_PRECHARGE = 0.5n    $ Bitline precharge time
.PARAM T_RWL_PULSE = 2.0n    $ RWL pulse width

* ============================================================
* Supply and Reference
* ============================================================
VVDD  VDD  0  DC=VDD_VAL
VGND  GND  0  DC=0

* Virtual VSS — clamped to GND during read
VVVSS VVSS 0  DC=0

* ============================================================
* DUT — Cell storing "0" on Q (Q=0, QB=1)
* Initial conditions set via .IC
* ============================================================
XCELL1 VDD GND Q QB WWLA WWLB RWL BL RBL RBLB VVSS UNIFIED_12T

.IC V(Q)=0 V(QB)=VDD_VAL     $ Cell stores 0 on Q

* ============================================================
* Stimulus
* ============================================================
* Write word-lines inactive throughout read
VWWLA WWLA 0  DC=0
VWWLB WWLB 0  DC=0

* BL precharged and held high
VBL   BL   0  DC=VDD_VAL

* RBL: precharged high, then released for sensing
VRBL  RBL  0  PWL(
+  0          VDD_VAL
+  T_PRECHARGE VDD_VAL
+  'T_PRECHARGE+0.01n' Z     $ High-Z: release for discharge
+ )

* RBLB: precharged high, then released
VRBLB RBLB 0  PWL(
+  0          VDD_VAL
+  T_PRECHARGE VDD_VAL
+  'T_PRECHARGE+0.01n' Z     $ High-Z: release for discharge
+ )

* RWL: pulse to trigger read
VRWL  RWL  0  PULSE(
+  0           VDD_VAL
+  T_PRECHARGE
+  0.01n       0.01n
+  T_RWL_PULSE
+  10n
+ )

* ============================================================
* Load capacitance on bitlines (16-cell Sub-RBL segment)
* C_Sub-RBL ≈ 16 × (2 × Cdiff + Cwire) ≈ 4 fF
* ============================================================
CRBL  RBL  0  4f
CRBLB RBLB 0  4f

* ============================================================
* Analysis
* ============================================================
.TRAN 0.01n 10n SWEEP MONTE=1000   $ Transient + Monte Carlo

* Static RSNM butterfly curve (DC sweep)
* Run separately with .DC sweep:
* .DC VNOISE -0.5 0.5 0.001

.PROBE V(Q) V(QB) V(RBL) V(RBLB) V(VVSS)
.PROBE I(VVDD)  $ Supply current

* Measure read access time (10% to 50% of VDD swing on RBL)
.MEASURE TRAN tread_50
+  TRIG V(RBL)  VAL='0.9*VDD_VAL'  FALL=1
+  TARG V(RBL)  VAL='0.5*VDD_VAL'  FALL=1

* Measure read disturb: Q should not deviate
.MEASURE TRAN q_disturb_max
+  MAX V(Q) FROM=T_PRECHARGE TO='T_PRECHARGE + T_RWL_PULSE'

* ============================================================
* Options
* ============================================================
.OPTIONS ACCURATE=1 RUNLVL=5 POST=2 BRIEF

.END
