#!/usr/bin/env bash
# ============================================================
# run_all_sims.sh — Master HSPICE Simulation Runner
# Unified 12T SRAM Framework
# ============================================================
# Prerequisites:
#   - HSPICE installed and in PATH
#   - PTM models downloaded (run scripts/setup_ptm.sh first)
#   - Python 3.9+ with dependencies installed
# ============================================================

set -e

RESULTS_DIR="results"
SIM_DIR="src/spice"
LOG_DIR="${RESULTS_DIR}/logs"

mkdir -p "${LOG_DIR}"
mkdir -p "${RESULTS_DIR}/figures"
mkdir -p "${RESULTS_DIR}/tables"

echo "============================================================"
echo "  Unified 12T SRAM — Full Simulation Suite"
echo "  $(date)"
echo "============================================================"

# ── Check HSPICE availability ─────────────────────────────────
if ! command -v hspice &> /dev/null; then
    echo "[WARNING] HSPICE not found in PATH."
    echo "          Set HSPICE_PATH or install HSPICE to run simulations."
    echo "          Skipping SPICE runs; Python analysis will use stored data."
    HSPICE_AVAILABLE=false
else
    HSPICE_AVAILABLE=true
    echo "[INFO] HSPICE found: $(which hspice)"
fi

# ── Corner sweep helper ───────────────────────────────────────
run_corner() {
    local TB="$1"
    local CORNER="$2"
    local VDD="$3"
    local OUT="${RESULTS_DIR}/${4}_${CORNER}_${VDD//./_}V"

    if [ "$HSPICE_AVAILABLE" = true ]; then
        echo "[SIM] Running: $TB | corner=$CORNER | VDD=${VDD}V"
        hspice -lib "models/45nm_bulk.pm" "$CORNER" \
               +param VDD_VAL="$VDD" \
               "${SIM_DIR}/${TB}" \
               -o "${OUT}" \
               >> "${LOG_DIR}/${4}.log" 2>&1
        echo "[SIM] Done → ${OUT}.lis"
    else
        echo "[SKIP] $TB ($CORNER, VDD=${VDD}V) — HSPICE unavailable"
    fi
}

# ── 1. Hold Mode Leakage ──────────────────────────────────────
echo ""
echo "[1/5] Hold Mode Leakage Analysis"
for VDD in 0.30 0.35 0.50 1.00; do
    for CORNER in TT FF SS FS SF; do
        run_corner "tb_half_select_row.sp" "$CORNER" "$VDD" "leakage"
    done
done

# ── 2. Read Mode — RSNM Extraction ───────────────────────────
echo ""
echo "[2/5] Read Mode — RSNM Butterfly Analysis"
for VDD in 0.35 0.50 1.00; do
    for CORNER in TT FS SF; do
        run_corner "tb_read.sp" "$CORNER" "$VDD" "read"
    done
done

# ── 3. Write Mode — WM Characterisation ──────────────────────
echo ""
echo "[3/5] Write Mode — Write Margin Analysis (SNFP worst case)"
for VDD in 0.30 0.35 0.50 1.00; do
    run_corner "tb_write.sp" "SF" "$VDD" "write"    # SF = SNFP worst case
    run_corner "tb_write.sp" "TT" "$VDD" "write"
done

# ── 4. Half-Select Immunity ───────────────────────────────────
echo ""
echo "[4/5] Half-Select Immunity — 10,000 Operation Stress Test"
for CORNER in TT FS SF; do
    run_corner "tb_half_select_row.sp" "$CORNER" "0.35" "half_select_row"
done

# ── 5. Monte Carlo PVT Analysis ───────────────────────────────
echo ""
echo "[5/5] Monte Carlo PVT — 1000-Point Analysis"
for VDD in 0.30 0.35 0.50 1.00; do
    for CORNER in TT FS SF; do
        if [ "$HSPICE_AVAILABLE" = true ]; then
            echo "[SIM] MC: VDD=${VDD}V | corner=${CORNER}"
            hspice -lib "models/45nm_bulk.pm" "$CORNER" \
                   +param VDD_VAL="$VDD" \
                   "${SIM_DIR}/tb_montecarlo.sp" \
                   -o "${RESULTS_DIR}/mc_${CORNER}_${VDD//./_}V" \
                   >> "${LOG_DIR}/montecarlo.log" 2>&1
        else
            echo "[SKIP] MC VDD=${VDD}V $CORNER — HSPICE unavailable"
        fi
    done
done

# ── Post-Processing ───────────────────────────────────────────
echo ""
echo "============================================================"
echo "  Post-Processing and Plot Generation"
echo "============================================================"

echo "[PYTHON] Generating SNM analysis plots..."
python src/python/snm_analysis.py --demo

echo "[PYTHON] Generating benchmark comparison charts..."
python src/python/benchmark_compare.py

echo ""
echo "============================================================"
echo "  All simulations complete!"
echo "  Results in: ${RESULTS_DIR}/"
echo "  Logs in:    ${LOG_DIR}/"
echo "============================================================"
