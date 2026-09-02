% Scalar construction keeps text and binary64 semantics distinct.
mpbits (512);
a = mp ("0.1");
b = mp (0.1);
fprintf ("text:   %s\n", char (a));
fprintf ("double: %s\n", char (b));
