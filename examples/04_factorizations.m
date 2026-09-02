% Dense real Cholesky, QR, pivoted QR, and LU.
A = mp ([4, 2; 2, 10]);
Rchol = chol (A);
disp (Rchol);

[Q, Rqr] = qr (A);
disp (Q * Rqr);

Ap = mp ([1, 0, 0; 0, 4, 0; 0, 0, 2]);
[Qp, Rp, P] = qr (Ap);
disp (Qp * Rp - Ap * P);

[L, U, PLU] = lu (A);
disp (PLU * A - L * U);
