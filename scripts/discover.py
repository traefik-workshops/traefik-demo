#!/usr/bin/env python3
"""Emit a JSON inventory of every leaf Terraform module + Helm chart in the repo.

Shape:
    {
      "modules": [
        { "path": "terraform/...", "required_inputs": [...], "sensitive_outputs": [...] },
        ...
      ],
      "charts": [
        { "path": "helm/<name>", "required_values": [...], "dependencies": [...] },
        ...
      ]
    }

Live-derived from the working tree (no committed snapshot). Intended as the
agent's first read of the repo — answers "what knobs do I need to set?"
without parsing every .tf and Chart.yaml by hand.

Parses HCL with regex + brace tracking rather than a real HCL library so the
script has no external deps. That is good enough for the canonical
`variable "name" { ... }` and `output "name" { ... }` shapes this repo uses;
exotic syntax (e.g. variables inside dynamic blocks) is not in scope.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

_BLOCK_RE = re.compile(r'^(variable|output)\s+"([^"]+)"\s*\{')
_DEFAULT_RE = re.compile(r"^\s*default\s*(=|\{)")
_SENSITIVE_RE = re.compile(r"^\s*sensitive\s*=\s*true\b")


def _walk_blocks(path: Path, kind: str):
    """Yield (name, body_lines) for every top-level `kind "name" { ... }` block."""
    if not path.exists():
        return
    lines = path.read_text().splitlines()
    i = 0
    while i < len(lines):
        m = _BLOCK_RE.match(lines[i])
        if not m or m.group(1) != kind:
            i += 1
            continue
        name = m.group(2)
        depth = lines[i].count("{") - lines[i].count("}")
        body = []
        i += 1
        while i < len(lines) and depth > 0:
            body.append(lines[i])
            depth += lines[i].count("{") - lines[i].count("}")
            i += 1
        yield name, body


def tf_required_inputs(variables_tf: Path) -> list[str]:
    out = []
    for name, body in _walk_blocks(variables_tf, "variable"):
        if not any(_DEFAULT_RE.match(ln) for ln in body):
            out.append(name)
    return out


def tf_sensitive_outputs(outputs_tf: Path) -> list[str]:
    out = []
    for name, body in _walk_blocks(outputs_tf, "output"):
        if any(_SENSITIVE_RE.match(ln) for ln in body):
            out.append(name)
    return out


def find_tf_modules() -> list[Path]:
    """Every dir that directly contains a .tf file, under terraform/."""
    seen: set[Path] = set()
    for tf in (ROOT / "terraform").rglob("*.tf"):
        if ".terraform" in tf.parts:
            continue
        seen.add(tf.parent)
    return sorted(seen)


def find_helm_charts() -> list[Path]:
    """Every chart dir directly under helm/."""
    helm_dir = ROOT / "helm"
    if not helm_dir.exists():
        return []
    return sorted(p.parent for p in helm_dir.glob("*/Chart.yaml"))


def helm_required_values(schema: Path) -> list[str]:
    if not schema.exists():
        return []
    try:
        data = json.loads(schema.read_text())
    except json.JSONDecodeError:
        return []
    return data.get("required", []) or []


def helm_dependencies(chart_yaml: Path) -> list[str]:
    """Dependency names. Uses yq for YAML→JSON since the repo already requires it."""
    if not chart_yaml.exists():
        return []
    try:
        out = subprocess.check_output(
            ["yq", "-o=json", ".dependencies // [] | map(.name)", str(chart_yaml)],
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []
    try:
        return json.loads(out) or []
    except json.JSONDecodeError:
        return []


def main() -> int:
    modules = []
    for mod in find_tf_modules():
        rel = mod.relative_to(ROOT).as_posix()
        modules.append({
            "path": rel,
            "required_inputs": tf_required_inputs(mod / "variables.tf"),
            "sensitive_outputs": tf_sensitive_outputs(mod / "outputs.tf"),
        })

    charts = []
    for chart in find_helm_charts():
        rel = chart.relative_to(ROOT).as_posix()
        charts.append({
            "path": rel,
            "required_values": helm_required_values(chart / "values.schema.json"),
            "dependencies": helm_dependencies(chart / "Chart.yaml"),
        })

    json.dump({"modules": modules, "charts": charts}, sys.stdout, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
