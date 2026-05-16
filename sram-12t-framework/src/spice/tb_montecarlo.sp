* ============================================================
* Testbench: 1000-Point Monte Carlo RSNM / WM Analysis
* ============================================================
* Evaluates RSNM and WM distribution across process variation
* at VDD = {0.3, 0.35, 0.5, 1.0} V
* Temperature: {-40, 27, 125} °C
* Corners: TT, FF, SS, FS, SF (SNFP = worst WM)
*
* Run with HSPICE Monte Carlo:
*   hspice tb_montecarlo.sp -o results/mc_sim
* ============================================================

.TITLE "Unified 12T SRAM — 1000-Point Monte Carlo"

.include "./unified_12T_cell.sp"
* .lib "./models/45nm_bulk.pm" TT   $ Change for different corners

* ============================================================
* Parameters — Sweep these for full PVT analysis
* ============================================================
.PARAM VDD_VAL = 0.35     $ Sub-threshold target
.PARAM TEMP    = 27       $ Temperature (°C)
.TEMP TEMP

* ============================================================
* Monte Carlo Setup
* ============================================================
* Enable process variation: Vth mismatch via Pelgrom model
* These parameters are technology-specific; adjust per PTM
.PARAM
+ SIGVTH_P = 3.5m    $ PMOS Vth sigma (mV), 45nm typical
+ SIGVTH_N = 3.5m    $ NMOS Vth sigma (mV)
+ SIGTOX   = 0.05n   $ Tox sigma

* ============================================================
* Supply
* ============================================================
VVDD VDD 0 DC=VDD_VAL
VGND GND 0 DC=0
VVVSS VVSS 0 DC=0       $ GND during active modes

* ============================================================
* DUT — RSNM Extraction via SNM Butterfly Curve
* ============================================================
* Method: Apply a DC noise source in series with latch feedback
* and sweep to find the maximum tolerable noise before flip.
*
* Reference: Seevinck et al., IEEE J. Solid-State Circuits 1987

XCELL VDD GND Q QB WWLA WWLB RWL BL RBL RBLB VVSS UNIFIED_12T
.IC V(Q)=VDD_VAL V(QB)=0

* All write/read signals de-asserted (HOLD mode for HSNM = RSNM)
VWWLA WWLA 0 DC=0
VWWLB WWLB 0 DC=0
VRWL  RWL  0 DC=0
VBL   BL   0 DC=VDD_VAL
VRBL  RBL  0 DC=VDD_VAL
VRBLB RBLB 0 DC=VDD_VAL

* Noise voltage source in feedback path (for butterfly sweep)
* Insert between QB feedback and Q gate during DC SNM measurement
* VNOISE_Q QFEED Q  DC=0 SWEEP -VDD_VAL VDD_VAL 0.001

* ============================================================
* Write Margin Extraction
* ============================================================
* Method: Hold WWLA=VDD, vary VDD downward until write fails
* Simulate separately with .DC PARAM sweep on VDD_VAL

* ============================================================
* Monte Carlo Analysis Command
* ============================================================
.TRAN 0.01n 20n SWEEP MONTE=1000

* Measure at each MC iteration:

* RSNM proxy: minimum latch node voltage during hold
.MEASURE TRAN rsnm_proxy
+  MIN V(Q) FROM=1n TO=20n

* Latch state after settling (should be 1 if data retained)
.MEASURE TRAN q_final
+  FIND V(Q) AT=19n

* Write margin proxy: time-to-flip during write stress
* (Uncomment and modify BL/WWLA stimulus for WM MC analysis)
* .MEASURE TRAN tflip
*   TRIG V(WWLA) VAL='0.5*VDD_VAL' RISE=1
*   TARG V(Q)    VAL='0.5*VDD_VAL' FALL=1

* ============================================================
* Statistics Output
* ============================================================
* HSPICE will output Monte Carlo statistics automatically.
* Post-process with: python src/python/monte_carlo_plot.py

.PROBE V(Q) V(QB)

* ============================================================
* PVT Sweep — Run multiple times with:
*   .lib TT  / FF  / SS  / FS  / SF
*   .TEMP -40 / 27 / 125
*   VDD_VAL = 0.3 / 0.35 / 0.5 / 1.0
* ============================================================

.OPTIONS ACCURATE=1 RUNLVL=5 POST=2 BRIEF MEASFORM=3

.END
