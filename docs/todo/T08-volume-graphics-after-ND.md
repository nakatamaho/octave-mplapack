# T08 TODO — volume graphics after N-D storage

## Scope

`slice`, `isosurface`, and related volume/N-D graphics APIs.

## Why deferred

The public `mp` contract is currently dense and two-dimensional. Implementing
volume graphics before defining N-D storage would create an inconsistent shape
and conversion boundary.

## Current evidence

`plot3`, `scatter3`, `mesh`, `surf`, `contour3`, `meshc`, `surfc`, and
`waterfall` pass with final-boundary conversion. Volume forms are firewall-
rejected and no numerical data path converts through binary64.

## Required dependency/algorithm

First establish N-D MPFR/MPC storage and indexing; then define an explicit
final visualization conversion for each volume API.

## Public API target

Octave-compatible volume graphics using MP data with conversion confined to
the final graphics boundary.

## Precision requirements

All field construction remains MPFR/MPC; only values consumed by the host
graphics routine may become builtin doubles.

## Test requirements

N-D shapes, slices/isosurfaces, handles and property forwarding, range-loss
behavior, high precision, firewall, and sanitizers.

## Re-entry milestone

After N-D storage and graphics boundary milestones; not part of T00–T14.
