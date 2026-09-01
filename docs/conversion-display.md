# Scalar conversion and display

## Scope

M05 defines conversion and display for one public scalar `mp` value.  It does
not define matrix conversion, matrix layout, arithmetic, comparison, or
serialization.

## Canonical decimal representation

Finite nonzero values use normalized base-10 scientific notation:

```text
[-]d[.digits]e[+|-]exponent
```

There is one nonzero digit before the optional decimal point, the exponent
marker is lower-case `e`, the exponent sign is always present, and its
magnitude has no leading zeroes.  Redundant trailing zeroes in the fractional
significand are removed without changing the decimal value.

The implementation calls `mpfr_get_str` with base 10, zero requested digits,
and `MPFR_RNDN`.  MPFR 4.2.2 defines zero requested digits as
`mpfr_get_str_ndigits(10, p)`, where `p` is the source value's precision.  That
is the certified digit count with which rounding-to-nearest output can be read
back at the same precision using rounding to nearest.  This behavior and the
matching `mpfr_free_str` ownership rule were audited against the
[MPFR 4.2.2 conversion-function manual](https://www.mpfr.org/mpfr-4.2.2/mpfr.html#Conversion-Functions-1).

## Round-trip guarantee

For a finite scalar `x` with precision `p`, parsing `char(x)` at precision `p`
reconstructs the same MPFR value.  The text is not promised to be the shortest
decimal and is not a precision-independent exact serialization of the binary
rational.  Future save/load support will need an explicit serialization
contract and precision metadata.

## Precision dependence

Formatting reads the immutable precision stored in the object.  It never uses
or changes the current default precision.  Consequently, changing `mpbits`
does not change `char(x)` or `disp(x)` for an existing value.

## Special values

Canonical special forms are:

```text
Inf
-Inf
NaN
```

The existing native text constructor accepts these forms.

## Signed zero

Positive zero is `0` and negative zero is `-0`.  Both the canonical text path
and explicit binary64 conversion preserve the zero sign where the host IEEE
binary64 implementation supports signed zero.

## Locale independence

Canonical digits come directly from `mpfr_get_str`; no locale-sensitive
stream, `printf` numeric conversion, or Octave binary64 formatter participates.
The decimal point is always `.`.  M05 does not change the process locale.

## Binary64 conversion

`double(x)` calls `mpfr_get_d` directly on the stored value.  It does not pass
through decimal text.  This conversion is explicitly lossy whenever the value
cannot be represented exactly in IEEE binary64.

## Rounding mode

Both canonical digit extraction and binary64 conversion explicitly request
`MPFR_RNDN`, round to nearest with ties to even.  They do not depend on or
modify MPFR's mutable default rounding mode.

## Display behavior

Scalar `disp(x)` writes `char(x)` followed by one newline.  It therefore uses
the same canonical multiprecision representation and does not convert through
binary64.  The result is intentionally independent of Octave `format short`
and `format long` settings.

## Memory and error handling

The buffer returned by `mpfr_get_str` is held by a project RAII owner and
released with `mpfr_free_str` on every path.  Output size arithmetic is checked
before reserving or appending to a C++ string.  Allocation and native
conversion failures are translated at the Octave extension boundary.

## Non-goals

M05 does not add implicit numeric or textual conversion.  Unsupported
operators and generic numeric functions remain errors.  User-selectable
display precision, shortened display modes, `printf` integration, and exact
serialization are outside this milestone.

## Future matrix display considerations

M05's formatter is a scalar primitive that future dense matrix display may
reuse.  Dense matrices will use the native M07 representation and will not be
represented or displayed as arrays of independent scalar wrapper objects.
