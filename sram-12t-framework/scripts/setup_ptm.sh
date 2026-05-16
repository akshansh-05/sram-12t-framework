#!/usr/bin/env bash
# ============================================================
# setup_ptm.sh — Download and Configure PTM Technology Models
# ============================================================
# Downloads the Predictive Technology Model (PTM) BSIM4 model
# files from Arizona State University for 40 nm, 45 nm, and
# 65 nm CMOS technology nodes.
#
# Reference: http://ptm.asu.edu
# ============================================================

set -e

MODELS_DIR="models"
PTM_BASE="http://ptm.asu.edu/modelcard/2006"

mkdir -p "${MODELS_DIR}"

echo "============================================================"
echo "  PTM Model Download — Unified 12T SRAM Framework"
echo "============================================================"
echo ""
echo "Downloading PTM BSIM4 models from ptm.asu.edu ..."
echo ""

download_model() {
    local FILENAME="$1"
    local URL="${PTM_BASE}/${FILENAME}"
    local DEST="${MODELS_DIR}/${FILENAME}"

    if [ -f "${DEST}" ]; then
        echo "[SKIP] Already exists: ${DEST}"
    else
        echo "[DL] ${URL}"
        if command -v curl &> /dev/null; then
            curl -sSL "${URL}" -o "${DEST}" || echo "[WARN] Download failed: ${FILENAME}"
        elif command -v wget &> /dev/null; then
            wget -q "${URL}" -O "${DEST}" || echo "[WARN] Download failed: ${FILENAME}"
        else
            echo "[ERROR] Neither curl nor wget found. Download manually from:"
            echo "        ${URL}"
        fi
    fi
}

# Download PTM model files
download_model "45nm_bulk.pm"
download_model "65nm_bulk.pm"
download_model "40nm_bulk.pm"    # May need to construct manually from PTM site

echo ""
echo "============================================================"
echo "  Model Setup Instructions"
echo "============================================================"
echo ""
echo "1. Verify downloads in: ${MODELS_DIR}/"
echo ""
echo "2. In each .sp testbench file, uncomment the .lib line:"
echo "   .lib \"./models/45nm_bulk.pm\" TT"
echo ""
echo "3. Available process corners:"
echo "   TT  — Typical NMOS / Typical PMOS"
echo "   FF  — Fast NMOS / Fast PMOS"
echo "   SS  — Slow NMOS / Slow PMOS"
echo "   FS  — Fast NMOS / Slow PMOS (worst RSNM)"
echo "   SF  — Slow NMOS / Fast PMOS (worst WM = SNFP corner)"
echo ""
echo "4. HVT / RVT device flavours:"
echo "   The PTM bulk models do not include HVT/RVT by default."
echo "   Adjust VTH0 parameter in model cards:"
echo "     HVT NMOS: VTH0 = +0.48V  (standard + 80 mV)"
echo "     HVT PMOS: VTH0 = -0.48V"
echo "     RVT NMOS: VTH0 = +0.40V  (standard)"
echo "     RVT PMOS: VTH0 = -0.40V"
echo ""
echo "5. For accurate Monte Carlo mismatch simulation, add Pelgrom"
echo "   mismatch parameters to the model card:"
echo "     .PARAM AVTH0_N = 3.5e-3   \$ Pelgrom coefficient (V·μm)"
echo "     .PARAM AVTH0_P = 3.5e-3"
echo ""
echo "Setup complete. Run: bash scripts/run_all_sims.sh"
