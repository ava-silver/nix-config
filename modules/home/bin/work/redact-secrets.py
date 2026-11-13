#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

SUCCESS_CODES = {0, 200, 205}


def scan(path: Path) -> list[dict[str, int]]:
    # Validators skip retired or expired credentials, which still need masking. Archive entries are excluded because
    # this script rewrites the plain files it is given, not the archives that contain them.
    result = subprocess.run(
        [
            "kingfisher",
            "scan",
            str(path),
            "--git-history",
            "none",
            "--no-validate",
            "--no-extract-archives",
            "--rules-path",
            "@redactSecretsRules@",
            "--redact",
            "--no-dedup",
            "--format",
            "jsonl",
            "--no-update-check",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode not in SUCCESS_CODES:
        raise RuntimeError(
            f"Kingfisher failed for {path} with exit code {result.returncode}"
        )

    return [
        record["finding"]
        for line in result.stdout.splitlines()
        if line and (record := json.loads(line)).get("finding")
    ]


def by_file(findings: list[dict[str, int]]) -> dict[Path, list[dict[str, int]]]:
    grouped: dict[Path, list[dict[str, int]]] = {}
    for finding in findings:
        grouped.setdefault(Path(finding["path"]), []).append(finding)
    return grouped


def redact(path: Path, findings: list[dict[str, int]]) -> None:
    lines = path.read_text().splitlines(keepends=True)
    by_line: dict[int, list[dict[str, int]]] = {}
    for finding in findings:
        by_line.setdefault(finding["line"], []).append(finding)

    for line_number, matches in by_line.items():
        line = list(lines[line_number - 1])
        for finding in sorted(
            matches, key=lambda item: item["column_start"], reverse=True
        ):
            start = finding["column_start"]
            end = finding["column_end"] + 1
            if start < 0 or end > len(line) or start >= end:
                raise RuntimeError(
                    f"Invalid Kingfisher range in {path} at line {line_number}"
                )
            line[start:end] = "*" * (end - start)
        lines[line_number - 1] = "".join(line)

    mode = path.stat().st_mode
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.redact-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as file:
            file.writelines(lines)
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    except BaseException:
        Path(temporary).unlink(missing_ok=True)
        raise


def main() -> int:
    paths = [
        Path(argument).expanduser().resolve()
        for argument in sys.argv[1:]
        if argument != "--"
    ]
    if not paths:
        print("Usage: redact-secrets -- <file|directory>...", file=sys.stderr)
        return 2

    for path in paths:
        print(f"Scanning {path}", flush=True)
        findings = scan(path)
        if not findings:
            print(f"No secrets found in {path}", flush=True)
            continue
        for file, matches in by_file(findings).items():
            redact(file, matches)
            print(f"Redacted {len(matches)} occurrence(s) from {file}", flush=True)
        remaining = scan(path)
        if remaining:
            raise RuntimeError(f"Secrets remain in {path}")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, UnicodeError, json.JSONDecodeError) as error:
        print(f"redact-secrets: {error}", file=sys.stderr)
        raise SystemExit(1)
