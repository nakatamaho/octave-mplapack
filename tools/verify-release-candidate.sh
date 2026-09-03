#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

commit=${1:-HEAD}
git rev-parse --verify "$commit^{commit}" >/dev/null
commit_sha=$(git rev-parse "$commit^{commit}")

package_name=$(sed -n 's/^Name: *//p' DESCRIPTION)
package_version=$(sed -n 's/^Version: *//p' DESCRIPTION)
if [ "$package_version" != "0.1.0" ]; then
  echo "FAIL: release candidate must use DESCRIPTION version 0.1.0" >&2
  exit 1
fi
package_dir=$package_name-$package_version

qa_root=$(mktemp -d)
cleanup ()
{
  find "$qa_root" -depth -delete
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

for label in A B; do
  checkout=$qa_root/$label
  mkdir -p "$checkout"
  git archive --format=tar --prefix=source/ "$commit_sha" \
    | tar -xf - -C "$checkout"
  (
    cd "$checkout/source"
    SOURCE_DATE_EPOCH=0 tools/build-package.sh
  )
  archive=$checkout/source/dist/$package_dir.tar.gz
  [ -f "$archive" ] || {
    echo "FAIL: build $label did not produce $archive" >&2
    exit 1
  }
  sha256sum "$archive" > "$qa_root/$label.sha256"
  stat -c '%s' "$archive" > "$qa_root/$label.size"
  tar tzf "$archive" > "$qa_root/$label.list"
  top_levels=$(cut -d/ -f1 "$qa_root/$label.list" | LC_ALL=C sort -u)
  if [ "$top_levels" != "$package_dir" ]; then
    echo "FAIL: build $label does not have one top-level directory" >&2
    exit 1
  fi
  if grep -Eq '(^|/)docs/v0\.1-release-manifest\.md$|(^|/)m23-report\.md$' \
      "$qa_root/$label.list"; then
    echo "FAIL: handoff/report metadata leaked into the runtime archive" >&2
    exit 1
  fi
done

hash_a=$(awk '{print $1}' "$qa_root/A.sha256")
hash_b=$(awk '{print $1}' "$qa_root/B.sha256")
if [ "$hash_a" != "$hash_b" ]; then
  echo "FAIL: clean release-candidate archives differ" >&2
  cat "$qa_root/A.sha256" "$qa_root/B.sha256" >&2
  exit 1
fi
if ! cmp -s "$qa_root/A.list" "$qa_root/B.list"; then
  echo "FAIL: clean release-candidate archive file lists differ" >&2
  exit 1
fi

echo "PASS: release candidate $commit_sha"
echo "Archive: $package_dir.tar.gz"
echo "SHA256: $hash_a"
echo "Size: $(cat "$qa_root/A.size") bytes"
echo "File list: identical"
