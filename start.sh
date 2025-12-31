#!/usr/bin/env bash
set -euo pipefail

echo "[start] user=$(id -u):$(id -g) arch=$(uname -m) date=$(date -Iseconds)"

# Asegura venv en PATH
export PATH="/opt/venv/bin:${PATH}"

echo "[start] python=$(python --version 2>&1 || true)"
echo "[start] which python=$(command -v python || true)"
echo "[start] which streamlit=$(command -v streamlit || true)"

# OpenBLAS en ARM (evita SIGILL típicos)
export OPENBLAS_CORETYPE="${OPENBLAS_CORETYPE:-ARMV8}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export NUMEXPR_NUM_THREADS="${NUMEXPR_NUM_THREADS:-1}"

# Geo libs
export GEOS_LIBRARY_PATH="${GEOS_LIBRARY_PATH:-/lib/aarch64-linux-gnu/libgeos_c.so.1}"
export LD_LIBRARY_PATH="/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu:/lib:/usr/lib:${LD_LIBRARY_PATH:-}"

echo "[start] GEOS_LIBRARY_PATH=$GEOS_LIBRARY_PATH"
echo "[start] LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
ls -lah /lib/aarch64-linux-gnu/libgeos_c.so* 2>/dev/null || true
ldconfig -p 2>/dev/null | grep -i geos || true

# Diagnóstico: muestra el error REAL del loader si falla
python - <<'PY'
import ctypes
p="/lib/aarch64-linux-gnu/libgeos_c.so.1"
try:
    ctypes.CDLL(p)
    print("[start] ctypes.CDLL(GEOS) OK:", p)
except OSError as e:
    print("[start] ctypes.CDLL(GEOS) FAILED:", e)
PY

# setup opcional
if [ -f "./setup.sh" ]; then
  echo "[start] running setup.sh"
  sh ./setup.sh
fi

# Arranque Streamlit
exec streamlit run APP_Dades.py --server.address 0.0.0.0 --server.port 8501
