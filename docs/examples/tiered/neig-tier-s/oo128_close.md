# Ozaki–Ogita 128-bit close-spectrum form (Tier S1)

## Quick idea

OO128_CLOSE isolates one mathematical reason a dense nonsymmetric eigensystem
can be misleading: the key reading is a three-way comparison. Requested roots
contain $2^{-80}+2^{-120}$, realized roots contain only $2^{-80}$, and
measured roots approximate the realized values. The case is intentionally
small enough to inspect and is paired with a deterministic runner. Its tier is
a statement about pedagogical difficulty and verification depth, not a claim
that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=8$, generation precision $g=128$ bits. Demo: $n=16$, $g=128$ bits.
The first two requested diagonal entries differ by a deliberately
unrepresentable tail.

The real requested standard form is upper bidiagonal. Its first diagonal entries are

```math
s_1=1,\qquad s_2=1+2^{-80}+2^{-120},
```

the remaining diagonal entries are $3,4,\ldots,n$, and every first-superdiagonal entry is 1. The fixed 128-bit generator rounds the shifted expression at $g=128$, producing $S'$ and then

```math
A=\mathrm{RN}_{128}\!\left(Y\,\mathrm{RN}_{128}(S'X)\right).
```

The required realized gap is $s'_2-s'_1=2^{-80}$: the $2^{-120}$ requested increment is intentionally removed and must remain visible in the metadata.

## Concrete smoke matrix

<!-- smoke-matrix: OO128_CLOSE -->

```math
A_{\mathrm{smoke}} = 2^{-80} \begin{bmatrix}
10880332376531662572355577 & 25387442211907212668829682 & 10880332376531662572355577 & -2417851639229258349412352 & 2417851639229258349412352 & -2417851639229258349412352 & 2417851639229258349412352 & -1208925819614629174706176 \\
-8462480737302404222943225 & -21760664753063325144711154 & -9671406556917033397649401 & 2417851639229258349412352 & -2417851639229258349412352 & 2417851639229258349412352 & -2417851639229258349412352 & 1208925819614629174706176 \\
7253554917687775048237050 & 21760664753063325144711156 & 12089258196146291747061754 & -1208925819614629174706176 & 2417851639229258349412352 & -2417851639229258349412352 & 2417851639229258349412352 & -1208925819614629174706176 \\
-6044629098073145873530875 & -18133887294219437620592630 & -6044629098073145873530875 & 6044629098073145873530880 & -1208925819614629174706176 & 2417851639229258349412352 & -2417851639229258349412352 & 1208925819614629174706176 \\
4835703278458516698824700 & 14507109835375550096474104 & 4835703278458516698824700 & 0 & 7253554917687775048237056 & -1208925819614629174706176 & 2417851639229258349412352 & -1208925819614629174706176 \\
-3626777458843887524118525 & -10880332376531662572355578 & -3626777458843887524118525 & 0 & 0 & 8462480737302404222943232 & -1208925819614629174706176 & 1208925819614629174706176 \\
2417851639229258349412350 & 7253554917687775048237052 & 2417851639229258349412350 & 0 & 0 & 0 & 9671406556917033397649408 & 0 \\
-1208925819614629174706175 & -3626777458843887524118526 & -1208925819614629174706175 & 0 & 0 & 0 & 0 & 9671406556917033397649408
\end{bmatrix}.
```

This is the full concrete smoke fixture for `OO128_CLOSE`. The matching [`oo128_close.m`](../../../../examples/tiered/neig-tier-s/oo128_close.m) selects the same manifest case and hands this input to the public `eig` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

This case separates source/model fidelity from eigensolver precision. The target roots are close relative to their magnitude, and the requested form includes a tail below the selected generation lattice. If a reader sees a 256-bit eig run and assumes all requested bits are present, the experiment has been misread. Conversely, if the dense products are evaluated at insufficient precision, a product error can be mistaken for the intended quantization. The test therefore has two distinct questions: did the prescribed $g=128$ generator realize exactly the documented $S'$, and can later MP arithmetic recover the spectrum of that realized dense matrix?

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [oo128_close.m](../../../../examples/tiered/neig-tier-s/oo128_close.m) runs the fixed case, checks the realized first gap, and measures eig(A) at the suite work/reference precisions. It reports both requested and realized spectra. The dense matrix is not rebuilt at each mpbits value. The balance and nobalance rows are controls for solver behavior; neither is allowed to alter the frozen input.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

