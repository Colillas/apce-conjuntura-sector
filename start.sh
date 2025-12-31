#!/usr/bin/env bash
set -euo pipefail

echo "[start] date=$(date -Iseconds) arch=$(uname -m)"

# 1) Asegura venv SIEMPRE
if [ -f /opt/venv/bin/activate ]; then
  # shellcheck disable=SC1091
  source /opt/venv/bin/activate
else
  echo "[start][FATAL] No existe /opt/venv/bin/activate"
  exit 1
fi

echo "[start] python=$(python --version 2>&1 || true)"
echo "[start] which python=$(which python || true)"
echo "[start] which streamlit=$(which streamlit || true)"

# 2) OpenBLAS (ARM) – evita SIGILL típicos
export OPENBLAS_CORETYPE="${OPENBLAS_CORETYPE:-ARMV8}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-1}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export NUMEXPR_NUM_THREADS="${NUMEXPR_NUM_THREADS:-1}"

# 3) Geo libs (GEOS)
export GEOS_LIBRARY_PATH="${GEOS_LIBRARY_PATH:-/lib/aarch64-linux-gnu/libgeos_c.so.1}"
export LD_LIBRARY_PATH="/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu:/lib:/usr/lib:${LD_LIBRARY_PATH:-}"

echo "[start] OPENBLAS_CORETYPE=$OPENBLAS_CORETYPE OPENBLAS_NUM_THREADS=$OPENBLAS_NUM_THREADS"
echo "[start] GEOS_LIBRARY_PATH=$GEOS_LIBRARY_PATH"
ls -lah /lib/aarch64-linux-gnu/libgeos_c.so* 2>/dev/null || true

# 4) Smoke test para que el log te diga exactamente dónde peta
echo "[start] smoke-import numpy..."
python -c "import numpy as np; print('numpy ok', np.__version__)"
echo "[start] smoke-import shapely..."
python -c "import shapely; print('shapely ok', shapely.__version__)"
echo "[start] smoke-import geopandas..."
python -c "import geopandas as gpd; print('geopandas ok', gpd.__version__)"

# 5) setup opcional
if [ -f "./setup.sh" ]; then
  echo "[start] running setup.sh"
  sh ./setup.sh
fi

# 6) Arranque Streamlit
exec streamlit run APP_Dades.py --server.address 0.0.0.0 --server.port "${PORT:-8501}"
