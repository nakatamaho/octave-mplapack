#!/usr/bin/env python3
"""Independent exact-rational preparation checks; not Octave/MPLAPACK tests."""
from __future__ import annotations
import argparse
from fractions import Fraction as F
import hashlib
import json
from math import isqrt
from pathlib import Path


def p2(e: int) -> F:
    return F(2 ** e) if e >= 0 else F(1, 2 ** (-e))


def floor_log2(x: F) -> int:
    if x <= 0:
        raise ValueError("Expected a positive rational")
    e = x.numerator.bit_length() - x.denominator.bit_length()
    return e - 1 if x < p2(e) else e


def rn(x: F, bits: int) -> F:
    """Exact model of binary round-to-nearest, ties-to-even, unbounded exponent."""
    x = F(x)
    if not x:
        return F(0)
    sign = 1 if x > 0 else -1
    x = abs(x)
    step = p2(floor_log2(x) - bits + 1)
    y = x / step
    k, rem = divmod(y.numerator, y.denominator)
    if 2 * rem > y.denominator or (2 * rem == y.denominator and k % 2):
        k += 1
    return sign * k * step


def rn_sqrt(x: F, bits: int) -> F:
    if x < 0:
        raise ValueError("Negative square root")
    if not x:
        return F(0)
    step = p2(floor_log2(x) // 2 - bits + 1)
    y = x / (step * step)
    k = isqrt(y.numerator // y.denominator)
    midpoint2 = F((2 * k + 1) ** 2, 4)
    if y > midpoint2 or (y == midpoint2 and k % 2):
        k += 1
    return k * step


def eye(n: int):
    return [[F(i == j) for j in range(n)] for i in range(n)]


def zeros(m: int, n: int | None = None):
    return [[F(0) for _ in range(m if n is None else n)] for _ in range(m)]


def mm(a, b, bits: int | None = None):
    out = zeros(len(a), len(b[0]))
    for i in range(len(a)):
        for j in range(len(b[0])):
            s = F(0)
            for k in range(len(b)):
                t = a[i][k] * b[k][j]
                if bits is not None:
                    t = rn(t, bits)
                s = s + t
                if bits is not None:
                    s = rn(s, bits)
            out[i][j] = s
    return out


def add(a, b):
    return [[x + y for x, y in zip(ar, br)] for ar, br in zip(a, b)]


def scale(a, s):
    return [[s * x for x in row] for row in a]


def transpose(a):
    return [list(row) for row in zip(*a)]


def inverse(a):
    n = len(a)
    b = [list(a[i]) + eye(n)[i] for i in range(n)]
    for j in range(n):
        pivot = next((i for i in range(j, n) if b[i][j]), None)
        if pivot is None:
            raise ValueError("Singular matrix")
        b[j], b[pivot] = b[pivot], b[j]
        t = b[j][j]
        b[j] = [x / t for x in b[j]]
        for i in range(n):
            if i != j:
                t = b[i][j]
                b[i] = [x - t * y for x, y in zip(b[i], b[j])]
    return [row[n:] for row in b]


def det(a):
    b = [list(row) for row in a]
    n, result = len(b), F(1)
    for j in range(n):
        pivot = next((i for i in range(j, n) if b[i][j]), None)
        if pivot is None:
            return F(0)
        if pivot != j:
            b[j], b[pivot] = b[pivot], b[j]
            result = -result
        t = b[j][j]
        result *= t
        for i in range(j + 1, n):
            ratio = b[i][j] / t
            for k in range(j + 1, n):
                b[i][k] -= ratio * b[j][k]
    return result


def last_bit(x: F) -> F:
    if not x:
        return F(0)
    x = abs(x)
    assert x.denominator & (x.denominator - 1) == 0
    n = x.numerator
    return F(n & -n, x.denominator)


def similarity_pair(n: int):
    l, u = eye(n), eye(n)
    for i in range(n - 1):
        l[i + 1][i] = u[i][i + 1] = F(1)
    x = mm(l, u)
    y = mm(inverse(u), inverse(l))
    assert mm(x, y) == mm(y, x) == eye(n)
    return x, y


def oo(n: int, kind: str, bits: int):
    x, y = similarity_pair(n)
    s = zeros(n)
    if kind == "real":
        for i in range(n):
            s[i][i] = F(i + 1) + p2(-45)
            if i + 1 < n:
                s[i][i + 1] = F(32)
    elif kind == "pair":
        for j in range(n // 2):
            a, b = F(2 * j + 1) + p2(-45), F(2 * j + 1, 8) + p2(-45)
            i = 2 * j
            s[i][i] = s[i + 1][i + 1] = a
            s[i][i + 1], s[i + 1][i] = b, -b
            if i + 2 < n:
                s[i][i + 2] = s[i + 1][i + 3] = F(8)
    elif kind == "close":
        for i in range(n):
            s[i][i] = F(i + 1)
        s[0][0] = F(1)
        s[1][1] = F(1) + p2(-80) + p2(-120)
        for i in range(n - 1):
            s[i][i + 1] = F(1)
    else:
        raise ValueError(kind)
    assert all(rn(t, bits) == t for row in s for t in row)
    phi, psi = [[last_bit(v) for v in row] for row in x], [[last_bit(v) for v in row] for row in y]
    beta = max(v / min(w for w in col if w) for col in transpose(phi) for v in col if v)
    gamma = max(p2(floor_log2(abs(x[i][j]))) / phi[i][j] for i in range(n) for j in range(n) if phi[i][j])
    theta = max(v / min(w for w in row if w) for row in psi for v in row if v)
    omega = max(p2(floor_log2(abs(y[i][j]))) / psi[i][j] for i in range(n) for j in range(n) if psi[i][j])
    ny = max(sum(bool(t) for t in row) for row in y)
    ns = max(sum(bool(t) for t in row) for row in s)
    nx = max(sum(bool(t) for t in col) for col in transpose(x))
    nd = min(ns, nx)
    v = ny * nd * max(abs(t) for row in s for t in row)
    alpha = p2(floor_log2(v))
    if alpha < v:
        alpha *= 2
    product = beta * gamma * theta * omega
    assert 4 * ny * nd * p2(-bits) * product <= 1
    sigma = 12 * alpha * product
    assert rn(sigma, bits) == sigma
    sp = [[rn(rn(sigma + t, bits) - sigma, bits) for t in row] for row in s]
    if kind == "pair":
        for j in range(n // 2):
            i = 2 * j
            sp[i + 1][i] = -sp[i][i + 1]
            assert sp[i][i] == sp[i + 1][i + 1]
    ax = mm(sp, x, bits)
    a = mm(y, ax, bits)
    assert ax == mm(sp, x)
    assert a == mm(y, mm(sp, x))
    assert all(rn(t, bits) == t for row in a for t in row)
    assert a != transpose(a)
    assert any(a[i][j] for i in range(n) for j in range(i))
    assert any(a[i][j] for i in range(n) for j in range(i + 1, n))
    changed = sum(t != z for r, zrow in zip(s, sp) for t, z in zip(r, zrow))
    assert changed > 0
    if kind == "close":
        assert sp[1][1] - sp[0][0] == p2(-80)
    raw = json.dumps([[str(t) for t in row] for row in a], separators=(",", ":"))
    return {"n": n, "kind": kind, "generation_bits": bits, "changed_entries": changed,
            "beta_gamma_theta_omega": str(product), "sigma": str(sigma),
            "exact_rational_matrix_sha256": hashlib.sha256(raw.encode()).hexdigest()}


def poly_eval(c, z):
    r = F(0)
    for x in c:
        r = r * z + x
    return r


def mks_checks():
    count = 0
    for n in range(3, 10):
        for m in range(1, n + 1):
            d = F(1, 8)
            a = [[d + F(j - i == m) for j in range(n)] for i in range(n)]
            length = (n - 1) // m + 1
            c = [F(1)] + [-d * (n - m * j) for j in range(length)]
            # Monic coefficients are in descending powers.
            for z in (F(-2), F(0), F(1), F(3)):
                lhs = det([[z * F(i == j) - a[i][j] for j in range(n)] for i in range(n)])
                assert lhs == z ** (n - length) * poly_eval(c, z)
                count += 1
    return count


def markov(n, aexp):
    m, eps = n // 2, p2(-aexp)
    q = zeros(n)
    for b, a in enumerate((F(1, 4), F(1, 8))):
        for j in range(m):
            i = b * m + j
            q[i][i] += 1 - a
            q[i][b * m + (j + 1) % m] += a
    r = [p2(-j) for j in range(1, n)] + [p2(-(n - 1))]
    assert sum(r) == 1
    p = [[(1 - eps) * q[i][j] + eps * r[j] for j in range(n)] for i in range(n)]
    assert all(sum(row) == 1 and all(t > 0 for t in row) for row in p)
    ident = eye(n)
    fundamental = inverse(add(ident, scale(q, -(1 - eps))))
    stationary = scale(mm([r], fundamental), eps)[0]
    assert sum(stationary) == 1 and all(t > 0 for t in stationary)
    assert mm([stationary], p) == [stationary]
    assert stationary != r
    for z in (F(-1), F(0), F(2), F(3)):
        target = (z - 1) * (z - (1 - eps))
        for a in (F(1, 4), F(1, 8)):
            num = (z - (1 - eps) * (1 - a)) ** m - ((1 - eps) * a) ** m
            target *= num / (z - (1 - eps))
        assert det([[z * F(i == j) - p[i][j] for j in range(n)] for i in range(n)]) == target
    return {"n": n, "epsilon_exponent": aexp, "strictly_positive": True,
            "row_stochastic_exactly": True, "stationary_vector_nontrivial": True}


def primitive_checks():
    total = 0
    for bits in (64, 128, 256):
        u = p2(-bits)
        vals = [F(0)] + [sign * F(k) * p2(e) for sign in (-1, 1)
                                     for k in (1, 3, 7)
                                     for e in (-1500, -50, 0, 50, 1500)]
        for a in vals:
            for b in vals:
                exacts = [a + b, a - b, a * b]
                if b:
                    exacts.append(a / b)
                for z in exacts:
                    r = rn(z, bits)
                    if r:
                        t = 8 * u * abs(r)
                        lo, hi = rn(r - t, bits), rn(r + t, bits)
                    else:
                        assert z == 0
                        lo = hi = F(0)
                    assert lo <= z <= hi
                    total += 1
        for a in (F(0), F(1), F(2), F(3), F(1, 3), p2(-3000), p2(3000)):
            r = rn_sqrt(a, bits)
            t = 8 * u * abs(r)
            lo, hi = rn(r - t, bits), rn(r + t, bits)
            lo = max(lo, F(0))
            assert lo * lo <= a <= hi * hi
            total += 1
    return total


def graph_checks():
    # k=m=1: C=[[1,1/4],[2^-20,3]], K=2, R=1/2.
    c, e, g, t = p2(-21), F(0), F(1, 8), p2(-19)
    assert c + e * t + g * t * t < t
    assert e + 2 * g * t < 1
    f = lambda z: p2(-20) + 2 * z - z * z / 4
    assert f(-t) < 0 < f(t)
    # Inverse identities used by the fixed-pencil and similarity checkers.
    a = [[F(2), F(1)], [F(1, 8), F(3)]]
    x = [[F(1), F(1, 4)], [F(0), F(1)]]
    t0 = mm(inverse(x), mm(a, x))
    assert mm(a, x) == mm(x, t0)
    b = [[F(1), F(1)], [F(0), F(1)]]
    ap = mm(b, a)
    assert mm(inverse(b), ap) == a
    return {"riccati_self_map_strict": True, "riccati_contraction_strict": True,
            "similarity_and_pencil_identities": True}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = {
        "schema": "neigt-preparation-v1", "kind": "exact_rational_math_checks",
        "octave_executed": False, "mplapack_executed": False,
        "oo_checks": [oo(n, k, p) for n in (8, 16) for k, p in
                      (("real", 53), ("pair", 53), ("close", 128))],
        "mks_characteristic_evaluations": mks_checks(),
        "markov_checks": [markov(8, 24), markov(16, 80)],
        "outward_primitive_checks": primitive_checks(),
        "graph_checks": graph_checks(),
        "status": "PASS_PREPARATION_ONLY"
    }
    text = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text, encoding="utf-8")
    else:
        print(text, end="")

if __name__ == "__main__":
    main()
