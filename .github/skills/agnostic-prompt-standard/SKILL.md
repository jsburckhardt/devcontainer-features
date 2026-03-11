---
name: agnostic-prompt-standard
description: The reference framework to generate, compile, and lint greenfield prompts that conform to the Agnostic Prompt Standard (APS) v1.0.
license: MIT
metadata:
  repository: "https://github.com/chris-buckley/agnostic-prompt-standard"
  author: "Christopher Buckley"
  co_authors: "Juan Burckhardt; Anastasiya Smirnova"
  spec_version: "1.0"
  framework_revision: "1.1.16"
  last_updated: "2026-02-18"
---

# Agnostic Prompt Standard (APS) v1.0 — Skill Entry

This `SKILL.md` is the **entrypoint** for the Agnostic Prompt Standard (APS) v1.0.

- The APS **normative spec** is in `references/` (those documents define the standard).
- Everything else in this repository is **supporting material** (examples, templates, platform adapters).

## Normative spec (APS v1.0)

1. [00 Structure](references/00-structure.md)
2. [01 Vocabulary](references/01-vocabulary.md)
3. [02 Linting and formatting](references/02-linting-and-formatting.md)
4. [03 Agentic control](references/03-agentic-control.md)
5. [04 Schemas and types](references/04-schemas-and-types.md)
6. [05 Grammar](references/05-grammar.md)
7. [06 Logging and privacy](references/06-logging-and-privacy.md)
8. [07 Error taxonomy](references/07-error-taxonomy.md)

## Skill layout

- `SKILL.md` — this file (skill entrypoint).
- `references/` — the APS v1.0 normative documents (this is what an LSP/linter should ingest).
- `assets/` — reusable examples for `<format>` and `<constants>` blocks.
  - `constants/` — example constants blocks.
    - `constants-json-block-v1.0.0.example.md`
    - `constants-text-block-v1.0.0.example.md`
    - `constants-csv-block-v1.0.0.example.md`
  - `formats/` — example format blocks.
    - `format-code-changes-full-v1.0.0.example.md`
    - `format-code-map-v1.0.0.example.md`
    - `format-docs-index-v1.0.0.example.md`
    - `format-error-v1.0.0.example.md`
    - `format-hierarchical-outline-v1.0.0.example.md`
    - `format-ideation-list-v1.0.0.example.md`
    - `format-link-manifest-v1.0.0.example.md`
    - `format-markdown-table-v1.0.0.example.md`
    - `format-smeac-plan-v1.0.0.example.md`
    - `format-table-api-coverage-v1.0.0.example.md`
- `_template/` — minimal skill skeleton for scaffolding new skills.
  - `SKILL.md` — stub entrypoint with placeholder frontmatter.
  - `references/`, `assets/constants/`, `assets/formats/`, `processes/`, `scripts/`, `guides/` — empty placeholder directories.
- `processes/` — executable APS process documents (skill-specific workflows).
  - `build-skill.md` — process for building new APS-compliant skills.
- `guides/` — reference documents for humans and agents.
  - `skill-authoring-v1.0.0.guide.md` — skill authoring reference.
- `platforms/` — **non-normative** platform adapters. Each platform has a single `adaptor.md` file.
  - `README.md` — platforms overview and contract.
  - `_template/` — skeleton for new platform adapters.
    - `adaptor.md`
  - `claude-code/` — Claude Code CLI adapter.
    - `adaptor.md` — platform constants, tool registry, and format contracts.
  - `opencode/` — OpenCode adapter.
    - `adaptor.md` — platform constants.
  - `vscode-copilot/` — VS Code + GitHub Copilot adapter.
    - `adaptor.md` — platform constants, tool registry, and format contracts.
- `scripts/` — optional build / compile / lint scripts (empty by default).

---

## Platform adapters

Platform-specific details (file discovery, frontmatter dialects, tool naming) are documented in `platforms/`.

→ See [platforms/README.md](platforms/README.md) for overview and how to add new adapters.

### VS Code + GitHub Copilot

The initial adapter for VS Code + GitHub Copilot is at `platforms/vscode-copilot/`.

→ See [platforms/vscode-copilot/adaptor.md](platforms/vscode-copilot/adaptor.md) for platform constants, tool registry, and format contracts.
