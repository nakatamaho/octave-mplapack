#!/usr/bin/env bash
set -euo pipefail

# NEIGT25 isolated package QA.  This script owns every temporary path it
# creates, builds the source archive from a clean Git extraction, and installs
# only that archive into a temporary Octave package prefix.  It never changes
# a production prefix, dependency checkout, tag, or published artifact.
repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

work_root=$(mktemp -d "${TMPDIR:-/tmp}/neigt25-clean-qa.XXXXXX")
qa_home="$work_root/home"
pkg_prefix="$work_root/octave-packages"
pkg_arch_prefix="$work_root/octave-arch"
pkg_db="$work_root/octave_packages"
source_checkout="$work_root/source-checkout"
source_extract="$work_root/source-extract"
proof_dir="$work_root/replayable-proof"
mkdir -p "$qa_home" "$pkg_prefix" "$pkg_arch_prefix" \
         "$source_checkout" "$source_extract"
trap 'rm -rf "$work_root"' EXIT

git archive --format=tar HEAD | tar -xf - -C "$source_checkout"
(
  cd "$source_checkout"
  SOURCE_DATE_EPOCH=0 tools/build-package.sh >/dev/null
)
package_name=$(sed -n 's/^Name: *//p' "$source_checkout/DESCRIPTION")
package_version=$(sed -n 's/^Version: *//p' "$source_checkout/DESCRIPTION")
package_dir=$package_name-$package_version
archive="$source_checkout/dist/$package_dir.tar.gz"
[[ -f "$archive" ]] || { echo "FAIL: missing clean source archive" >&2; exit 1; }
tar -xzf "$archive" -C "$source_extract"
source_root="$source_extract/$package_dir"

mplapack_pc=${MPLAPACK_PC:-mplapack_mpfr}
pkg_config_bin=${PKG_CONFIG:-pkg-config}
"$pkg_config_bin" --exists "$mplapack_pc" || {
  echo "FAIL: $mplapack_pc is unavailable through pkg-config" >&2
  exit 1
}
mplapack_version=$($pkg_config_bin --modversion "$mplapack_pc")
mplapack_libdir=$($pkg_config_bin --variable=libdir "$mplapack_pc")
mplapack_prefix=$($pkg_config_bin --variable=prefix "$mplapack_pc")

export NEIGT25_PKG_DB="$pkg_db"
export NEIGT25_PKG_PREFIX="$pkg_prefix"
export NEIGT25_PKG_ARCH_PREFIX="$pkg_arch_prefix"
export NEIGT25_REPO_ROOT="$repo_root"
export NEIGT25_SOURCE_ROOT="$source_root"
export NEIGT25_PROOF_DIR="$proof_dir"

export PKG_CONFIG_PATH="$mplapack_libdir/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="$mplapack_libdir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export CPATH="$mplapack_prefix/include${CPATH:+:$CPATH}"

octave_args=(--no-gui --quiet --no-init-file
  --path "$source_root/examples/neig_tiers/private"
  --path "$source_root/examples/neig_tiers")

run_octave() {
  HOME="$qa_home" octave-cli "${octave_args[@]}" --eval "$1"
}

install_package() {
  run_octave "pkg ('local_list', '$pkg_db'); pkg ('prefix', '$pkg_prefix', '$pkg_arch_prefix'); pkg ('install', '-local', '$archive');"
}

install_package

run_octave '
  pkg ("local_list", getenv ("NEIGT25_PKG_DB"));
  pkg ("prefix", getenv ("NEIGT25_PKG_PREFIX"), getenv ("NEIGT25_PKG_ARCH_PREFIX"));
  pkg ("load", "mplapack-interop");
  public_path = which ("mp");
  helper_path = which ("mp_neig_tiers");
  replay_path = which ("mp_neig_replay");
  fprintf ("which mp: %s\n", public_path);
  fprintf ("which mp_neig_tiers: %s\n", helper_path);
  fprintf ("which mp_neig_replay: %s\n", replay_path);
  assert (! isempty (public_path));
  assert (! isempty (helper_path));
  assert (! isempty (replay_path));
  assert (! strncmp (public_path, getenv ("NEIGT25_REPO_ROOT"), ...
                     length (getenv ("NEIGT25_REPO_ROOT"))));
  assert (! strncmp (helper_path, getenv ("NEIGT25_REPO_ROOT"), ...
                     length (getenv ("NEIGT25_REPO_ROOT"))));
  assert (! strncmp (replay_path, getenv ("NEIGT25_REPO_ROOT"), ...
                     length (getenv ("NEIGT25_REPO_ROOT"))));
  assert (strncmp (helper_path, getenv ("NEIGT25_SOURCE_ROOT"), ...
                  length (getenv ("NEIGT25_SOURCE_ROOT"))));
  assert (strncmp (replay_path, getenv ("NEIGT25_SOURCE_ROOT"), ...
                  length (getenv ("NEIGT25_SOURCE_ROOT"))));
  info = mplapack_version ();
  assert (strcmp (info.backend, "mpfr"));
  fprintf ("MPLAPACK version: %s\n", info.mplapack);
  fprintf ("PASS: isolated which provenance\n");
'

