#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

package_name=$(sed -n 's/^Name: *//p' DESCRIPTION)
package_version=$(sed -n 's/^Version: *//p' DESCRIPTION)

case $package_name in
  ''|*[!A-Za-z0-9_-]*)
    echo "FAIL: invalid package name in DESCRIPTION: $package_name" >&2
    exit 1
    ;;
esac

case $package_version in
  ''|*[!A-Za-z0-9._+-]*)
    echo "FAIL: invalid package version in DESCRIPTION: $package_version" >&2
    exit 1
    ;;
esac

package_dir=$package_name-$package_version
dist_dir=$repo_root/dist
archive=$dist_dir/$package_dir.tar.gz
stage_root=$(mktemp -d)
archive_tmp=

cleanup ()
{
  if [ -n "$archive_tmp" ] && [ -f "$archive_tmp" ]; then
    rm -f "$archive_tmp"
  fi
  find "$stage_root" -depth -delete
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

package_root=$stage_root/$package_dir
manifest=$stage_root/manifest
mkdir -p "$package_root" "$dist_dir"

source_roots='
DESCRIPTION
COPYING
INDEX
LICENSE
NEWS.md
README.md
CONTRIBUTING.md
inst
src
test
docs
tools
'

for source_root in $source_roots; do
  if [ ! -e "$source_root" ]; then
    echo "FAIL: package source is missing: $source_root" >&2
    exit 1
  fi
done

find $source_roots -type f \
  ! -name '*.o' \
  ! -name '*.oct' \
  ! -name '*.lo' \
  ! -name '*.la' \
  ! -path '*/.build-m02/*' \
  ! -path '*/.build-m06/*' \
  ! -path '*/.build-m07/*' \
  ! -path '*/.build-m08/*' \
  ! -path '*/.build-m09/*' \
  ! -path '*/.build-m10/*' \
  ! -path '*/.build-m11/*' \
  ! -path '*/.build-m12/*' \
  ! -path '*/.build-m13/*' \
  ! -path '*/.build-m14/*' \
  ! -path '*/.libs/*' \
  ! -path '*/.deps/*' \
  -print | LC_ALL=C sort > "$manifest"

while IFS= read -r source_path; do
  destination_dir=$package_root/$(dirname "$source_path")
  mkdir -p "$destination_dir"
  cp "$source_path" "$package_root/$source_path"
done < "$manifest"

archive_epoch=${SOURCE_DATE_EPOCH:-0}
tar_path=$stage_root/$package_dir.tar
tar --sort=name --format=ustar --owner=0 --group=0 --numeric-owner \
  --mtime="@$archive_epoch" -C "$stage_root" -cf "$tar_path" "$package_dir"
archive_tmp=$(mktemp "$dist_dir/.package.XXXXXX")
gzip -n -c "$tar_path" > "$archive_tmp"
mv "$archive_tmp" "$archive"
archive_tmp=

echo "PASS: built dist/$package_dir.tar.gz"
