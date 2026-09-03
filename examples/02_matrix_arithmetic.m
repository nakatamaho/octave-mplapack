% Dense real MPFR matrix arithmetic.
A = mp ([1, 2; 3, 4]);
B = mp ([5, 6; 7, 8]);
disp (A + B);
disp (A .* B);
disp (A * B);
