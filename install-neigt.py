#!/usr/bin/env python3
"""Install the NEIGT instruction bundle without replacing existing content."""
from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path, PurePosixPath
import re
import sys
import tempfile
from typing import Iterable

MANIFEST = "SHA256SUMS-NEIGT"


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def safe_relative(text: str) -> Path:
    path = PurePosixPath(text)
    if path.is_absolute() or not path.parts or any(p in {".", ".."} for p in path.parts):
        raise ValueError(f"Unsafe bundle path: {text!r}")
    if "\\" in text or "\x00" in text or text != path.as_posix():
        raise ValueError(f"Noncanonical bundle path: {text!r}")
    return Path(*path.parts)


def assert_no_symlinks(root: Path, relative: Path) -> None:
    current = root
    if current.is_symlink():
        raise ValueError(f"Symlink root is not allowed: {root}")
    for part in relative.parts:
        current = current / part
        if current.is_symlink():
            raise ValueError(f"Symlink path is not allowed: {current}")


def load_payload(bundle: Path) -> list[tuple[Path, bytes, str]]:
    manifest_path = bundle / MANIFEST
    assert_no_symlinks(bundle, Path(MANIFEST))
    raw = manifest_path.read_bytes()
    text = raw.decode("utf-8")
    entries: list[tuple[Path, bytes, str]] = []
    seen: set[Path] = set()
    for number, line in enumerate(text.splitlines(), 1):
        match = re.fullmatch(r"([0-9a-f]{64})  (.+)", line)
        if not match:
            raise ValueError(f"Invalid checksum line {number}")
        expected, name = match.groups()
        relative = safe_relative(name)
        if relative in seen or relative == Path(MANIFEST):
            raise ValueError(f"Duplicate/self-referencing checksum path: {name}")
        seen.add(relative)
        assert_no_symlinks(bundle, relative)
        source = bundle / relative
        if not source.is_file():
            raise ValueError(f"Missing regular bundle file: {name}")
        data = source.read_bytes()
        if digest(data) != expected:
            raise ValueError(f"Checksum mismatch: {name}")
        entries.append((relative, data, expected))
    required = {
        Path("README-NEIGT.md"), Path("install-neigt.py"),
        Path("docs/codex/NEIGT-LUNA-XHIGH.md"), Path("docs/codex/NEIGT-GOAL.md"),
        Path("docs/codex/neigt/cases.json"),
        Path("docs/codex/neigt/verification-jobs.json"),
    }
    if not required.issubset(seen):
        raise ValueError("Checksum manifest lacks required instruction files")
    entries.append((Path(MANIFEST), raw, digest(raw)))
    return entries


def preflight(repo: Path, entries: Iterable[tuple[Path, bytes, str]]) -> list[tuple[Path, bytes, str]]:
    if not repo.is_dir() or repo.is_symlink():
        raise ValueError(f"Repository must be an existing nonsymlink directory: {repo}")
    if not (repo / ".git").exists():
        raise ValueError(f"No .git directory/worktree marker found: {repo}")
    pending: list[tuple[Path, bytes, str]] = []
    conflicts: list[str] = []
    for relative, data, expected in entries:
        assert_no_symlinks(repo, relative)
        target = repo / relative
        current = target.parent
        while current != repo:
            if current.exists() and not current.is_dir():
                conflicts.append(f"Parent is not a directory: {current}")
                break
            current = current.parent
        if target.exists():
            if not target.is_file() or digest(target.read_bytes()) != expected:
                conflicts.append(f"Different existing destination: {target}")
            else:
                print(f"IDENTICAL  {relative.as_posix()}")
        else:
            pending.append((relative, data, expected))
            print(f"NEW        {relative.as_posix()}")
    if conflicts:
        raise ValueError("Preflight failed; nothing was copied:\n" + "\n".join(conflicts))
    return pending


def apply(repo: Path, pending: list[tuple[Path, bytes, str]]) -> None:
    created: list[tuple[Path, str, int, int]] = []
    temp_paths: list[Path] = []
    try:
        for relative, data, expected in pending:
            assert_no_symlinks(repo, relative)
            destination = repo / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            assert_no_symlinks(repo, relative)
            with tempfile.NamedTemporaryFile(prefix=".neigt-", dir=destination.parent, delete=False) as stream:
                temporary = Path(stream.name)
                temp_paths.append(temporary)
                stream.write(data)
                stream.flush()
                os.fsync(stream.fileno())
            os.chmod(temporary, 0o644)
            # Atomic create-without-replacement on the destination filesystem.
            os.link(temporary, destination)
            stat = destination.stat()
            created.append((destination, expected, stat.st_dev, stat.st_ino))
            temporary.unlink()
            temp_paths.remove(temporary)
            print(f"COPIED     {relative.as_posix()}")
    except BaseException:
        for path, expected, device, inode in reversed(created):
            try:
                stat = path.lstat()
                if (not path.is_symlink() and stat.st_dev == device and stat.st_ino == inode
                        and path.is_file() and digest(path.read_bytes()) == expected):
                    path.unlink()
                else:
                    print(f"ROLLBACK_SKIPPED_CHANGED  {path}", file=sys.stderr)
            except FileNotFoundError:
                pass
        raise
    finally:
        for temporary in temp_paths:
            try:
                temporary.unlink()
            except FileNotFoundError:
                pass


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, required=True, help="Existing target Git checkout")
    parser.add_argument("--apply", action="store_true", help="Copy after a successful all-file preflight")
    args = parser.parse_args()
    bundle = Path(__file__).absolute().parent
    repo = args.repo.expanduser().absolute()
    try:
        entries = load_payload(bundle)
        pending = preflight(repo, entries)
        if not args.apply:
            print(f"DRY_RUN: {len(pending)} new files; use --apply to copy.")
            return 0
        apply(repo, pending)
        print(f"DONE: {len(pending)} instruction files copied; no existing file replaced.")
        return 0
    except (OSError, ValueError, UnicodeError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
