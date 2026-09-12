#!/usr/bin/env python3
"""Exact preparation checks, not an Octave implementation or acceptance run.

Uses only Python's standard library. Integer/Fraction identities are exact.
Toy correctly-rounded binary arithmetic checks corroborate, but do not replace,
the proof or the required source audit of the actual MPFR binding.
"""
from __future__ import annotations

import argparse
import json
import math
from fractions import Fraction as F
from pathlib import Path
from typing import Any

Matrix = list[list[Any]]


def pow2(e: int) -> F:
    return F(2**e) if e >= 0 else F(1, 2**(-e))


def ceil_log2(n: int) -> int:
    if n < 1:
        raise ValueError("Positive integer required")
    return (n - 1).bit_length()


def transpose(a: Matrix) -> Matrix:
    return [list(x) for x in zip(*a)]


def mm(a: Matrix, b: Matrix) -> Matrix:
    bt = transpose(b)
    return [[sum(x * y for x, y in zip(row, col)) for col in bt] for row in a]


def identity(n: int) -> Matrix:
    return [[int(i == j) for j in range(n)] for i in range(n)]


def hadamard(n: int) -> Matrix:
    if n < 1 or n & (n - 1):
        raise ValueError("Power-of-two size required")
    h = [[1]]
    while len(h) < n:
        h = [r + r for r in h] + [r + [-v for v in r] for r in h]
    return h


def js(n: int) -> Matrix:
    a = [[0] * n for _ in range(n)]
    a[0][0] = 1
    for i in range(1, n):
        for j in range(1, i + 1):
            a[i][j] = a[i - 1][j - 1] + j * (j + 1) * a[i - 1][j]
    return a


def lah(n: int) -> Matrix:
    a = [[0] * n for _ in range(n)]
    a[0][0] = 1
    for i in range(2, n + 1):
        for j in range(1, i + 1):
            left = a[i - 2][j - 2] if j > 1 else 0
            same = a[i - 2][j - 1]
            a[i - 1][j - 1] = left + (i + j - 1) * same
    return a


def det_exact(a: Matrix) -> F:
    b = [[F(x) for x in row] for row in a]
    d = F(1)
    n = len(b)
    for k in range(n):
        pivot = next((i for i in range(k, n) if b[i][k]), None)
        if pivot is None:
            return F(0)
        if pivot != k:
            b[k], b[pivot] = b[pivot], b[k]
            d = -d
        value = b[k][k]
        d *= value
        for i in range(k + 1, n):
            t = b[i][k] / value
            for j in range(k + 1, n):
                b[i][j] -= t * b[k][j]
            b[i][k] = F(0)
    return d


def min_bits(x: F) -> int:
    """Significand bits needed for an exact finite dyadic value."""
    x = F(x)
    if not x:
        return 0
    den = x.denominator
    if den & (den - 1):
        raise ValueError("Value is not dyadic")
    m = abs(x.numerator)
    while not m & 1:
        m >>= 1
    return m.bit_length()


def floor_log2(x: F) -> int:
    if x <= 0:
        raise ValueError("Positive value required")
    e = x.numerator.bit_length() - x.denominator.bit_length()
    return e - 1 if x < pow2(e) else e


def rn(x: F, bits: int) -> F:
    """Unbounded-exponent normalized binary RN, ties to even."""
    if not x:
        return F(0)
    sign = 1 if x > 0 else -1
    x = abs(x)
    scale = pow2(floor_log2(x) - bits + 1)
    y = x / scale
    k, rem = divmod(y.numerator, y.denominator)
    if 2 * rem > y.denominator or (2 * rem == y.denominator and k & 1):
        k += 1
    return sign * k * scale


