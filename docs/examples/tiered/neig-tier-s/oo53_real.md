# Ozaki–Ogita real standard form (Tier S1)

## Quick idea

OO53_REAL is the smallest complete example of a fixed-precision eigenvalue generator followed by a dense nonsymmetric eigensolve. Its purpose is to make a distinction visible: a requested matrix, the once-rounded standard form, the generated dense matrix, and the measured eigensolver output are four different objects. The case uses the real form of the Ozaki–Ogita construction and is intentionally deterministic.

## Mathematical problem

Smoke uses $n=8$ and generation precision $g=53$ bits; demo uses $n=16$ and
the same $g$. Let $N$ have ones on the first superdiagonal, let
$L=I+N^{\mathsf T}$ and $U=I+N$, and define $X=LU$ and
$Y=U^{-1}L^{-1}$. The requested standard form is upper bidiagonal:

```math
(S_{\mathrm{req}})_{ii}=i+2^{-45},\qquad
(S_{\mathrm{req}})_{i,i+1}=32.
```

The specified generator applies the two rounded shifted additions and then the two matrix products at exactly g:

```math
\sigma=12\alpha P,\qquad
S'_{ij}=\operatorname{RN}_{g}\left(\operatorname{RN}_{g}(\sigma+(S_{\mathrm{req}})_{ij})-\sigma\right),
```


```math
A=\operatorname{RN}_{g}\left(Y\,\operatorname{RN}_{g}(S'X)\right).
```

The roots of the realized triangular standard form are $\operatorname{diag}(S')$, not the requested diagonal.

## Why this problem is numerically difficult

The difficulty is in the construction as well as in the eigensolve. $X$ and $Y$
are triangular inverse factors with different dyadic scales. The Ozaki–Ogita
theorem uses those scales, the unit roundoff $u=2^{-g}$, the nonzero-count
parameters, and the exact bound $P=\beta\gamma\theta\omega$ to make the two
products error-free at the selected generation precision. A generic similarity
generator would not test that contract.

The requested diagonal contains a small $2^{-45}$ increment. The shift
expression can quantize it, and the realized matrix must preserve that fact in
its metadata. A later 256-bit eig call cannot restore a bit removed at $g=53$.
Conversely, if a low work precision corrupts $S'X$ or $Y(S'X)$, that is a
product failure, not an intended quantization effect. Exactness and solver
accuracy are therefore separate gates.

## What the Octave example computes

The matching [oo53_real.m](../../../../examples/tiered/neig-tier-s/oo53_real.m) selects only OO53_REAL from the fixed NEIG manifest and invokes the public mp_neig_tiers smoke path. The family runner uses $n=8$ for smoke and $n=16$ for demo, runs both balance modes, and records generation precision, requested/realized spectra, model hashes, operation precision, measured roots, and left/right diagnostics. It sends the generated dense $A$ to eig; it does not solve the easier triangular $S'$ problem in its place.

Before reading the root comparison, inspect the generator record: $X$ and $Y$ must be inverse pairs, the theorem inequality must hold, the rounded products must equal the independently evaluated exact products, and at least one requested entry must be quantized. Repeating generation at $g=53$ must be bit-identical, regardless of later eig precision.

## Construction and exactness

The independent audit verifies $XY=YX=I$ using finite nilpotent series, not an unverified numerical inverse. It calculates a sufficient dyadic bit guard for both matrix-product stages and checks the Ozaki–Ogita inequality

```math
4 n_Y n' 2^{-g}P\le 1.
```

Every rounded scalar sum and every final matrix entry is compared with an exact dyadic numerator/denominator evaluation. The realized standard form and the final A are serialized separately. Agreement between two MP runs is a useful regression check but cannot replace this exactness proof.

The $g=53$ generator is the explicitly allowed fixed-precision generator. It must not be silently changed to 64, 128, or the eigensolver precision. The construction is also not a license to route later dense operations through builtin binary64 complex arithmetic.

## Diagnostics

For $A\in\mathbb{C}^{n\times n}$, right vectors $V$, diagonal output $D$, and
left vectors $W$, use

```math
r_{\mathrm{eig}}=
\frac{\lVert AV-VD\rVert_F}{\lVert A\rVert_F\lVert V\rVert_F},
\qquad
r_{\mathrm{left}}=
\frac{\lVert A^{\mathsf H}W-WD^{\mathsf H}\rVert_F}
{\lVert A\rVert_F\lVert W\rVert_F}.
```

Match measured eigenvalues bijectively with diag(S') and separately with diag(S_req). Keep a requested-versus-realized forward bottleneck, a model hash, and the generation exactness status. A real model has no mathematical imaginary parts; a displayed imaginary component is a solver/conditioning diagnostic.

## Backward error versus forward error

The eigen residual is a backward-style equation defect. It says that the returned factors nearly satisfy an eigen-equation for the stored $A$. It does not say that each root is close to the requested root: forward error is affected by the realized/requested difference and by the left/right eigenvalue condition. A small residual can therefore coexist with a visible difference at the $2^{-45}$ scale, while a large residual means the measured solve itself needs investigation.

## What arbitrary precision changes

The input/source precision is $g=53$ for the frozen generator output. Arithmetic/work precision is 128 or 256 bits in the smoke rows, with higher reference/evaluation rows. Mathematical conditioning is determined by the triangular factors and the eigenvector geometry. More work precision reduces rounding in the dense eigensolve and diagnostics, but it does not regenerate $S'$ or restore a discarded requested bit. The operation must still use the input-owned MPFR/MPC precision and restore the caller’s ambient precision.

## Reading the output

First confirm that the case ID, $n$, $g$, and requested/realized hashes are correct. Next confirm the theorem audit and product exactness. Then read $r_{\mathrm{eig}}$ and the matched forward errors. If the measured result follows $\operatorname{diag}(S')$ rather than $\operatorname{diag}(S_{\mathrm{req}})$, that is expected when the generator removed a requested increment. A PASS line is only a pass for these declared gates; it is not a claim that the requested unrounded spectrum was computed.

## Common mistakes

Do not use $mp(S_{\mathrm{req}})$ as the measured $A$, compare only with the requested diagonal, regenerate the standard form for each eig precision, or call the construction a generic similarity recipe. Do not infer forward accuracy from $r_{\mathrm{eig}}$ alone. Do not use an ordinary inverse to establish $XY=I$. Do not silently change $g$ or label a native binary64 control as the MP result.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Katsuhisa Ozaki and Takeshi Ogita, “Generation of test matrices with specified eigenvalues using floating-point arithmetic.” Numerical Algorithms 90 (2022), 241–262. DOI: 10.1007/s11075-021-01186-7](https://doi.org/10.1007/s11075-021-01186-7) — Theorem 1 and the paired standard-form construction motivate the fixed-precision generator and the requested/realized distinction.
- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — General all-eigenvalue error-bound context; this page does not claim that the project implements that paper.

The selected dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations.

## Project provenance

- Runnable case: [oo53_real.m](../../../../examples/tiered/neig-tier-s/oo53_real.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Generator specification: [GENERATOR-OO.md](../../../../docs/codex/neigt/GENERATOR-OO.md).
- The detailed page explains the model; the family runner remains the measurement authority.
