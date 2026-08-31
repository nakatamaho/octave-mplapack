# M02 — Native `mp` value storage

# Goal

Introduce the smallest safe native representation for multiprecision values. A
scalar-first implementation is acceptable when it supports the ownership proof.

# Scope

- Deterministic RAII ownership
- Explicit value precision
- Safe copy, destruction, assignment, temporaries, and moves if used
- A supported Octave 11.1 custom-value integration

# Non-goals

- Complete matrix construction or arithmetic
- User-visible pointer handles or a global handle registry
- Premature Octave 8 implementation throughout numerical code

# Design constraints

First inspect installed Octave 11.x headers, extension APIs, shipped examples,
and supported custom-value mechanisms. Do not guess from obsolete tutorials or
commit to an inheritance hierarchy before that inspection. Initialize and
clear MPFR objects exactly once, avoid leaks and double-free, retain precision
and dimensions explicitly, and localize any later compatibility layer.

# Implementation tasks

- Document the inspected Octave API and selected native-value mechanism.
- Implement minimal RAII storage and deliberate copy/move behavior.
- Integrate it with Octave temporaries and errors without raw-pointer exposure.
- Document scalar metadata versus future matrix storage responsibilities.

# Required tests

Exercise repeated construction/destruction, copies, assignments, temporaries,
error paths, and repeated package usage. Run ASan where practical and Valgrind
where available and meaningful, recording any limitations rather than hiding
them.

# Gate

`G02` passes only with no known memory ownership defects and with all required
lifetime paths covered. This gate is planned and is not passed by M00.

# Expected commit

`M02: add safe native mp value storage`