def sqrt_rn(x: F, bits: int) -> F:
    if x < 0:
        raise ValueError("Nonnegative value required")
    if not x:
        return F(0)
    scale = pow2(floor_log2(x) // 2 - bits + 1)
    y = x / (scale * scale)
    k = math.isqrt(y.numerator // y.denominator)
    midpoint_squared = F((2 * k + 1)**2, 4)
    if y > midpoint_squared or (y == midpoint_squared and k & 1):
        k += 1
    return k * scale


def padded(r: F, bits: int) -> tuple[F, F]:
    if not r:
        return F(0), F(0)
    t = 8 * pow2(-bits) * abs(r)
    assert rn(t, bits) == t
    return rn(r - t, bits), rn(r + t, bits)


def case_budget(case: dict[str, Any]) -> int:
    p = case["parameters"]
    family = case["family"]
    n = p.get("n", p.get("m"))
    if family == "nro_block":
        return 2
    if family == "jacobi_stirling":
        return 3 + sum(ceil_log2(1 + r * (r + 1)) for r in range(1, n))
    if family == "lah":
        return 3 + sum(ceil_log2(2 * i) for i in range(2, n + 1))
    if family == "dd_path":
        return p["b"] + 2
    if family == "pascal":
        return n + 2 if p["representation"] == "lower" else 2 * n + 2
    if family == "vandermonde":
        return 2 + (n - 1) * ceil_log2(n)
    if family == "bidiagonal":
        return p["a"] * (n - 1) + 4
    if family == "lauchli":
        return 2
    if family == "hadamard_spectrum":
        if p["mode"] == "geometric":
            return p["a"] * (n - 1) + ceil_log2(n) + 2
        return p.get("b", 4) + ceil_log2(n) + 5
    if family == "nro_companion":
        return ceil_log2(p["nu"] + 1) + 3
    raise ValueError(f"Unknown family: {family}")


def run() -> dict[str, Any]:
    manifest_path = Path(__file__).resolve().parents[1] / "cases.json"
    manifest = json.loads(manifest_path.read_text())
    counts, budgets = {}, []
    for name, profile in manifest["profiles"].items():
        cases = profile["cases"]
        assert len({c["id"] for c in cases}) == len(cases)
        count = len(cases) * (len(profile["work_bits"]) + int(profile["native"])) * len(profile["modes"])
        assert count == profile["expected_svd_rows"]
        counts[name] = {"cases": len(cases), "svd_rows": count}
        for c in cases:
            guard = case_budget(c)
            below = [p for p in profile["work_bits"] if p < guard]
            assert not below or c["family"] == "dd_path", (name, c["id"], guard)
            assert profile["work_bits"][-1] >= guard
            budgets.append({"profile": name, "case": c["id"], "guard": guard,
                            "intentional_below_guard_bits": below})

    for n in [1, 2, 4, 8, 16, 32]:
        h = hadamard(n)
        assert mm(h, transpose(h)) == [[n * x for x in row] for row in identity(n)]
    h = hadamard(16)
    b = [[(2**40) * v for v in row] for row in h]
    a = [identity(16)[i] + b[i] for i in range(16)] + [[0] * 16 + identity(16)[i] for i in range(16)]
    inv = [identity(16)[i] + [-v for v in b[i]] for i in range(16)] + [[0] * 16 + identity(16)[i] for i in range(16)]
    assert mm(a, inv) == identity(32) == mm(inv, a)
    assert all(F.from_float(float(x)) == x for row in a for x in row)

    assert js(5) == [[1, 0, 0, 0, 0], [0, 1, 0, 0, 0], [0, 2, 1, 0, 0],
                     [0, 4, 8, 1, 0], [0, 8, 52, 20, 1]]
    integer_bits = []
    for n in [8, 16, 20, 24, 32]:
        j, l = js(n), lah(n)
        for i in range(1, n + 1):
            for k in range(1, i + 1):
                assert l[i - 1][k - 1] == math.comb(i - 1, k - 1) * math.factorial(i) // math.factorial(k)
        q = [[math.comb(i, k) if k <= i else 0 for k in range(n)] for i in range(n)]
        p = [[math.comb(i + k, i) for k in range(n)] for i in range(n)]
        assert mm(q, transpose(q)) == p
        integer_bits.append({"n": n, "js_max_integer_bits": max(x.bit_length() for row in j for x in row),
                             "lah_max_integer_bits": max(x.bit_length() for row in l for x in row),
                             "pascal_symmetric_max_integer_bits": max(x.bit_length() for row in p for x in row)})

    published_c = [[1, -6, 7, -9], [1, -5, 0, 0], [0, 1, -5, 0], [0, 0, 1, -5]]
    published_x = [[125, -124, 130, -225], [25, -25, 26, -45], [5, -5, 5, -9], [1, -1, 1, -2]]
    assert mm(published_c, published_x) == identity(4) == mm(published_x, published_c)
    for n, nu in [(2, 2), (3, 3), (8, 16), (16, 256), (32, 256)]:
        k = [(-1)**i for i in range(n - 1)] + [1]
        first = [k[0]] + [k[i] - nu * k[i - 1] for i in range(1, n)]
        c = [first] + [[int(j == i - 1) - nu * int(j == i) for j in range(n)] for i in range(1, n)]
        horner = first[0]
        for t in first[1:]:
            horner = nu * horner + t
        assert horner == 1
        assert max(abs(x) for row in c for x in row) <= nu + 1
        assert det_exact(c) == (-1)**(n - 1)

    for rho in [F(1), F(1, 2)]:
        n = 8
        d = [[F(0)] * n for _ in range(n)]
        d[0][0] = 1
        d[0][1] = -1
        for i in range(1, n - 1):
            d[i][i - 1], d[i][i], d[i][i + 1] = -rho, 1 + rho, -1
        d[-1][-2], d[-1][-1] = -rho, rho
        assert all(sum(row) == 0 for row in d)
        assert det_exact(d) == 0
        assert all(det_exact([row[:k] for row in d[:k]]) == 1 for k in range(1, n))
        for i in range(n):
            shifted = d[i][i] + pow2(-160)
            assert F.from_float(float(shifted)) == d[i][i]
            assert rn(shifted, 128) == d[i][i]
            assert rn(shifted, 256) == shifted

    # Exact dyadic significand requirement in the dense geometric demo.
    n, step = 16, 8
    h = hadamard(n)
    g = h[-1:] + h[:-1]
    hdiag = [[F(v) * pow2(-step * j) for j, v in enumerate(row)] for row in h]
    mixed = [[x / n for x in row] for row in mm(hdiag, transpose(g))]
    max_mixed_bits = max(min_bits(x) for row in mixed for x in row)
    assert max_mixed_bits <= step * (n - 1) + ceil_log2(n) + 2 <= 128

    arithmetic_checks = 0
    for bits in [8, 16, 64, 128]:
        for a0 in range(1, 13):
            for b0 in range(1, 10):
                for e in [-100, -7, 0, 53]:
                    value = F(a0, b0) * pow2(e)
                    for z in [value, -value]:
                        lo, hi = padded(rn(z, bits), bits)
                        assert lo <= z <= hi
                        arithmetic_checks += 1
                    r = sqrt_rn(value, bits)
                    lo, hi = padded(r, bits)
                    assert 0 <= lo and lo * lo <= value <= hi * hi
                    arithmetic_checks += 1

    return {"status": "PASS", "scope": "Exact Python mathematical preparation checks only",
            "octave_executed": False, "backend_rounding_contract_audited": False,
            "paper_algorithm_reproduction": False,
            "profile_counts": counts, "guard_checks": budgets,
            "integer_bit_lengths": integer_bits,
            "nro_native_input_exact": True, "published_inverse_identity_exact": True,
            "dd_tau_loss_and_rank_checks": True, "geometric_demo_actual_significand_bits": max_mixed_bits,
            "toy_rn_enclosure_checks": arithmetic_checks,
            "notes": ["Rational/integer identities are exact.",
                      "Toy RN checks corroborate the algebra; the general proof remains in VERIFICATION.md.",
                      "No tests here demonstrate actual Octave execution or library rounding behavior."]}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="Optional new JSON output path; existing files are not replaced")
    args = parser.parse_args()
    result = run()
    text = json.dumps(result, indent=2) + "\n"
    if args.output:
        with args.output.open("x", encoding="utf-8") as f:
            f.write(text)
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
