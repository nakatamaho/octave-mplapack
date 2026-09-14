#!/usr/bin/env python3
"""Compare committed GitHub Math smoke matrices with generator output."""

from __future__ import annotations

import argparse
import re
from fractions import Fraction
from pathlib import Path

from format_smoke_matrices import load_records


MATRIX_RE = re.compile(
    r"<!--\s*smoke-matrix:\s*(?P<case>[A-Za-z0-9_-]+)\s*-->\s*"
    r"```math\s*\n(?P<body>.*?)\n```\s*",
    re.DOTALL,
)


def parse_atom(text: str):
    text = text.strip().replace(" ", "")
    if text == "i":
        return (Fraction(0), Fraction(1))
    if text == "-i":
        return (Fraction(0), Fraction(-1))
    imag = text.endswith("i")
    if imag:
        text = text[:-1]
    if text.startswith(r"\frac{") and text.endswith("}"):
        numerator, denominator = text[6:-1].split("}{", 1)
        value = Fraction(int(numerator), int(denominator))
    elif text.startswith("2^{") and text.endswith("}"):
        exponent = int(text[3:-1])
        value = Fraction(2**exponent) if exponent >= 0 else Fraction(1, 2**(-exponent))
    elif text.startswith("-2^{") and text.endswith("}"):
        exponent = int(text[4:-1])
        value = -Fraction(2**exponent) if exponent >= 0 else -Fraction(1, 2**(-exponent))
    else:
        value = Fraction(int(text))
    return (Fraction(0), value) if imag else (value, Fraction(0))


def scale_value(value, scale):
    return (value[0] * scale, value[1] * scale)


def parse_matrix(document: str, case_id: str):
    matches = [m for m in MATRIX_RE.finditer(document)
               if m.group("case") == case_id]
    if len(matches) != 1:
        raise ValueError(
            f"{case_id}: expected one marked matrix block, found {len(matches)}"
        )
    body = matches[0].group("body")
    begin = body.find(r"\begin{bmatrix}")
    end = body.find(r"\end{bmatrix}")
    if begin < 0 or end < 0 or end <= begin:
        raise ValueError(f"{case_id}: matrix must use bmatrix")
    expression = body[begin + len(r"\begin{bmatrix}"):end].strip()
    prefix = body[:begin].strip()
    if "=" in prefix:
        prefix = prefix.rsplit("=", 1)[1].strip()
    scale = Fraction(1)
    if prefix:
        prefix_match = re.search(r"2\^\{-(\d+)\}\s*$", prefix)
        if prefix_match is None:
            raise ValueError(f"{case_id}: unsupported matrix scale {prefix!r}")
        scale = Fraction(1, 2 ** int(prefix_match.group(1)))
    rows = []
    for raw_row in re.split(r"\\\\", expression):
        raw_row = raw_row.strip()
        if not raw_row:
            continue
        rows.append([scale_value(parse_atom(entry), scale)
                     for entry in raw_row.split("&")])
    if not rows or len({len(row) for row in rows}) != 1:
        raise ValueError(f"{case_id}: malformed matrix rows")
    return rows


def compare(expected, actual, case_id):
    rows = len(expected)
    columns = len(expected[0])
    if (rows, columns) != actual["shape"]:
        raise ValueError(
            f"{case_id}: shape {rows}x{columns} != "
            f"{actual['shape'][0]}x{actual['shape'][1]}"
        )
    for row in range(rows):
        for column in range(columns):
            expected_value = expected[row][column]
            actual_value = actual["values"][(row + 1, column + 1)]
            if expected_value != actual_value:
                raise ValueError(
                    f"{case_id}: mismatch at ({row + 1},{column + 1}): "
                    f"{expected_value!r} != {actual_value!r}"
                )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("records", type=Path)
    args = parser.parse_args()
    metadata, records = load_records(args.records)
    actual = {}
    for case_id, (doc, rows, columns) in metadata.items():
        actual[case_id] = {
            "doc": doc,
            "shape": (rows, columns),
            "values": {
                (row, column): records[(case_id, row, column)]
                for row in range(1, rows + 1)
                for column in range(1, columns + 1)
            },
        }

    for case_id, item in actual.items():
        document = Path(item["doc"]).read_text(encoding="utf-8")
        expected = parse_matrix(document, case_id)
        compare(expected, item, case_id)
        print(f"PASS: {case_id} {item['shape'][0]}x{item['shape'][1]} {item['doc']}")
        if case_id == "FRANK0":
            checks = {
                (0, 0): (Fraction(8), Fraction(0)),
                (0, 7): (Fraction(1), Fraction(0)),
                (3, 2): (Fraction(5), Fraction(0)),
                (3, 1): (Fraction(0), Fraction(0)),
            }
            for (row, column), value in checks.items():
                if expected[row][column] != value:
                    raise ValueError(
                        f"FRANK0: focused orientation check failed at "
                        f"({row + 1},{column + 1})"
                    )
            print("PASS: FRANK0 focused orientation checks (11, 18, 43, 42)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
