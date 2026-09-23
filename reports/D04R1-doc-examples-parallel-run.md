# D04R1 documentation-example smoke run

## Result

```text
GNU Parallel: GNU parallel 20240222
Requested concurrency: 32 jobs
Tasks: 92 total (65 runnable examples, 27 help lookups)
Task results: 92 PASS, 0 FAIL
GNU Parallel exit status: 0
Wall time: 737 seconds (12 minutes 17 seconds)
Start: 2026-09-23T21:32:20+09:00
End:   2026-09-23T21:44:37+09:00
```

The 65 examples comprised 21 ordinary/verification examples, including the
NEIG V-S and V-A smoke entry points, plus all 44 `examples/tiered/*.m`
examples. The 27 help lookups were the complete list from
`tools/test-doc-examples.sh`, including `@mp/log2`. Every job ran against the
clean installed 0.5.1 candidate at `/tmp/d04r1-final-prefix` with a separate
`HOME` and per-task stdout/stderr files.

The fixed `/tmp/mplapack-interop-example.mat` output of
`examples/09_serialization_rng.m` was protected with an exclusive `flock`; all
other jobs used the corresponding shared lock. This allowed all jobs to be
submitted to the same GNU Parallel run without racing on the shared file.

The slowest task was `examples/16_neig_verified_vs.m` at 736.497 seconds.
`examples/tiered/svd-tier-s/nro_scale_up.m` and
`examples/tiered/svd-tier-s/nro_scale_down.m` took 482.934 and 482.206 seconds,
respectively. These were single documentation examples, not full stress
profiles.

## Reproduction command shape

Tasks were enumerated in `/tmp/d04r1-doc-parallel/tasks.tsv` and submitted as
`parallel --jobs 32 --halt never --colsep '\t' --line-buffer --tagstring
'{1}' 'bash /tmp/d04r1-parallel-worker.sh {1} {2} {3}'`.
The worker command loaded `mplapack-interop` from the isolated package DB,
executed each example or help lookup in a separate Octave process, and recorded
per-task status and elapsed time.

GNU Parallel's native `--joblog` option was accidentally omitted. Per-task
start/end/status records and timings are retained in
`/tmp/d04r1-doc-parallel/logs/` and
`/tmp/d04r1-doc-parallel/task-results.tsv`; the console contains all 92 PASS
lines at `/tmp/d04r1-doc-parallel/parallel-console.log`. The whole-run timing
is also in `/tmp/d04r1-doc-parallel/run-summary.txt`.

This gate exercises runnable documentation examples and help lookups. It is
not a substitute for the full `tools/local-ci.sh` sanitizer/regression wall,
which was not run as part of this timing measurement.
