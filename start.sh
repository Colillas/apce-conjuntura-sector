#!/usr/bin/env bash
set -e

# Asegura que Shapely encuentre GEOS
export GEOS_LIBRARY_PATH="${GEOS_LIBRARY_PATH:-/lib/aarch64-linux-gnu/libgeos_c.so.1}"
export LD_LIBRARY_PATH="/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu:/lib:/usr/lib:${LD_LIBRARY_PATH:-}"

# Si necesitas setup.sh, ejecútalo (si existe)
if [ -f "./setup.sh" ]; then
  sh ./setup.sh
fi

# Arranque Streamlit
exec streamlit run APP_Dades.py --server.address 0.0.0.0 --server.port "${PORT:-8501}"
