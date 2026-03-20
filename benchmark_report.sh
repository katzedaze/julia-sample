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

# [TIME] タグからセクション別タイムを抽出する関数
extract_time() {
  local output="$1" label="$2"
  echo "$output" | grep -F "[TIME] $label:" | grep -oP '[0-9.]+(?= ms)' || echo "N/A"
}

# セクション別タイム抽出
sections=("図形と多重ディスパッチ:図形と多態性" "配列操作:配列操作" "統計計算:統計計算" "フィボナッチ:フィボナッチ" "行列演算 (3×3):行列演算 (3×3)" "行列演算 (500×500):行列演算 (500×500)")

declare -A julia_times python_times

for entry in "${sections[@]}"; do
  jlabel="${entry%%:*}"
  pylabel="${entry##*:}"
  julia_times["$jlabel"]=$(extract_time "$JULIA_OUT" "$jlabel")
  python_times["$pylabel"]=$(extract_time "$PYTHON_OUT" "$pylabel")
done

# フィボナッチ内訳
julia_fib_naive=$(echo "$JULIA_OUT" | grep "素朴な再帰" | grep -oP '\[\K[0-9.]+')
julia_fib_memo=$(echo "$JULIA_OUT" | grep "メモ化" | grep -oP '\[\K[0-9.]+')
julia_fib_iter=$(echo "$JULIA_OUT" | grep "反復" | grep -oP '\[\K[0-9.]+')

python_fib_naive=$(echo "$PYTHON_OUT" | grep "素朴な再帰" | grep -oP '\[\K[0-9.]+')
python_fib_memo=$(echo "$PYTHON_OUT" | grep "メモ化" | grep -oP '\[\K[0-9.]+')
python_fib_iter=$(echo "$PYTHON_OUT" | grep "反復" | grep -oP '\[\K[0-9.]+')

# バージョン
julia_ver=$(julia --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')
python_ver=$(python3 --version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

# 倍率計算関数
calc_ratio() {
  local julia_val="$1" python_val="$2"
  if [ "$julia_val" = "N/A" ] || [ "$python_val" = "N/A" ] || [ "$julia_val" = "0" ] || [ "$julia_val" = "0.0" ]; then
    echo "-"
  else
    echo "scale=1; $python_val / $julia_val" | bc 2>/dev/null || echo "-"
  fi
}

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
> 各セクションの計測は JIT ウォームアップ後に行っています。

## セクション別実行時間

| セクション | Julia | Python | 倍率 (Python/Julia) |
|---|---|---|---|
| 図形 (多重ディスパッチ/多態性) | ${julia_times["図形と多重ディスパッチ"]} ms | ${python_times["図形と多態性"]} ms | $(calc_ratio "${julia_times["図形と多重ディスパッチ"]}" "${python_times["図形と多態性"]}")x |
| 配列操作 | ${julia_times["配列操作"]} ms | ${python_times["配列操作"]} ms | $(calc_ratio "${julia_times["配列操作"]}" "${python_times["配列操作"]}")x |
| 統計計算 | ${julia_times["統計計算"]} ms | ${python_times["統計計算"]} ms | $(calc_ratio "${julia_times["統計計算"]}" "${python_times["統計計算"]}")x |
| フィボナッチ (全体) | ${julia_times["フィボナッチ"]} ms | ${python_times["フィボナッチ"]} ms | $(calc_ratio "${julia_times["フィボナッチ"]}" "${python_times["フィボナッチ"]}")x |
| 行列演算 (3×3) | ${julia_times["行列演算 (3×3)"]} ms | ${python_times["行列演算 (3×3)"]} ms | $(calc_ratio "${julia_times["行列演算 (3×3)"]}" "${python_times["行列演算 (3×3)"]}")x |
| 行列演算 (500×500) | ${julia_times["行列演算 (500×500)"]} ms | ${python_times["行列演算 (500×500)"]} ms | $(calc_ratio "${julia_times["行列演算 (500×500)"]}" "${python_times["行列演算 (500×500)"]}")x |

## フィボナッチ内訳

| アルゴリズム | Julia | Python | 倍率 (Python/Julia) |
|---|---|---|---|
| 素朴な再帰 (n=30) | ${julia_fib_naive} ms | ${python_fib_naive} ms | $(calc_ratio "$julia_fib_naive" "$python_fib_naive")x |
| メモ化 (n=50) | ${julia_fib_memo} ms | ${python_fib_memo} ms | $(calc_ratio "$julia_fib_memo" "$python_fib_memo")x |
| 反復 (n=50) | ${julia_fib_iter} ms | ${python_fib_iter} ms | $(calc_ratio "$julia_fib_iter" "$python_fib_iter")x |

## 考察

- **総実行時間**: Julia は JIT コンパイルにより短いスクリプトでは起動が遅い
- **計算本体**: JIT ウォームアップ後は Julia が Python より高速（特に再帰・ループ処理）
- **軽量処理**: 配列操作や統計計算など軽い処理では両言語の差は小さい
- **Julia の真価**: 大規模な数値計算・ループ処理・科学技術計算で発揮される

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