Exactness is checked at the dyadic level for the shifted quantization, $S'X$, $Y(S'X)$, and the final $A$. The guard calculation records $P$, $\alpha$, $n_Y$, and $n'$ and verifies the theorem inequality. The $2^{-120}$ loss is checked by decoding the stored dyadic entries, not by decimal formatting. Repeating the generator at $g=128$ must produce identical hashes; raising the eig precision must leave those hashes unchanged.

The construction audit is intentionally independent of eig: it checks algebraic identities, dyadic serialization, and declared generation guards before using a solver result. A cross-precision match is useful evidence, but it is not an exactness proof.

## Diagnostics

For a computed $A\in\mathbb{C}^{n\times n}$, right vectors $V$, diagonal or block output $D$, and left vectors $W$, the primary residuals are

```math
r_{\mathrm{eig}}=
\frac{\lVert AV-VD\rVert_F}{\lVert A\rVert_F\lVert V\rVert_F},
\qquad
r_{\mathrm{left}}=
\frac{\lVert A^{\mathsf H}W-WD^{\mathsf H}\rVert_F}
{\lVert A\rVert_F\lVert W\rVert_F}.
```

For a selected cluster $J$, use $A V_J-V_JD_J$ and a range/projector or principal-angle comparison; do not turn a repeated or defective cluster into an individual-vector claim.

Also inspect the normwise backward indicator against the correct input, the forward bottleneck against the exact/realized reference, and the left/right or subspace diagnostic appropriate to this case. Keep MP values until the final display. A residual is not a certificate that every eigenvalue digit is forward correct.

## Backward error versus forward error

The residual ($r_{\mathrm{eig}}$) measures how nearly the returned factors satisfy an eigen-equation. It can be interpreted as a small backward perturbation of the matrix under suitable normalization, but the corresponding forward eigenvalue error is multiplied by eigenvalue and eigenvector conditioning. In a cluster, the forward object is an invariant subspace. In a defective case, a full diagonalizing basis does not exist. The report therefore never promotes a small residual to a universal accuracy claim.

## What arbitrary precision changes

The input/source precision is the frozen 128-bit standard form; work precision is 128/256-bit in smoke and higher in reference rows. The mathematical gap is $2^{-80}$ after realization, while the discarded tail is not part of the model. Higher arithmetic precision improves the solve and dense products but cannot recreate the discarded tail. This is why the document names the realized matrix explicitly.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

The key reading is a three-way comparison: requested roots contain $2^{-80}+2^{-120}$, realized roots contain only $2^{-80}$, and measured roots approximate the realized values. A high residual means the eigensolver failed; a small residual with a $2^{-120}$ difference from the requested root is expected. Use absolute error for this local gap and a scaled bottleneck metric for the full spectrum.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not label the requested spectrum as the exact spectrum, regenerate S for each solve precision, claim that the lost tail proves MP arithmetic is inaccurate, or use a low-precision rounded product as the exact model. Do not scale the entire S and assume that the same tail behavior follows; the generator’s alpha guard scales too.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Katsuhisa Ozaki and Takeshi Ogita, “Generation of test matrices with specified eigenvalues using floating-point arithmetic.” *Numerical Algorithms* 90 (2022), 241–262. DOI: [10.1007/s11075-021-01186-7](https://doi.org/10.1007/s11075-021-01186-7)](https://doi.org/10.1007/s11075-021-01186-7) — Theorem 1 and the paired standard-form construction motivate the fixed-precision generator and the requested/realized distinction.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [oo128_close.m](../../../../examples/tiered/neig-tier-s/oo128_close.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
