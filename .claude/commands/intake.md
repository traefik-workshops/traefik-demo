# Intake

Normalize raw prospect material into a clean, unified document ready for signal extraction. First step of every PoC workflow.

## Invocation

```
/intake <path-or-glob> [--workdir <output-dir>]
```

Examples:
```
/intake fixtures/example-1/transcript.md
/intake ~/downloads/nexovault/                              # directory — merge all files inside
/intake ~/downloads/nexovault/*.pdf --workdir /tmp/poc/nexovault
```

`--workdir` sets the output root for this PoC. If omitted, defaults to `~/poc-scenarios/<slug>/`.
All subsequent commands (`/extract-scenario`, `/feasibility-check`, etc.) must use the same workdir.

## Step 0 — Create output working directory

1. Determine output root:
   - If `--workdir <path>` was provided in the prompt: use that path as the PoC root.
   - Otherwise: infer prospect slug from file content (company name, first 20 lines → lowercase, non-alphanumerics → `-`) and use `~/poc-scenarios/<slug>/`.
   - If prospect name is ambiguous: ask SA before proceeding.
2. Create the directory tree:
   ```bash
   mkdir -p <workdir>/intake
   ```
3. All output for this PoC (normalized.md, poc.yaml, manifests/) lives under `<workdir>/`.

Do not proceed until the output directory exists.

## Step 1 — Discover and classify sources

For each file provided:

| Format detected | Treatment |
|---|---|
| Email thread (`.eml`, `.md` with `From:` headers) | Parse thread in chronological order; label each message with sender and date |
| Call transcript (`.md`, `.txt` with speaker labels) | Keep speaker attribution; identify SA vs prospect turns |
| Slack export (`.json`, `.md` with channel format) | Flatten to chronological messages; strip reactions/metadata |
| PDF | Extract text; flag if OCR quality is poor |
| Mixed (multiple formats in one file) | Split by document boundary; classify each section |

## Step 2 — Merge and deduplicate

If multiple files or sections provided:

1. Merge into one unified document ordered by date (oldest first).
2. Apply authority rule: **call notes > email > Slack**. When the same fact appears in multiple sources, keep the most authoritative version and note the source.
3. Flag contradictions explicitly: *"Email says no GPU; call notes say GPU available Q3."*
4. Remove duplicates (same content forwarded / copy-pasted across files).

## Step 3 — Write normalized output

Write the unified document to:
```
<workdir>/intake/normalized.md
```

Format of `normalized.md`:
```markdown
# Intake — <Prospect Name>

**Sources:** <list of original files>
**Normalized:** <date>

---

## [Email thread — <date range>]

<merged email content, sender-labeled>

---

## [Call transcript — <date>]

<transcript content, speaker-labeled>

---

## [Contradictions flagged]

- <fact>: <source A says X>, <source B says Y> → using <source B> (authority rule)
```

## Step 4 — Append to poc.yaml

Create `<workdir>/poc.yaml` if it doesn't exist. Append:

```yaml
intake:
  prospect_slug: <slug>
  workdir: <workdir>
  sources:
    - { path: <original-path>, type: <email-thread|transcript|slack|pdf|mixed> }
  normalized_path: <workdir>/intake/normalized.md
  contradictions:
    - { fact: "<fact>", sources: ["<A> says X", "<B> says Y"], resolved: "<B> (authority rule)" }
```

`workdir` is written once here so all subsequent commands can read it from `poc.yaml` without needing the flag again.

## Rules

- Do not extract signals or map modules — that is `/extract-scenario` and `/feasibility-check` scope.
- If a file cannot be read or parsed, report it and skip — do not stop the whole run.
- Never discard source material — write normalized output alongside originals, not instead of them.
