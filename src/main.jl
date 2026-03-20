"""
Julia サンプルプログラム
- 多重ディスパッチ (Multiple Dispatch)
- 型システム
- 配列操作・ブロードキャスト
- 統計計算
- ベンチマーク
"""

# ============================================================
# 1. 抽象型と多重ディスパッチ
# ============================================================

abstract type Shape end

struct Circle <: Shape
    radius::Float64
end

struct Rectangle <: Shape
    width::Float64
    height::Float64
end

struct Triangle <: Shape
    base::Float64
    height::Float64
end

# 多重ディスパッチ: 型ごとに面積計算を定義
area(c::Circle) = π * c.radius^2
area(r::Rectangle) = r.width * r.height
area(t::Triangle) = 0.5 * t.base * t.height

# 多重ディスパッチ: 型ごとに周囲長を定義
perimeter(c::Circle) = 2π * c.radius
perimeter(r::Rectangle) = 2 * (r.width + r.height)
perimeter(t::Triangle) = t.base + t.height + √(t.base^2 + t.height^2)

function describe(s::Shape)
    type_name = typeof(s) |> string
    println("  $(type_name): 面積 = $(round(area(s), digits=2)), 周囲長 = $(round(perimeter(s), digits=2))")
end

# ============================================================
# 2. 配列操作とブロードキャスト
# ============================================================

function demo_array_operations()
    println("\n--- 配列操作 ---")

    # 内包表記で配列生成
    squares = [x^2 for x in 1:10]
    println("  1〜10 の二乗: $squares")

    # ブロードキャスト (dot syntax)
    data = [1.0, 4.0, 9.0, 16.0, 25.0]
    sqrt_data = sqrt.(data)
    println("  平方根 (broadcast): $sqrt_data")

    # フィルタリング
    evens = filter(iseven, 1:20)
    println("  偶数 (1〜20): $evens")

    # map + do 構文
    results = map(1:5) do x
        x^3 + 2x - 1
    end
    println("  f(x) = x³ + 2x - 1: $results")
end

# ============================================================
# 3. 統計計算
# ============================================================

function statistics(data::Vector{<:Real})
    n = length(data)
    μ = sum(data) / n
    σ² = sum((x - μ)^2 for x in data) / n
    σ = √σ²
    sorted = sort(data)
    median_val = if isodd(n)
        sorted[div(n, 2) + 1]
    else
        (sorted[div(n, 2)] + sorted[div(n, 2) + 1]) / 2
    end

    (mean=μ, variance=σ², std=σ, median=median_val, min=minimum(data), max=maximum(data))
end

function demo_statistics()
    println("\n--- 統計計算 ---")

    data = [23.1, 45.7, 12.3, 67.8, 34.5, 56.2, 78.9, 41.0, 29.4, 53.6]
    println("  データ: $data")

    stats = statistics(data)
    println("  平均:   $(round(stats.mean, digits=2))")
    println("  分散:   $(round(stats.variance, digits=2))")
    println("  標準偏差: $(round(stats.std, digits=2))")
    println("  中央値:  $(stats.median)")
    println("  最小値:  $(stats.min)")
    println("  最大値:  $(stats.max)")
end

# ============================================================
# 4. フィボナッチ (メモ化 vs 再帰) ベンチマーク
# ============================================================

# 素朴な再帰
function fib_naive(n::Int)
    n ≤ 1 && return n
    fib_naive(n - 1) + fib_naive(n - 2)
end

# メモ化
function fib_memo(n::Int, cache::Dict{Int,Int}=Dict{Int,Int}())
    n ≤ 1 && return n
    haskey(cache, n) && return cache[n]
    cache[n] = fib_memo(n - 1, cache) + fib_memo(n - 2, cache)
end

# 反復
function fib_iter(n::Int)
    n ≤ 1 && return n
    a, b = 0, 1
    for _ in 2:n
        a, b = b, a + b
    end
    b
end

function demo_benchmark()
    println("\n--- フィボナッチ ベンチマーク ---")

    n_small = 30
    n_large = 50

    # ウォームアップ (JIT コンパイル)
    fib_naive(10)
    fib_memo(10)
    fib_iter(10)

    # 素朴な再帰 (n=30)
    t1 = @elapsed result1 = fib_naive(n_small)
    println("  素朴な再帰  (n=$n_small): $result1  [$(round(t1 * 1000, digits=3)) ms]")

    # メモ化 (n=50)
    t2 = @elapsed result2 = fib_memo(n_large)
    println("  メモ化     (n=$n_large): $result2  [$(round(t2 * 1000, digits=3)) ms]")

    # 反復 (n=50)
    t3 = @elapsed result3 = fib_iter(n_large)
    println("  反復       (n=$n_large): $result3  [$(round(t3 * 1000, digits=3)) ms]")
end

# ============================================================
# 5. 行列演算
# ============================================================

function demo_matrix()
    println("\n--- 行列演算 ---")

    A = [1 2 3; 4 5 6; 7 8 9]
    B = [9 8 7; 6 5 4; 3 2 1]

    println("  A = $A")
    println("  B = $B")
    println("  A × B = $(A * B)")
    println("  A' (転置) = $(A')")
    println("  tr(A) (トレース) = $(sum(A[i, i] for i in 1:3))")
    println("  det に近い特異値: ", let F = svd(A); round.(F.S, digits=3); end)
end

# ============================================================
# メイン実行
# ============================================================

using LinearAlgebra: svd

function main()
    println("=" ^ 50)
    println(" Julia サンプルプログラム (v$(VERSION))")
    println("=" ^ 50)

    # 1. 多重ディスパッチ
    println("\n--- 図形と多重ディスパッチ ---")
    shapes = [Circle(5.0), Rectangle(4.0, 6.0), Triangle(3.0, 4.0)]
    for s in shapes
        describe(s)
    end

    # 2. 配列操作
    demo_array_operations()

    # 3. 統計計算
    demo_statistics()

    # 4. ベンチマーク
    demo_benchmark()

    # 5. 行列演算
    demo_matrix()

    println("\n" * "=" ^ 50)
    println(" 完了!")
    println("=" ^ 50)
end

main()
