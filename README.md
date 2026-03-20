# Julia vs Python サンプルプログラム

Julia と Python で同じ処理を実装し、パフォーマンスを比較するプロジェクト。

## 必要環境

- Julia 1.12+
- Python 3.10+

## ファイル構成

```
julia-sample/
├── src/
│   ├── main.jl          # Julia 版
│   └── main.py          # Python 版
├── benchmark.sh          # 両言語を実行して結果を表示
├── benchmark_report.sh   # ベンチマーク結果を BENCHMARK.md に出力
├── BENCHMARK.md          # ベンチマーク結果レポート
└── README.md
```

## 実行方法

### 個別実行

```bash
julia src/main.jl
python3 src/main.py
```

### ベンチマーク比較（ターミナル表示）

```bash
bash benchmark.sh
```

### ベンチマークレポート生成

```bash
bash benchmark_report.sh
```

実行後、`BENCHMARK.md` にレポートが出力されます。

## デモ内容

| セクション | 概要 | Julia の機能 | Python の機能 |
|---|---|---|---|
| 多重ディスパッチ / 多態性 | 図形ごとの面積・周囲長計算 | 抽象型、構造体、多重ディスパッチ | ABC、クラス継承 |
| 配列操作 | データ変換・フィルタリング | ブロードキャスト、`do` 構文 | リスト内包表記 |
| 統計計算 | 基本統計量の算出 | NamedTuple | dict |
| ベンチマーク | フィボナッチ比較 | `@elapsed` | `time.perf_counter` |
| 行列演算 | 線形代数の基本操作 | 組み込み行列演算、SVD | 手実装 |

## ベンチマーク結果

詳細は [BENCHMARK.md](BENCHMARK.md) を参照。

### サマリー

| 指標 | Julia | Python | 備考 |
|---|---|---|---|
| 総実行時間 | ~1900 ms | ~44 ms | Julia は JIT コンパイルのオーバーヘッドを含む |
| fib_naive(30) | ~2.7 ms | ~35 ms | **Julia が約 13 倍高速** |
| メモ化 / 反復 | ≈ 0 ms | ≈ 0 ms | 両言語とも十分高速 |

### ポイント

- **総実行時間**: Julia は JIT コンパイルにより短いスクリプトでは Python より遅く見える
- **計算本体**: 素朴な再帰フィボナッチでは Julia が Python の約 13 倍高速
- Julia の真価は大規模な数値計算・ループ処理で発揮される
