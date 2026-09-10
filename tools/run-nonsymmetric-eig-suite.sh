#!/bin/sh

# Run the repository-local all-family nonsymmetric eigensystem suite.
# Usage: tools/run-nonsymmetric-eig-suite.sh [smoke|demo|stress] [output-dir]

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
profile=${1:-smoke}
output_dir=${2:-}

case "$profile" in
  smoke|demo|stress) ;;
  *)
    echo "usage: $0 [smoke|demo|stress] [output-dir]" >&2
    exit 2
    ;;
esac

if [ "$#" -gt 2 ]; then
  echo "usage: $0 [smoke|demo|stress] [output-dir]" >&2
  exit 2
fi

export NEIG_PROFILE="$profile"
export NEIG_OUTPUT="$output_dir"

cd "$repo_root"
exec tools/dev-octave.sh --eval \
  'addpath ("examples/nonsymmetric_eig");
   profile = getenv ("NEIG_PROFILE");
   output_dir = getenv ("NEIG_OUTPUT");
   if (isempty (output_dir))
     results = mp_eig_suite (profile);
   else
     results = mp_eig_suite (profile, struct ("output_dir", output_dir));
   endif
   fprintf ("NEIG %s: %s (%d rows)\n", profile, results.status, numel (results.rows));
   if (! results.ok)
     error ("NEIG:Failed", "nonsymmetric eigensystem suite failed");
   endif'