run_octave '
  pkg ("local_list", getenv ("NEIGT25_PKG_DB"));
  pkg ("prefix", getenv ("NEIGT25_PKG_PREFIX"), getenv ("NEIGT25_PKG_ARCH_PREFIX"));
  pkg ("load", "mplapack-interop");
  smoke = mp_neig_tiers ("smoke", struct ("tier", "all", "plot", false));
  assert (strcmp (smoke.status, "NUMERICS_ONLY_COMPLETE"));
  assert (! smoke.ok && smoke.scope_ok);
  assert (smoke.coverage.measured_eig_rows == 120);
  demo = mp_neig_tiers ("demo", struct ("tier", "all", "plot", false));
  assert (strcmp (demo.status, "NUMERICS_ONLY_COMPLETE"));
  assert (! demo.ok && demo.scope_ok);
  assert (demo.coverage.measured_eig_rows == 168);
  fprintf ("PASS: isolated ordinary smoke=120 demo=168\n");
'

run_octave '
  pkg ("local_list", getenv ("NEIGT25_PKG_DB"));
  pkg ("prefix", getenv ("NEIGT25_PKG_PREFIX"), getenv ("NEIGT25_PKG_ARCH_PREFIX"));
  pkg ("load", "mplapack-interop");
  smoke = mp_neig_verify_examples ("smoke", struct ("tier", "V", "plot", false));
  assert (smoke.ok && strcmp (smoke.status, "COMPLETE"));
  assert (smoke.coverage.verification_job_count == 26);
  assert (smoke.coverage.verification_jobs_implemented == 26);
  assert (all ([smoke.jobs.pass]) && all ([smoke.jobs.milestone_pass]));
  fprintf ("PASS: isolated V smoke=26/26\n");
  clear smoke;
  demo = mp_neig_verify_examples ("demo", struct ("tier", "V", "plot", false));
  assert (demo.ok && strcmp (demo.status, "COMPLETE"));
  assert (demo.coverage.verification_job_count == 26);
  assert (demo.coverage.verification_jobs_implemented == 26);
  assert (all ([demo.jobs.pass]) && all ([demo.jobs.milestone_pass]));
  fprintf ("PASS: isolated V demo=26/26\n");
'

run_octave '
  pkg ("local_list", getenv ("NEIGT25_PKG_DB"));
  pkg ("prefix", getenv ("NEIGT25_PKG_PREFIX"), getenv ("NEIGT25_PKG_ARCH_PREFIX"));
  pkg ("load", "mplapack-interop");
  A = mp ([1, 2; 3, 4]);
  b = mp ([1; 2]);
  x = A \ b;
  assert (norm (double (A * x - b)) < 1e-12);
  Z = mp ([1+2i, 2-1i; 3, 4+3i]);
  zb = mp ([1; 2i]);
  z = Z \ zb;
  assert (norm (double (Z * z - zb)) < 1e-12);
  assert (! isempty (strtrim (evalc ("help mp_neig_tiers"))));
  fprintf ("PASS: isolated package real/complex/help smoke\n");
  bundle = mp_neig_write_outputs ("smoke", getenv ("NEIGT25_PROOF_DIR"), ...
                                  struct ("tier", "all", "plot", false));
  assert (bundle.replay.ok);
  fprintf ("Replayable proof: %s\n", bundle.output.proof);
  pkg ("unload", "mplapack-interop");
  pkg ("uninstall", "-nodeps", "mplapack-interop");
'

run_octave '
  assert (isempty (which ("mp")));
  assert (isempty (which ("mpbits")));
  helper_path = which ("mp_neig_tiers");
  assert (! isempty (helper_path));
  assert (strncmp (helper_path, getenv ("NEIGT25_SOURCE_ROOT"), ...
                  length (getenv ("NEIGT25_SOURCE_ROOT"))));
  fprintf ("PASS: isolated uninstall removes package paths; extracted helper remains\n");
'

install_package

run_octave '
  pkg ("local_list", getenv ("NEIGT25_PKG_DB"));
  pkg ("prefix", getenv ("NEIGT25_PKG_PREFIX"), getenv ("NEIGT25_PKG_ARCH_PREFIX"));
  pkg ("load", "mplapack-interop");
  A = mp ([2, 1; 1, 3]);
  assert (norm (double (A * (A \ mp ([1; 2])) - mp ([1; 2]))) < 1e-12);
  Z = mp ([2+1i, 1; 1, 3-1i]);
  assert (norm (double (Z * (Z \ mp ([1; 2i])) - mp ([1; 2i]))) < 1e-12);
  fprintf ("PASS: isolated reinstall second real/complex smoke\n");
'

echo "PASS: NEIGT25 isolated clean-package QA"
echo "Source revision: $(git rev-parse HEAD)"
echo "Source archive: $package_dir.tar.gz"
echo "Source archive size: $(stat -c '%s' "$archive")"
echo "Source archive SHA256: $(sha256sum "$archive" | awk '{print $1}')"
echo "MPLAPACK: $mplapack_version ($mplapack_prefix)"
echo "Package prefix: $pkg_prefix"
echo "Example source: $source_root"
echo "Replayable proof: $proof_dir/proof-vs1-01.json"

if [[ -n "${NEIGT25_ARTIFACT_DIR:-}" ]]; then
  mkdir -p "$NEIGT25_ARTIFACT_DIR"
  cp -a "$proof_dir" "$NEIGT25_ARTIFACT_DIR/"
  echo "Exported proof artifacts: $NEIGT25_ARTIFACT_DIR/replayable-proof"
fi
