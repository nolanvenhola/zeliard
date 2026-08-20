#!/usr/bin/env python3
"""Mechanical architecture and typed-GDScript checks for the production project."""

from __future__ import annotations

import re
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
SCRIPT_ROOTS = (PROJECT_ROOT / "runtime", PROJECT_ROOT / "addons", PROJECT_ROOT / "tests")
RUNTIME_FORBIDDEN = (
    "@tool",
    "EditorPlugin",
    "EditorInterface",
    "EditorInspectorPlugin",
    "res://addons",
)
FUNCTION = re.compile(r"^\s*func\s+\w+\s*\((?P<parameters>[^)]*)\)\s*(?:->\s*[^:]+)?\s*:")
TYPED_FUNCTION = re.compile(r"^\s*func\s+\w+\s*\([^)]*\)\s*->\s*[^:]+\s*:")
UNTYPED_VAR = re.compile(r"^\s*var\s+[a-zA-Z_]\w*\s*=")


def check_script(path: Path) -> list[str]:
    errors: list[str] = []
    text = path.read_text(encoding="utf-8")
    relative = path.relative_to(PROJECT_ROOT).as_posix()
    if path.is_relative_to(PROJECT_ROOT / "runtime"):
        for token in RUNTIME_FORBIDDEN:
            if token in text:
                errors.append(f"{relative}: runtime code contains editor-only token {token!r}")
    for line_number, line in enumerate(text.splitlines(), 1):
        function = FUNCTION.match(line)
        if function and not TYPED_FUNCTION.match(line):
            errors.append(f"{relative}:{line_number}: function requires an explicit return type")
        if function:
            parameters = function.group("parameters")
            for parameter in parameters.split(","):
                declaration = parameter.strip().split("=", maxsplit=1)[0]
                if declaration and ":" not in declaration:
                    errors.append(
                        f"{relative}:{line_number}: parameter {declaration!r} requires an explicit type"
                    )
        if UNTYPED_VAR.match(line):
            errors.append(f"{relative}:{line_number}: variable requires an explicit type or := inference")
        leading = line[: len(line) - len(line.lstrip())]
        if " " in leading and line.strip():
            errors.append(f"{relative}:{line_number}: use tabs for GDScript indentation")
    return errors


def main() -> int:
    errors: list[str] = []
    scripts = sorted(path for root in SCRIPT_ROOTS for path in root.rglob("*.gd"))
    if not scripts:
        errors.append("no production GDScript files found")
    for script in scripts:
        errors.extend(check_script(script))
    if errors:
        print("Architecture validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print(f"PASS: architecture and typing rules ({len(scripts)} scripts)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
