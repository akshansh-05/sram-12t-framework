* ============================================================
* Testbench: Write Mode — DSPS Write Assist Verification
* ============================================================
* Tests:
*   1. Write "0" to Q (Q: 1→0) — DSPS P3 assist activation
*   2. Write "1" to Q (Q: 0→1) — P4 pre-activated
*   3. WM sweep vs VDD (write margin characterisation)
*   4. SNFP process corner worst-case analysis
* ============================================================

.TITLE "Unified 12T SRAM Write Mode Testbench — DSPS Assist"

.include "./unified_12T_cell.sp"
* .lib "./models/45nm_bulk.pm" SF    $ SNFP = worst WM corner

.PARAM VDD_VAL = 0.35
.PARAM T_WRITE  = 2.0n
.PARAM T_SETTLE = 0.5n

VVDD  VDD  0  DC=VDD_VAL
VGND  GND  0  DC=0

* VVSS = GND during write
VVVSS VVSS 0  DC=0

* DUT — starts storing Q=1, QB=0
XCELL1 VDD GND Q QB WWLA WWLB RWL BL RBL RBLB VVSS UNIFIED_12T
.IC V(Q)=VDD_VAL V(QB)=0

* Read word-line inactive
VRWL  RWL  0  DC=0

* WWLB inactive (we write via WWLA only)
VWWLB WWLB 0  DC=0

* WWLA: assert to enable write to Q
VWWLA WWLA 0  PULSE(
+  0           VDD_VAL
+  T_SETTLE
+  0.01n       0.01n
+  T_WRITE
+  20n
+ )

* BL = 0V (write "0" to Q)
VBL BL 0 PULSE(
+  VDD_VAL  0
+  T_SETTLE
+  0.01n    0.01n
+  T_WRITE
+  20n
+ )

* Read bitlines — precharged but idle
VRBL  RBL  0  DC=VDD_VAL
VRBLB RBLB 0  DC=VDD_VAL

* ============================================================
* Analysis
* ============================================================
.TRAN 0.01n 15n

.PROBE V(Q) V(QB) V(WWLA) V(BL)

* Write delay: BL falling edge to Q crossing 50% VDD
.MEASURE TRAN twrite
+  TRIG V(BL)  VAL='0.5*VDD_VAL' FALL=1
+  TARG V(Q)   VAL='0.5*VDD_VAL' FALL=1

* Write success check — Q should reach < 0.1*VDD after write
.MEASURE TRAN q_final
+  FIND V(Q) AT='T_SETTLE + T_WRITE + 0.5n'

* DSPS activation point: when does P3 turn on?
* (When V(Q) drops below VDD - |VthP3| ≈ 50 mV at 350 mV)
.MEASURE TRAN t_dsps_on
+  TRIG V(WWLA) VAL='0.5*VDD_VAL' RISE=1
+  TARG V(Q)    VAL=0.05          FALL=1

* ============================================================
* Write Margin Sweep (separate .DC analysis)
* ============================================================
* Sweep VDD from 0.2V to 1.2V; find minimum VDD for write
* .DC VDD 0.2 1.2 0.01 SWEEP PARAM VDD_VAL

.OPTIONS ACCURATE=1 POST=2 BRIEF

.END
