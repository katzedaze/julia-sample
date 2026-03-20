"""
Python サンプルプログラム
- クラスと多態性 (Polymorphism)
- 型システム
- 配列操作
- 統計計算
- ベンチマーク
"""

import math
import time
from abc import ABC, abstractmethod

# ============================================================
# 1. 抽象クラスと多態性
# ============================================================

class Shape(ABC):
    @abstractmethod
    def area(self) -> float: ...

    @abstractmethod
    def perimeter(self) -> float: ...

    def describe(self):
        name = type(self).__name__
        print(f"  {name}: 面積 = {round(self.area(), 2)}, 周囲長 = {round(self.perimeter(), 2)}")


class Circle(Shape):
    def __init__(self, radius: float):
        self.radius = radius

    def area(self) -> float:
        return math.pi * self.radius ** 2

    def perimeter(self) -> float:
        return 2 * math.pi * self.radius


class Rectangle(Shape):
    def __init__(self, width: float, height: float):
        self.width = width
        self.height = height

    def area(self) -> float:
        return self.width * self.height

    def perimeter(self) -> float:
        return 2 * (self.width + self.height)


class Triangle(Shape):
    def __init__(self, base: float, height: float):
        self.base = base
        self.height = height

    def area(self) -> float:
        return 0.5 * self.base * self.height

    def perimeter(self) -> float:
        return self.base + self.height + math.sqrt(self.base ** 2 + self.height ** 2)


# ============================================================
# 2. 配列操作
# ============================================================

def demo_array_operations():
    print("\n--- 配列操作 ---")

    squares = [x ** 2 for x in range(1, 11)]
    print(f"  1〜10 の二乗: {squares}")

    data = [1.0, 4.0, 9.0, 16.0, 25.0]
    sqrt_data = [math.sqrt(x) for x in data]
    print(f"  平方根: {sqrt_data}")

    evens = [x for x in range(1, 21) if x % 2 == 0]
    print(f"  偶数 (1〜20): {evens}")

    results = [x ** 3 + 2 * x - 1 for x in range(1, 6)]
    print(f"  f(x) = x³ + 2x - 1: {results}")


# ============================================================
# 3. 統計計算
# ============================================================

def statistics(data: list[float]) -> dict:
    n = len(data)
    mean = sum(data) / n
    variance = sum((x - mean) ** 2 for x in data) / n
    std = math.sqrt(variance)
    sorted_data = sorted(data)
    if n % 2 == 1:
        median = sorted_data[n // 2]
    else:
        median = (sorted_data[n // 2 - 1] + sorted_data[n // 2]) / 2

    return {
        "mean": mean,
        "variance": variance,
        "std": std,
        "median": median,
        "min": min(data),
        "max": max(data),
    }


def demo_statistics():
    print("\n--- 統計計算 ---")

    data = [23.1, 45.7, 12.3, 67.8, 34.5, 56.2, 78.9, 41.0, 29.4, 53.6]
    print(f"  データ: {data}")

    stats = statistics(data)
    print(f"  平均:   {round(stats['mean'], 2)}")
    print(f"  分散:   {round(stats['variance'], 2)}")
    print(f"  標準偏差: {round(stats['std'], 2)}")
    print(f"  中央値:  {stats['median']}")
    print(f"  最小値:  {stats['min']}")
    print(f"  最大値:  {stats['max']}")


# ============================================================
# 4. フィボナッチ (メモ化 vs 再帰) ベンチマーク
# ============================================================

def fib_naive(n: int) -> int:
    if n <= 1:
        return n
    return fib_naive(n - 1) + fib_naive(n - 2)


def fib_memo(n: int, cache: dict[int, int] | None = None) -> int:
    if cache is None:
        cache = {}
    if n <= 1:
        return n
    if n in cache:
        return cache[n]
    cache[n] = fib_memo(n - 1, cache) + fib_memo(n - 2, cache)
    return cache[n]


def fib_iter(n: int) -> int:
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def demo_benchmark():
    print("\n--- フィボナッチ ベンチマーク ---")

    n_small = 30
    n_large = 50

    # ウォームアップ
    fib_naive(10)
    fib_memo(10)
    fib_iter(10)

    t1 = time.perf_counter()
    result1 = fib_naive(n_small)
    t1 = time.perf_counter() - t1
    print(f"  素朴な再帰  (n={n_small}): {result1}  [{round(t1 * 1000, 3)} ms]")

    t2 = time.perf_counter()
    result2 = fib_memo(n_large)
    t2 = time.perf_counter() - t2
    print(f"  メモ化     (n={n_large}): {result2}  [{round(t2 * 1000, 3)} ms]")

    t3 = time.perf_counter()
    result3 = fib_iter(n_large)
    t3 = time.perf_counter() - t3
    print(f"  反復       (n={n_large}): {result3}  [{round(t3 * 1000, 3)} ms]")


# ============================================================
# 5. 行列演算
# ============================================================

def mat_mul(a: list[list[int]], b: list[list[int]]) -> list[list[int]]:
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def mat_transpose(a: list[list[int]]) -> list[list[int]]:
    return [list(row) for row in zip(*a)]


def demo_matrix():
    print("\n--- 行列演算 ---")

    A = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    B = [[9, 8, 7], [6, 5, 4], [3, 2, 1]]

    print(f"  A = {A}")
    print(f"  B = {B}")
    print(f"  A × B = {mat_mul(A, B)}")
    print(f"  A' (転置) = {mat_transpose(A)}")
    print(f"  tr(A) (トレース) = {sum(A[i][i] for i in range(3))}")


# ============================================================
# メイン実行
# ============================================================

import sys

def main():
    version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    print("=" * 50)
    print(f" Python サンプルプログラム (v{version})")
    print("=" * 50)

    # 1. 多態性
    print("\n--- 図形と多態性 ---")
    shapes = [Circle(5.0), Rectangle(4.0, 6.0), Triangle(3.0, 4.0)]
    for s in shapes:
        s.describe()

    # 2. 配列操作
    demo_array_operations()

    # 3. 統計計算
    demo_statistics()

    # 4. ベンチマーク
    demo_benchmark()

    # 5. 行列演算
    demo_matrix()

    print("\n" + "=" * 50)
    print(" 完了!")
    print("=" * 50)


if __name__ == "__main__":
    main()
