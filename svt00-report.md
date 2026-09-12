# SVT00 report

## Result

SVT00: PASS.

The authoritative implementation worktree for this task is `/tmp/t00-t14`,
branch `topic/svd-tier-sav-examples`, starting at
`760ec415a6f2b634f5cb80ee53758925cd32b83d`. The existing SVD and NEIG
implementations were retained. The specification bundle was copied without
content changes from the prepared bundle into `docs/codex/` and its recorded
SHA-256 checks passed.

## API and path audit

The installed/public SVD surface is:

```text
inst/@mp/svd.m
  -> __mplapack_core__("svd", value, mode, output_mode)
  -> src/octave_bridge.cc: mp_svd_operation
  -> src/mp_svd.cc: Rgesvd or Cgesvd
```

Supported forms verified from the current source and executed successfully:

```text
s = svd(A)
[U,S,V] = svd(A)
[U,S,V] = svd(A, "econ")
[U,S,V] = svd(A, 0)       % deprecated economy spelling
```

Two-output SVD and invalid options are rejected. Full and economy shapes,
real/complex type paths, descending nonnegative singular values, reconstruction,
input immutability, and `V` rather than `V'` output convention are covered by
the existing SVD tests and the focused probe below.

Existing reuse paths are `examples/07_svd_hilbert.m`, `test/svd.tst`,
`src/mp_svd.cc`, `src/mp_svd.h`, and the existing MP matrix/arithmetic/solve,
norm, and eigensystem implementations. NEIG remains under
`examples/nonsymmetric_eig/` and `examples/13_nonsymmetric_eig_suite.m`.
Three unused top-level example numbers allocated for SVT are 14, 15, and 16.

## Precision and rounding audit

The current scalar implementation uses explicit MPFR `MPFR_RNDN` for real
addition, subtraction, multiplication, division, square root, and extraction;
the complex path uses MPC with `MPC_RND(MPFR_RNDN, MPFR_RNDN)`. The inspected
paths are `src/mp_arithmetic.cc`, `src/mp_matrix_arithmetic.cc`,
`src/mp_script_compat.cc`, `src/mp_complex_arithmetic.cc`, `src/mp_svd.cc`,
and `src/mp_precision.cc`. The SVD boundary uses uniform stored precision,
operation-owned destructive copies, and RAII precision scopes. The source
search found no implicit binary64 numerical fallback in these paths;
`double(mp)` is an explicit conversion only.

This is the SVT00 source/API audit, not the final Tier V proof audit. The
universal scalar rounding/range preconditions and exact dyadic certificate
serialization remain mandatory SVT12 work and are not claimed PASS here.

## Commands and observed results

Environment:

```text
GNU Octave 11.1.0
MPLAPACK pkg-config module: mplapack_mpfr 3.0.1
MPLAPACK include: /home/docker/opt/octave-mplapack-stack/include/mplapack
MPLAPACK library: /home/docker/opt/octave-mplapack-stack/lib/libmplapack_mpfr.so.3
```

The dependency environment was selected with:

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
```

Executed gates:

```sh
tools/check-tree.sh
tools/check-format.sh
make -C src check-dependency
make -C src check-svd
make -C src check-norm
make -C src check-det-inv
make -C src check-rank-condition
make -C src check-structured-eig
make -C src check-general-eig
make -C src check-generalized-eig
```

All commands passed, including the ASan/UBSan native tests. The Octave
focused command passed `test/svd.tst`, `test/eig_general.tst`, and
`test/gesv.tst`. The additional public API probe passed real and complex
economy SVD, 256/1024-bit precision isolation, shape, immutability, and
reconstruction checks. The preparation Python check was rerun for consistency;
its output remains explicitly marked as non-Octave evidence.

## Gate assessment

```text
focused existing tests: PASS
current public API/path audit: PASS
reuse map and example allocation: PASS
SVT00 gate: PASS
Tier V scalar-contract final audit: DEFERRED TO SVT12 (not a SVT00 failure)
```

Branch: `topic/svd-tier-sav-examples`
Starting commit: `760ec415a6f2b634f5cb80ee53758925cd32b83d`
Final commit: `c1f4010aa8bc13917a1281504acd7fe2c6b69cd1`
Files changed: `docs/codex/**`, `README-SVT.md`, `SHA256SUMS-SVT`, `svt00-report.md`
Commands run: the commands listed above, plus the public API and preparation probes
Tests: existing native SVD/norm/det-inv/rank/eig gates and focused Octave SVD/eig/solve tests
Gate: PASS
Known limitations: no SVT runner, Tier S/A constructors, or Tier V verifier exists yet; no final certificate claim is made
