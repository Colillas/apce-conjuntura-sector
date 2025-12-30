#!/usr/bin/env bash
set -euo pipefail

echo "[start] user=$(id -u):$(id -g) arch=$(uname -m) date=$(date -Iseconds)"
echo "[start] python=$(python --version 2>&1 || true)"

# Fuerza OpenBLAS en ARM (evita SIGILL típicos)
export OPENBLAS_CORETYPE="${OPENBLAS_CORETYPE:-ARMV8}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export NUMEXPR_NUM_THREADS="${NUMEXPR_NUM_THREADS:-1}"

# Asegura que Shapely encuentre GEOS
export GEOS_LIBRARY_PATH="${GEOS_LIBRARY_PATH:-/lib/aarch64-linux-gnu/libgeos_c.so.1}"
export LD_LIBRARY_PATH="/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu:/lib:/usr/lib:${LD_LIBRARY_PATH:-}"

echo "[start] OPENBLAS_CORETYPE=$OPENBLAS_CORETYPE OPENBLAS_NUM_THREADS=$OPENBLAS_NUM_THREADS OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo "[start] GEOS_LIBRARY_PATH=$GEOS_LIBRARY_PATH"
ls -lah /lib/aarch64-linux-gnu/libgeos_c.so* 2>/dev/null || true

# setup opcional
if [ -f "./setup.sh" ]; then
  echo "[start] running setup.sh"
  sh ./setup.sh
fi

# Arranque Streamlit (puerto fijo)
exec streamlit run APP_Dades.py --server.address 0.0.0.0 --server.port 8501
