#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

separator() {
  echo ""
  echo "######################################################"
  echo "# $1"
  echo "######################################################"
  echo ""
}

separator "Julia"
START_J=$(date +%s%N)
julia src/main.jl
END_J=$(date +%s%N)
JULIA_MS=$(( (END_J - START_J) / 1000000 ))

separator "Python"
START_P=$(date +%s%N)
python3 src/main.py
END_P=$(date +%s%N)
PYTHON_MS=$(( (END_P - START_P) / 1000000 ))

separator "比較結果"
echo "  Julia  総実行時間: ${JULIA_MS} ms"
echo "  Python 総実行時間: ${PYTHON_MS} ms"
echo ""
if [ "$JULIA_MS" -gt 0 ]; then
  RATIO=$(echo "scale=2; $PYTHON_MS / $JULIA_MS" | bc)
  echo "  Python / Julia = ${RATIO}x"
fi
echo ""
