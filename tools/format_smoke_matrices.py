#!/usr/bin/env python3
"""Format exact generator output as readable GitHub Math matrix blocks."""

from __future__ import annotations

import argparse
from fractions import Fraction
from pathlib import Path


Scalar = tuple[Fraction, Fraction]


def value_from_record(sign: int, mantissa_hex: str, exponent: int) -> Fraction:
    if sign == 0:
        return Fraction(0)
    value = Fraction(int(mantissa_hex, 16))
    if exponent >= 0:
        value *= 2**exponent
    else:
        value /= 2**(-exponent)
    return value if sign > 0 else -value


def load_records(path: Path):
    records = {}
    metadata = {}
    with path.open(encoding="utf-8") as stream:
        for raw in stream:
            if not raw.strip() or raw.startswith("#"):
                continue
            fields = raw.rstrip("\n").split("\t")
            if len(fields) != 10:
                raise ValueError(f"malformed record: {raw.rstrip()}")
            case_id, doc, rows, columns, row, column, kind, sign, mantissa, exponent = fields
            key = (case_id, int(row), int(column))
            metadata.setdefault(case_id, (doc, int(rows), int(columns)))
            value = value_from_record(int(sign), mantissa, int(exponent))
            if kind == "real":
                records[key] = (value, Fraction(0))
            elif kind == "complex-real":
                previous = records.get(key, (Fraction(0), Fraction(0)))
                records[key] = (value, previous[1])
            elif kind == "complex-imag":
                previous = records.get(key, (Fraction(0), Fraction(0)))
                records[key] = (previous[0], value)
            else:
                raise ValueError(f"unknown record kind {kind!r}")
    return metadata, records


def fraction_text(value: Fraction) -> str:
    if value.denominator == 1:
        return str(value.numerator)
    if value.numerator == 1 and value.denominator & (value.denominator - 1) == 0:
        return f"2^{{-{value.denominator.bit_length() - 1}}}"
    if value.numerator == -1 and value.denominator & (value.denominator - 1) == 0:
        return f"-2^{{-{value.denominator.bit_length() - 1}}}"
    return rf"\frac{{{value.numerator}}}{{{value.denominator}}}"


def scalar_text(value: Scalar) -> str:
    real, imag = value
    if imag == 0:
        return fraction_text(real)
    if real == 0:
        unit = fraction_text(abs(imag))
        return f"{'-' if imag < 0 else ''}{unit}i"
    sign = "+" if imag > 0 else "-"
    return f"{fraction_text(real)}{sign}{fraction_text(abs(imag))}i"


def common_power_of_two(values) -> int:
    denominator_exponents = []
    for value in values:
        for part in value:
            if part:
                denominator = part.denominator
                if denominator & (denominator - 1):
                    return 0
                denominator_exponents.append(denominator.bit_length() - 1)
    return max(denominator_exponents, default=0)


def matrix_block(case_id: str, rows: int, columns: int, values) -> str:
    flat = [values[(row, column)] for row in range(1, rows + 1)
            for column in range(1, columns + 1)]
    factor_power = common_power_of_two(flat)
    nonzero = sum(any(part for part in value) for value in flat)
    if factor_power and nonzero < max(8, rows * columns // 2):
        factor_power = 0
    factor = 2**factor_power
    entries = []
    for row in range(1, rows + 1):
        rendered = []
        for column in range(1, columns + 1):
            value = values[(row, column)]
            if factor_power:
                value = (value[0] * factor, value[1] * factor)
            rendered.append(scalar_text(value))
        entries.append(" & ".join(rendered))
    body = " \\\\\n".join(entries)
    prefix = f"2^{{-{factor_power}}} " if factor_power else ""
    return (
        f"<!-- smoke-matrix: {case_id} -->\n"
        "```math\n"
        f"A_{{\\mathrm{{smoke}}}} = {prefix}\\begin{{bmatrix}}\n"
        f"{body}\n"
        "\\end{bmatrix}.\n"
        "```\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("records", type=Path)
    args = parser.parse_args()
    metadata, records = load_records(args.records)
    for case_id, (doc, rows, columns) in metadata.items():
        values = {(row, column): records[(case_id, row, column)]
                  for row in range(1, rows + 1)
                  for column in range(1, columns + 1)}
        print(f"===== {doc} =====")
        print(matrix_block(case_id, rows, columns, values), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
