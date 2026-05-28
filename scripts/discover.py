#!/usr/bin/env python3
"""Emit a JSON inventory of every leaf Terraform module + Helm chart in the repo.

Shape:
    {
      "tag": "vX.Y.Z",           # current repo tag (or "v0.0.0" if none)
      "modules": [
        {
          "path": "terraform/<section>/<...>",
          "section": "<section>",         # ai, apps, compute, observability, security, tools, traefik
          "platform": "<platform>",       # k8s, aws, azure, ..., or "" if N/A
          "name": "<basename>",
          "description": "<first README paragraph>",
          "required_inputs": [{"name": ..., "type": ..., "description": ...}, ...],
          "optional_inputs": [{"name": ..., "type": ..., "description": ..., "default_kind": "literal|expression"}, ...],
          "outputs": [{"name": ..., "description": ..., "sensitive": bool}, ...],
        },
        ...
      ],
      "charts": [
        {
          "path": "helm/<name>",
          "name": "<name>",
          "description": "<Chart.yaml description>",
          "app_version": "<Chart.yaml appVersion>",
          "keywords": [...],
          "required_values": [...],         # from values.schema.json "required" array
          "dependencies": [...]
        },
        ...
      ]
    }

Live-derived from the working tree. There is also a committed `catalog.json` at
the repo root that's expected to match this output; CI fails if it drifts.

Parses HCL with regex + brace tracking rather than a real HCL library so the
script has no Python deps. Good enough for the canonical
`variable "name" { ... }` and `output "name" { ... }` shapes this repo uses.
Uses `yq` for Chart.yaml YAML→JSON (already required by the repo).
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
_DESCRIPTION_RE = re.compile(r'^\s*description\s*=\s*"((?:[^"\\]|\\.)*)"')
_TYPE_RE = re.compile(r"^\s*type\s*=\s*(.+?)\s*$")
_LITERAL_DEFAULT_RE = re.compile(r'^\s*default\s*=\s*(?:"[^"]*"|\d+(?:\.\d+)?|true|false|null|\[\s*\]|\{\s*\})\s*$')


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


def _block_field(body: list[str], regex: re.Pattern) -> str:
    """Extract first matching field's first capture group, or ''. Stops at nested block."""
    depth = 0
    for ln in body:
        if depth == 0:
            m = regex.match(ln)
            if m:
                return m.group(1)
        depth += ln.count("{") - ln.count("}")
        if depth < 0:
            break
    return ""


def _has_default(body: list[str]) -> bool:
    depth = 0
    for ln in body:
        if depth == 0 and _DEFAULT_RE.match(ln):
            return True
        depth += ln.count("{") - ln.count("}")
    return False


def _is_sensitive(body: list[str]) -> bool:
    depth = 0
    for ln in body:
        if depth == 0 and _SENSITIVE_RE.match(ln):
            return True
        depth += ln.count("{") - ln.count("}")
    return False


def _default_kind(body: list[str]) -> str:
    """'literal' for scalars/empty collections, 'expression' for anything else."""
    depth = 0
    for ln in body:
        if depth == 0 and _DEFAULT_RE.match(ln):
            return "literal" if _LITERAL_DEFAULT_RE.match(ln) else "expression"
        depth += ln.count("{") - ln.count("}")
    return ""


def tf_variables(variables_tf: Path) -> tuple[list[dict], list[dict]]:
    required, optional = [], []
    for name, body in _walk_blocks(variables_tf, "variable"):
        desc = _block_field(body, _DESCRIPTION_RE)
        type_ = _block_field(body, _TYPE_RE)
        entry = {"name": name, "type": type_, "description": desc}
        if _has_default(body):
            entry["default_kind"] = _default_kind(body)
            optional.append(entry)
        else:
            required.append(entry)
    return required, optional


def tf_outputs(outputs_tf: Path) -> list[dict]:
    out = []
    for name, body in _walk_blocks(outputs_tf, "output"):
        out.append({
            "name": name,
            "description": _block_field(body, _DESCRIPTION_RE),
            "sensitive": _is_sensitive(body),
        })
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


