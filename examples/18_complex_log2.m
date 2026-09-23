## Demonstrate the native arbitrary-precision complex log2 path.
##
## The complex operation is routed through the gmpfrxx MPC compatibility
## wrapper and does not require a direct mpc_log2 symbol.

mpbits (256);
z = mp ("1", "2");
w = log2 (z);
assert (isa (w, "mp"));
assert (! isreal (w));
disp (w);
