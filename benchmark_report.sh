#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

OUTPUT="BENCHMARK.md"

# Julia 実行
START_J=$(date +%s%N)
JULIA_OUT=$(julia src/main.jl 2>&1)
END_J=$(date +%s%N)
JULIA_MS=$(( (END_J - START_J) / 1000000 ))

# Python 実行
START_P=$(date +%s%N)
PYTHON_OUT=$(python3 src/main.py 2>&1)
END_P=$(date +%s%N)
PYTHON_MS=$(( (END_P - START_P) / 1000000 ))

# フィボナッチのタイムを抽出
julia_fib_naive=$(echo "$JULIA_OUT" | grep "素朴な再帰" | grep -oP '\[\K[0-9.]+')
julia_fib_memo=$(echo "$JULIA_OUT" | grep "メモ化" | grep -oP '\[\K[0-9.]+')
julia_fib_iter=$(echo "$JULIA_OUT" | grep "反復" | grep -oP '\[\K[0-9.]+')

python_fib_naive=$(echo "$PYTHON_OUT" | grep "素朴な再帰" | grep -oP '\[\K[0-9.]+')
python_fib_memo=$(echo "$PYTHON_OUT" | grep "メモ化" | grep -oP '\[\K[0-9.]+')
python_fib_iter=$(echo "$PYTHON_OUT" | grep "反復" | grep -oP '\[\K[0-9.]+')

# Julia / Python バージョン
julia_ver=$(julia --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')
python_ver=$(python3 --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

# 倍率計算
if [ "$julia_fib_naive" != "0" ] && [ "$julia_fib_naive" != "0.0" ]; then
  fib_ratio=$(echo "scale=1; $python_fib_naive / $julia_fib_naive" | bc)
else
  fib_ratio="N/A"
fi

if [ "$JULIA_MS" -gt 0 ]; then
  total_ratio=$(echo "scale=2; $PYTHON_MS * 1.0 / $JULIA_MS" | bc)
else
  total_ratio="N/A"
fi

# マークダウン出力
cat > "$OUTPUT" << EOF
# ベンチマーク結果

実行日時: $(date '+%Y-%m-%d %H:%M:%S')

## 環境

| 項目 | バージョン |
|---|---|
| Julia | $julia_ver |
| Python | $python_ver |
| OS | $(uname -sr) |

## 総実行時間

| 言語 | 時間 |
|---|---|
| Julia | ${JULIA_MS} ms |
| Python | ${PYTHON_MS} ms |

> Julia の総実行時間には JIT コンパイル（初回実行時のコード変換）のオーバーヘッドが含まれます。

## フィボナッチ ベンチマーク

| アルゴリズム | Julia | Python | 倍率 (Python/Julia) |
|---|---|---|---|
| 素朴な再帰 (n=30) | ${julia_fib_naive} ms | ${python_fib_naive} ms | ${fib_ratio}x |
| メモ化 (n=50) | ${julia_fib_memo} ms | ${python_fib_memo} ms | - |
| 反復 (n=50) | ${julia_fib_iter} ms | ${python_fib_iter} ms | - |

## 考察

- **総実行時間**: Julia は JIT コンパイルにより短いスクリプトでは Python より遅く見える
- **計算本体**: 素朴な再帰フィボナッチでは Julia が Python の約 ${fib_ratio} 倍高速
- **メモ化・反復**: 両言語とも十分高速で差はほぼない
- Julia の強みは大規模な数値計算やループ処理で発揮される

## 実行ログ

<details>
<summary>Julia 出力</summary>

\`\`\`
$JULIA_OUT
\`\`\`

</details>

<details>
<summary>Python 出力</summary>

\`\`\`
$PYTHON_OUT
\`\`\`

</details>
EOF

echo "ベンチマーク結果を $OUTPUT に出力しました"
