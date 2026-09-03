% Square and rectangular real multiprecision solves.
A = mp ([2, 1; 1, 3]);
b = mp ([1; 2]);
x = A \ b;
disp (x);

T = mp ([1, 0; 0, 1; 1, 1]);
r = mp ([0; 1; 4]);
y = T \ r;
disp (y);
