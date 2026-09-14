# Ozaki–Ogita paired real standard form (Tier S1)

## Quick idea

OO53_PAIR isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: Look for conjugate pairing in the realized spectrum and for a small left residual using conjugate transpose. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=8$, $g=53$ bits. Demo: $n=16$, $g=53$ bits. The dimension is even
and $S$ is block upper triangular with 2-by-2 real blocks.

For block index $j=0,\ldots,n/2-1$, define

```math
a_j=2j+1+2^{-45},\qquad b_j=(2j+1)/8+2^{-45},\qquad
B_j=\begin{bmatrix}a_j&b_j\\-b_j&a_j\end{bmatrix}.
```

The requested $S_{\mathrm{req}}$ places $B_j$ on the diagonal and $8I_2$ on each first block superdiagonal. The same fixed Ozaki–Ogita triple product as in OO53_REAL is then applied. The roots of the realized standard form are the exact complex pair

```math
\lambda_{j,\pm}=a'_j\mathbin{\pm} i b'_j,
```

where $a'_j,b'_j$ are the realized, once-quantized entries.

## Concrete smoke matrix

<!-- smoke-matrix: OO53_PAIR -->

```math
A_{\mathrm{smoke}} = 2^{-3} \begin{bmatrix}
23 & 646 & 744 & 130 & 148 & 94 & 96 & -93 \\
-14 & -572 & -615 & -66 & -148 & -94 & -96 & 93 \\
12 & 513 & 558 & 130 & 212 & 94 & 96 & -93 \\
-10 & -430 & -450 & -100 & -145 & -30 & -96 & 93 \\
8 & 344 & 360 & 115 & 166 & 94 & 160 & -93 \\
-6 & -258 & -270 & -90 & -102 & -44 & -91 & 157 \\
4 & 172 & 180 & 60 & 68 & 69 & 126 & -93 \\
-2 & -86 & -90 & -30 & -34 & -38 & -42 & 99
\end{bmatrix}.
```

This is the full concrete smoke fixture for `OO53_PAIR`. The matching [`oo53_pair.m`](../../../../examples/tiered/neig-tier-s/oo53_pair.m) selects the same manifest case and hands this input to the public `eig` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

The pair case tests a subtle representation invariant rather than merely asking for complex output. A pair block is real, but its eigenvalues are complex conjugates, and the full block upper-triangular standard form need not be normal because of the $8I_2$ couplings. Quantizing the upper $b$ and lower $-b$ independently can break the exact conjugate block structure by one ulp. The specified sign-copy rule avoids that error: quantize the shared magnitude once and form the lower entry by exact negation. The dense $A$ then inherits a nontrivial nonnormal eigenvector problem while its requested pair geometry is known.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [oo53_pair.m](../../../../examples/tiered/neig-tier-s/oo53_pair.m) selects the paired case and reports the generator audit, the realized block roots, and the measured eig output. The comparison uses a complex MP bijective matching and the left-eigenvector convention $A^{\mathsf H}w=\overline{\lambda}w$. It checks the real reconstruction of the paired blocks separately from the dense residual. The example is deliberately not a call to a complex-valued generic matrix constructor followed by a binary64 conversion.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The paired generator checks that both diagonal positions share one quantized $a$, that the lower $b$ is exactly the negative of the quantized upper $b$, and that the same lattice and magnitude bounds used for the theorem hold. It independently verifies both matrix products and $XY=YX=I$. The realized pair is stored before any eigensolver call. A nonzero $b'$ is required for the mandatory fixture; if a future parameter made $b'=0$, its multiplicity would have to be relabeled rather than still called a complex pair.

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

The source precision is $g=53$ for the generator. Later 128/256-bit arithmetic evaluates the frozen $A$ and its complex eigensystem. MPFR precision controls real components and MPC precision controls complex operations at the selected operation precision; neither changes the original quantization. Mathematical difficulty comes from nonnormal block coupling and the relation between right and left eigenvectors, not simply from the presence of imaginary parts.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

Look for conjugate pairing in the realized spectrum and for a small left residual using conjugate transpose. The order and phases of eigenvectors are not fixed. A residual for $AV-VD$ can be small even when the two members of a sensitive pair move, so compare the matched eigenvalues and the block-structure audit together. The requested values are a construction target; the realized values are the forward-error reference.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not quantize b and -b separately, transpose instead of conjugate-transpose the left relation, call the whole S normal because each diagonal block has a conjugate pair, or compare arbitrary eigenvector phases entrywise. Do not replace the paired form with two unrelated scalar roots.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Katsuhisa Ozaki and Takeshi Ogita, “Generation of test matrices with specified eigenvalues using floating-point arithmetic.” *Numerical Algorithms* 90 (2022), 241–262. DOI: [10.1007/s11075-021-01186-7](https://doi.org/10.1007/s11075-021-01186-7)](https://doi.org/10.1007/s11075-021-01186-7) — Theorem 1 and the paired standard-form construction motivate the fixed-precision generator and the requested/realized distinction.
- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [oo53_pair.m](../../../../examples/tiered/neig-tier-s/oo53_pair.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
