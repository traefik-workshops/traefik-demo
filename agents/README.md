# agents/

Tool-agnostic mirror of agent assets, paired with the [`AGENTS.md`](../AGENTS.md) convention.

The canonical files live under [`.claude/`](../.claude/). This directory contains git symlinks so any agent that follows the cross-tool `agents/` convention (OpenAI Codex, Cursor, Gemini CLI, ...) can discover them without needing to know the Claude-specific path:

- [`agents/skills/`](./skills) → `../.claude/skills/` — `new-module`, `new-chart`, `bump`, `sa-assistant`
- [`agents/commands/`](./commands) → `../.claude/commands/` — `/extract-scenario`, `/preflight`, `/build-poc`, `/snapshot-poc`

There is **one source of truth**: the files under `.claude/`. Edit there.

## Skill / command formats

The `SKILL.md` files use Claude Code's frontmatter convention (`name:` / `description:`). Other tools that don't read the frontmatter can still consume the Markdown body — the body is the actual prompt / instructions. Commands under `commands/` are plain Markdown.

## On the symlinks

Git stores these as symlinks (mode `120000`). On macOS / Linux they resolve transparently. On Windows you may need `git config --global core.symlinks true` before cloning, or developer mode enabled. If a contributor reports a broken `agents/` directory on Windows, that's the fix.
