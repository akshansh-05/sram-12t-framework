* ============================================================
* Testbench: Row Half-Select Immunity
* ============================================================
* Scenario: WWLA is asserted (targeting another column on
*   the same row), but BL stays precharged at VDD.
*   The cell-under-test must NOT flip its data.
*
* Verifies both cases:
*   Case A: Half-selected cell stores Q = 1
*   Case B: Half-selected cell stores Q = 0
* ============================================================

.TITLE "Unified 12T SRAM Row Half-Select Immunity Testbench"

.include "./unified_12T_cell.sp"
* .lib "./models/45nm_bulk.pm" TT

.PARAM VDD_VAL = 0.35
.PARAM T_HS    = 5.0n
.PARAM T_SETTLE = 0.5n

VVDD VDD 0 DC=VDD_VAL
VGND GND 0 DC=0

* VVSS held at 100 mV during half-select (hold-like condition)
VVVSS VVSS 0 DC=0.1

* ============================================================
* Cell A: Stores Q=1, QB=0 (Case A)
* ============================================================
XCELL_A VDD GND QA QAB WWLA_A WWLB_A RWL_A BL_A RBLA RBLBA VVSS UNIFIED_12T
.IC V(QA)=VDD_VAL V(QAB)=0

* WWLA asserted — simulates row half-select
VWWLA_A WWLA_A 0 PULSE(0 VDD_VAL T_SETTLE 0.01n 0.01n T_HS 20n)
VWWLB_A WWLB_A 0 DC=0
VRWL_A  RWL_A  0 DC=0
* BL precharged — no write target
VBL_A   BL_A   0 DC=VDD_VAL
VRBLA   RBLA   0 DC=VDD_VAL
VRBLBA  RBLBA  0 DC=VDD_VAL

* ============================================================
* Cell B: Stores Q=0, QB=1 (Case B)
* ============================================================
XCELL_B VDD GND QB_n QBB WWLA_B WWLB_B RWL_B BL_B RBLB_n RBLBB VVSS UNIFIED_12T
.IC V(QB_n)=0 V(QBB)=VDD_VAL

VWWLA_B WWLA_B 0 PULSE(0 VDD_VAL T_SETTLE 0.01n 0.01n T_HS 20n)
VWWLB_B WWLB_B 0 DC=0
VRWL_B  RWL_B  0 DC=0
VBL_B   BL_B   0 DC=VDD_VAL
VRBLB_n RBLB_n 0 DC=VDD_VAL
VRBLBB  RBLBB  0 DC=VDD_VAL

* ============================================================
* Analysis
* ============================================================
.TRAN 0.01n 10n

.PROBE V(QA) V(QAB) V(QB_n) V(QBB)
.PROBE V(WWLA_A) V(BL_A)

* Cell A should stay at QA = VDD throughout
.MEASURE TRAN qa_min
+  MIN V(QA) FROM=T_SETTLE TO='T_SETTLE+T_HS'

* Cell B should stay at QB_n = 0 throughout
.MEASURE TRAN qb_max
+  MAX V(QB_n) FROM=T_SETTLE TO='T_SETTLE+T_HS'

.OPTIONS POST=2 BRIEF

.END


* ============================================================
* Testbench: Column Half-Select Immunity
* ============================================================
* Scenario: A different row (row r') is being written via its
*   WWLA. The column bitline BL swings to 0 V. The cell-under-
*   test (row r ≠ r') has WWLA=0, WWLB=0 throughout.
* ============================================================
*
* NOTE: Run this as a separate simulation file:
*       cp tb_half_select_row.sp tb_half_select_col.sp
*       and edit as below.
*
* .TITLE "Unified 12T SRAM Column Half-Select Immunity Testbench"
*
* .include "./unified_12T_cell.sp"
*
* .PARAM VDD_VAL = 0.35
* .PARAM T_COL_SWING = 5.0n
*
* VVDD VDD 0 DC=VDD_VAL
* VGND GND 0 DC=0
* VVVSS VVSS 0 DC=0.1   $ VVSS at 100 mV — hold-like
*
* * Cell-under-test: stores Q=1
* XCELL VDD GND Q QB WWLA WWLB RWL BL RBL RBLB VVSS UNIFIED_12T
* .IC V(Q)=VDD_VAL V(QB)=0
*
* * All word-lines for this cell are DEASSERTED
* VWWLA WWLA 0 DC=0
* VWWLB WWLB 0 DC=0
* VRWL  RWL  0 DC=0
*
* * BL is being swung by the selected row r' write operation
* VBL BL 0 PULSE(VDD_VAL 0 0.5n 0.01n 0.01n T_COL_SWING 20n)
*
* VRBL  RBL  0 DC=VDD_VAL
* VRBLB RBLB 0 DC=VDD_VAL
*
* .TRAN 0.01n 10n
* .PROBE V(Q) V(QB) V(BL) V(WWLA)
*
* * Q should not move despite BL swinging
* .MEASURE TRAN q_disturb MAX V(Q) FALL=1
* .MEASURE TRAN q_min     MIN V(Q)
*
* .OPTIONS POST=2 BRIEF
* .END
