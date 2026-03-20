# Julia vs Python サンプルプログラム

Julia と Python で同じ処理を実装し、パフォーマンスを比較するプロジェクト。

## 必要環境

- Julia 1.12+
- Python 3.10+

## ファイル構成

```
julia-sample/
├── src/
│   ├── main.jl              # Julia 版
│   └── main.py              # Python 版
├── benchmark_report.sh       # ベンチマーク結果を BENCHMARK.md に出力
├── BENCHMARK.md              # ベンチマーク結果レポート
└── README.md
```

## 実行方法

### 個別実行

```bash
julia src/main.jl
python3 src/main.py
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
| フィボナッチ | アルゴリズム別速度比較 | `@elapsed` | `time.perf_counter` |
| 行列演算 (3×3) | 基本的な線形代数 | 組み込み行列演算 | 手実装 |
| 行列演算 (500×500) | 大規模行列の積・転置・SVD | BLAS/LAPACK | 手実装 (純 Python) |

## ベンチマーク結果

詳細は [BENCHMARK.md](BENCHMARK.md) を参照。

### セクション別実行時間

| セクション | Julia | Python | 倍率 (Python/Julia) |
|---|---|---|---|
| 図形 | 0.025 ms | 0.021 ms | ~1x |
| 配列操作 | 0.023 ms | 0.008 ms | ~1x |
| 統計計算 | 0.019 ms | 0.011 ms | ~1x |
| フィボナッチ | 2.4 ms | 34.8 ms | **14x Julia が高速** |
| 行列演算 (3×3) | 0.011 ms | 0.020 ms | ~2x |
| 行列演算 (500×500) | 107.9 ms | 5478.5 ms | **51x Julia が高速** |

### ポイント

- **軽量処理**: 配列操作・統計計算などではほぼ同等
- **再帰計算**: フィボナッチ素朴再帰で Julia が約 14 倍高速
- **大規模行列**: 500×500 の行列演算で Julia が約 51 倍高速 (BLAS/LAPACK の威力)
- **JIT オーバーヘッド**: Julia の総実行時間には JIT コンパイルの初期化コストが含まれる