def first_paragraph(readme: Path) -> str:
    """Return README.md's first non-heading, non-list, non-code paragraph (first sentence)."""
    if not readme.exists():
        return ""
    for line in readme.read_text().splitlines():
        s = line.strip()
        if not s or s.startswith("#") or s.startswith("-") or s.startswith("```") or s.startswith("|"):
            continue
        return s
    return ""


def helm_required_values(schema: Path) -> list[str]:
    if not schema.exists():
        return []
    try:
        data = json.loads(schema.read_text())
    except json.JSONDecodeError:
        return []
    return data.get("required", []) or []


def _yq(expr: str, file: Path) -> str:
    """Run `yq -o=json <expr> <file>`. Returns '' on error or missing yq."""
    try:
        return subprocess.check_output(
            ["yq", "-o=json", expr, str(file)], text=True
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def chart_meta(chart_yaml: Path) -> dict:
    """Parse Chart.yaml for description, appVersion, keywords, dependencies."""
    meta = {"description": "", "app_version": "", "keywords": [], "dependencies": []}
    if not chart_yaml.exists():
        return meta
    for key, expr in (
        ("description", ".description // \"\""),
        ("app_version", ".appVersion // \"\""),
        ("keywords", ".keywords // []"),
        ("dependencies", ".dependencies // [] | map(.name)"),
    ):
        raw = _yq(expr, chart_yaml)
        if not raw:
            continue
        try:
            meta[key] = json.loads(raw)
        except json.JSONDecodeError:
            pass
    return meta


def section_and_platform(rel_path: str) -> tuple[str, str]:
    """Parse `terraform/<section>/<platform>/<name>` (or variant) into (section, platform)."""
    parts = rel_path.split("/")
    if len(parts) < 2 or parts[0] != "terraform":
        return "", ""
    section = parts[1]
    # compute has cloud-first layout: terraform/compute/<cloud>/<name>
    if section == "compute" and len(parts) >= 3:
        return section, parts[2]
    # traefik has no platform layer: terraform/traefik/<name>
    if section == "traefik" and len(parts) >= 3:
        return section, ""
    # most sections: terraform/<section>/<name>/<platform>
    if len(parts) >= 4:
        return section, parts[3]
    if len(parts) == 3:
        return section, ""
    return section, ""


def current_tag() -> str:
    try:
        out = subprocess.check_output(
            ["git", "tag", "--list", "v*"], text=True, cwd=ROOT
        ).splitlines()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "v0.0.0"
    if not out:
        return "v0.0.0"
    # natural-sort by splitting on '.', taking the last
    def key(t: str):
        s = t.lstrip("v")
        try:
            return tuple(int(x) for x in s.split("."))
        except ValueError:
            return (0, 0, 0)
    return sorted(out, key=key)[-1]


def main() -> int:
    modules = []
    for mod in find_tf_modules():
        rel = mod.relative_to(ROOT).as_posix()
        required, optional = tf_variables(mod / "variables.tf")
        section, platform = section_and_platform(rel)
        modules.append({
            "path": rel,
            "section": section,
            "platform": platform,
            "name": mod.name,
            "description": first_paragraph(mod / "README.md"),
            "required_inputs": required,
            "optional_inputs": optional,
            "outputs": tf_outputs(mod / "outputs.tf"),
        })

    charts = []
    for chart in find_helm_charts():
        rel = chart.relative_to(ROOT).as_posix()
        meta = chart_meta(chart / "Chart.yaml")
        charts.append({
            "path": rel,
            "name": chart.name,
            "description": meta["description"],
            "app_version": meta["app_version"],
            "keywords": meta["keywords"],
            "required_values": helm_required_values(chart / "values.schema.json"),
            "dependencies": meta["dependencies"],
        })

    json.dump(
        {"tag": current_tag(), "modules": modules, "charts": charts},
        sys.stdout,
        indent=2,
        sort_keys=False,
    )
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
