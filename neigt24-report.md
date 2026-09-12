# NEIGT24 report

## Result

NEIGT24: PASS

This milestone integrated the four numbered Tier-S/Tier-A/V-S/V-A examples
into the existing documentation example runner and `test/run_tests.m`. The
authoritative manual was updated in Texinfo and regenerated to Markdown.
The source-package gate uses two independent clean Git extractions and checks
required helpers, manifests, focused tests, documentation, and deterministic
archive contents. No numerical implementation, dependency, installed API,
backend, compiler semantic, or public rounding API was changed.

## Branch and commits

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `dc25773fa8f4cd18cfd4562fc3503ae30b038f6f`

Final implementation commit: `b9f6d557495e1f6857a41a1e527f7c199857286a`

The report-record commit is created after this report-only update.

## Files changed

```text
README.md
doc/mplapack-interop.texi
docs/advanced-numerics-compatibility.md
docs/backend-map.md
docs/doxygen/mainpage.dox
docs/mplapack-interop.md
docs/octave-script-compatibility.md
docs/public-api-inventory.md
examples/neig_tiers/mp_neig_tiers.m
examples/neig_tiers/mp_neig_verify_examples.m
test/run_tests.m
test/test_neigt24.m
tools/check-neigt-source-package.sh
tools/test-doc-examples.sh
```

Pre-existing untracked user files were not staged, edited, or removed:
`docs/NEIG-LUNA-XHIGH.md`, `docs/codex/SVT-GOAL.md`,
`docs/codex/SVT-LUNA-XHIGH.md`, `docs/codex/svt/`, `octave-workspace`, and
`test/octave-workspace`.

## Commands and measured results

Focused gate:
`timeout 1800s octave-cli --no-gui --quiet --no-init-file --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src --path /tmp/neigt-work2/examples/neig_tiers/private --path /tmp/neigt-work2/examples/neig_tiers --path /tmp/neigt-work2/test --eval 'test_neigt24();'`

Exit status 0. Tier-S smoke: 12 cases/72 measured rows. Tier-A smoke: 8
cases/48 measured rows. V-S: 16/16 jobs PASS. V-A: 10/10 jobs PASS. All four
helper help blocks were found.

Relevant regressions:

```text
timeout 900s octave-cli ... --eval 'test_neigt13();'
timeout 900s octave-cli ... --eval 'test_neigt23();'
```

Both exited 0. NEIGT13 retained outward arithmetic/complex rectangle/range/
replay-hash PASS. NEIGT23 retained exact output, independent replay, tamper,
output-conflict, and headless PASS.

Documentation gates:

```text
tools/build-manual-markdown.sh
tools/check-docs.sh
tools/build-docs.sh
tools/check-tree.sh
tracked-file format scan and bash -n tools/*.sh
```

All passed. `tools/build-docs.sh` produced user HTML, Info/plaintext,
generated Markdown, and Doxygen HTML. No working TeX PDF toolchain was
available, so PDF was informationally not built.

The existing `tools/check-format.sh` scans untracked files and encountered the
pre-existing binary `test/octave-workspace`; it was not allowed to consume or
remove that user file. The tracked-file equivalent and changed-file
`git diff --check` passed.

Source-package gate: `timeout 900s tools/check-neigt-source-package.sh` exited
0. Two clean Git extractions produced identical
`mplapack-interop-0.5.0-dev.tar.gz` archives. Size: 635736 bytes. SHA256:
`9dd42849feaaecf6f8ab18a640466d6fbb35f72812152f8d31fb08a2eb56d6d2`.
Required numbered examples, helper/private directories, both JSON manifests,
focused tests, Texinfo/Markdown manuals, inventories, Doxygen landing page,
and source-package tools were present; `.git`, build products, native outputs,
and workspace files were absent.

Documentation example gate: `timeout 3600s tools/test-doc-examples.sh` exited 0.
Existing examples 1--13 and new examples 14--17 completed, with the configured
MPLAPACK MPFR 3.0.1 dependency probe passing.

## Documentation and scope audit

The manual records syntax, profiles, tier selection, 120/168 ordinary row
counts, 26 verification jobs per profile, model/input/candidate separation,
one-operation/one-precision MPFR/MPC behavior, no-binary64-fallback policy,
defective cluster/block-Schur semantics, output/replay hash binding, and the
display-only plotting boundary. The four helper APIs have concise Octave help
where applicable and are classified as repository-local QA interfaces, not
installed package APIs. Stress and optional plots were not run.

## Gate

NEIGT24: PASS

## Known limitations

The source package remains `0.5.0-dev`; no release was frozen or published.
The PDF toolchain was unavailable. The whole-worktree `check-format.sh` cannot
be claimed clean while the pre-existing untracked workspace binary remains.

## Required final milestone fields

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `dc25773fa8f4cd18cfd4562fc3503ae30b038f6f`

Final commit: `b9f6d557495e1f6857a41a1e527f7c199857286a`

Files changed: paths listed above, plus this report in the next report-record
commit.

Commands run: focused NEIGT24 gate; NEIGT13/23 regressions; manual/Markdown,
DOC00, Doxygen, tree, tracked-format, source-package, and full documentation
example gates.

Tests: all listed commands exited 0.

Gate: PASS.

Known limitations: development archive only; no PDF, Stress, or plot gate;
untracked workspace file prevents an unqualified whole-worktree format claim.
