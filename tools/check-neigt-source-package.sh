#!/usr/bin/env bash
set -euo pipefail

# Build the NEIGT source package twice from independent Git extractions.
# This deliberately excludes untracked worktree material and does not build
# or install a binary package.
repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

work_root=$(mktemp -d "${TMPDIR:-/tmp}/neigt-source-package.XXXXXX")
trap 'rm -rf "$work_root"' EXIT

build_one() {
  local label=$1
  local checkout="$work_root/$label"
  mkdir -p "$checkout"
  git archive --format=tar HEAD | tar -xf - -C "$checkout"
  (
    cd "$checkout"
    SOURCE_DATE_EPOCH=0 tools/build-package.sh >/dev/null
  )
  cp "$checkout/dist/$(sed -n 's/^Name: *//p' "$checkout/DESCRIPTION")-$(sed -n 's/^Version: *//p' "$checkout/DESCRIPTION").tar.gz" \
     "$work_root/$label.tar.gz"
}

build_one A
build_one B

archive_a="$work_root/A.tar.gz"
archive_b="$work_root/B.tar.gz"
cmp -s "$archive_a" "$archive_b" || {
  echo "FAIL: NEIGT source-package archives differ" >&2
  exit 1
}

listing="$work_root/listing"
tar tzf "$archive_a" > "$listing"
package_dir=$(cut -d/ -f1 "$listing" | head -n 1)
expected=(
  "examples/14_neig_tier_s.m"
  "examples/15_neig_tier_a.m"
  "examples/16_neig_verified_vs.m"
  "examples/17_neig_verified_va.m"
  "examples/neig_tiers/"
  "examples/neig_tiers/private/"
  "examples/neig_tiers/private/net_v_s1_gershgorin.m"
  "examples/neig_tiers/private/net_v_a3_job.m"
  "test/test_neigt23.m"
  "test/test_neigt24.m"
  "docs/codex/neigt/cases.json"
  "docs/codex/neigt/verification-jobs.json"
  "doc/mplapack-interop.texi"
  "docs/mplapack-interop.md"
  "docs/backend-map.md"
  "docs/advanced-numerics-compatibility.md"
  "docs/public-api-inventory.md"
  "docs/doxygen/mainpage.dox"
  "tools/test-doc-examples.sh"
  "tools/check-neigt-source-package.sh"
  "tools/run-neigt-clean-package-qa.sh"
)
for path_name in "${expected[@]}"; do
  grep -Eq "^${package_dir}/${path_name}(\	|$)" "$listing" || {
    echo "FAIL: source package lacks $path_name" >&2
    exit 1
  }
done

if grep -Eq '(^|/)(\.git|dist|\.libs|\.deps)(/|$)|\.(o|oct|lo|la)$|(^|/)octave-workspace$' "$listing"; then
  echo "FAIL: source package contains a generated/private path" >&2
  exit 1
fi

hash=$(sha256sum "$archive_a" | awk '{print $1}')
size=$(stat -c '%s' "$archive_a")
echo "PASS: NEIGT source package contents and reproducibility"
echo "Archive: $package_dir.tar.gz"
echo "Size: $size"
echo "SHA256: $hash"
