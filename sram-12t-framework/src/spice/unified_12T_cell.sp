* ============================================================
* Unified 12T SRAM Cell — HSPICE Netlist
* ============================================================
* Reference: "A Comparative Analysis and Unified Design Framework
*             for High-Performance Low-Power 12T SRAM Cells"
* Technology: 45 nm / 65 nm Predictive Technology Model (PTM)
*             http://ptm.asu.edu
* ============================================================
* Transistor Map:
*   P1, P2  — HVT PMOS latch pull-up
*   N1, N2  — HVT NMOS latch pull-down
*   P3, P4  — RVT PMOS DSPS write assist
*   N3, N4  — RVT NMOS write access
*   N5, N6  — RVT NMOS read path (RBL)
*   N7, N8  — RVT NMOS read path (RBLB)
*
* Ports:
*   VDD  — Supply
*   GND  — Ground
*   Q    — Storage node (primary)
*   QB   — Storage node (complement = Q-bar)
*   WWLA — Write Word-Line A (row-based, controls N3/P3)
*   WWLB — Write Word-Line B (row-based, controls N4/P4)
*   RWL  — Read Word-Line
*   BL   — Write Bitline
*   RBL  — Read Bitline (true)
*   RBLB — Read Bitline (complement)
*   VVSS — Virtual VSS (~100 mV hold, 0 V active)
* ============================================================

.SUBCKT UNIFIED_12T VDD GND Q QB WWLA WWLB RWL BL RBL RBLB VVSS

* --- Storage Latch ---
* P1: PMOS pull-up, left side  (gate = QB → turns ON when QB = 0)
MP1  Q   QB  VDD VDD  PMOS_HVT W=80n L=60n

* P2: PMOS pull-up, right side (gate = Q  → turns ON when Q = 0)
MP2  QB  Q   VDD VDD  PMOS_HVT W=80n L=60n

* N1: NMOS pull-down, left side  (gate = QB)
MN1  Q   QB  VVSS VVSS NMOS_HVT W=80n L=60n

* N2: NMOS pull-down, right side (gate = Q)
MN2  QB  Q   VVSS VVSS NMOS_HVT W=80n L=60n

* --- DSPS Write Assist ---
* P3: gate = Q; during write-0 to Q, turns ON as Q drops, pulling QB high
MP3  QB  Q   VDD VDD  PMOS_RVT W=80n L=60n

* P4: gate = QB; during write-1 to Q, reinforces QB = 0
MP4  Q   QB  VDD VDD  PMOS_RVT W=80n L=60n

* --- Write Access Transistors ---
* N3: WWLA-controlled access to Q
MN3  Q   WWLA BL  GND  NMOS_RVT W=80n L=60n

* N4: WWLB-controlled access to QB
MN4  QB  WWLB BL  GND  NMOS_RVT W=80n L=60n

* --- Decoupled Read Path (RBL) ---
* N5: gated by QB; if QB=1 (cell stores 0 on Q), creates discharge path
MN5  int_rbl_n QB  GND GND  NMOS_RVT W=80n L=60n

* N6: gated by RWL; series with N5
MN6  RBL RWL  int_rbl_n GND  NMOS_RVT W=80n L=60n

* --- Decoupled Read Path (RBLB) ---
* N7: gated by Q; if Q=1 (cell stores 1), creates RBLB discharge path
MN7  int_rblb_n Q   GND GND  NMOS_RVT W=80n L=60n

* N8: gated by RWL; series with N7
MN8  RBLB RWL int_rblb_n GND  NMOS_RVT W=80n L=60n

.ENDS UNIFIED_12T

* ============================================================
* Technology Model Includes
* Modify paths to match your PTM installation
* ============================================================
* .include "./models/45nm_bulk.pm"
* .include "./models/65nm_bulk.pm"
* .lib  "./models/45nm_bulk.pm" TT    $ Typical corner
* .lib  "./models/45nm_bulk.pm" FF    $ Fast-N Fast-P
* .lib  "./models/45nm_bulk.pm" SS    $ Slow-N Slow-P
* .lib  "./models/45nm_bulk.pm" FS    $ Fast-N Slow-P
* .lib  "./models/45nm_bulk.pm" SF    $ Slow-N Fast-P (SNFP = worst WM)

* ============================================================
* Model Definitions (simplified — replace with PTM models)
* ============================================================
* PMOS HVT: High-Vth PMOS for latch (|Vth| ~ 480 mV at 45 nm)
.MODEL PMOS_HVT PMOS LEVEL=14
+  VTH0=-0.48 TOX=1.8E-9 XJ=15E-9
+  LINT=5E-9  WINT=5E-9

* NMOS HVT: High-Vth NMOS for latch
.MODEL NMOS_HVT NMOS LEVEL=14
+  VTH0=0.48  TOX=1.8E-9 XJ=15E-9
+  LINT=5E-9  WINT=5E-9

* PMOS RVT: Regular-Vth PMOS for write assist and read path
.MODEL PMOS_RVT PMOS LEVEL=14
+  VTH0=-0.40 TOX=1.8E-9 XJ=15E-9
+  LINT=5E-9  WINT=5E-9

* NMOS RVT: Regular-Vth NMOS for access and read path
.MODEL NMOS_RVT NMOS LEVEL=14
+  VTH0=0.40  TOX=1.8E-9 XJ=15E-9
+  LINT=5E-9  WINT=5E-9

* NOTE: Replace the above simplified .MODEL statements with
* the full PTM BSIM4 models from http://ptm.asu.edu
* for accurate simulation.
