# Platforms

APS is designed to be **platform-agnostic**, but real hosts (IDEs, agent runtimes, CI bots) differ in:

- File discovery conventions (where prompts/agents/skills live)
- YAML frontmatter dialects (which fields exist, required/optional)
- Tool availability, naming, and approval UX
- Safety constraints (auto-approve settings, restricted file paths)

This folder contains **platform adapters** that describe those differences *without changing the APS v1.0 spec*.

## Adapter layout

Each platform adapter is a single `adaptor.md` file plus an optional `templates/` directory:

```
platforms/
  _template/                      # skeleton for new adapters
    adaptor.md                    # template adaptor.md
    templates/                    # optional installable agent files
  <platform-id>/
    adaptor.md                    # single source of truth
    templates/                    # optional installable agent files
      .claude/agents/             # (claude-code) or
      .github/agents/             # (vscode-copilot)
```

The `adaptor.md` file contains three APS sections:

1. `<instructions>` — platform-specific generation instructions
2. `<constants>` — all metadata: platform ID, detection markers, file conventions, tool registries, agent versioning
3. `<formats>` — frontmatter and output format contracts

## Add a new platform adapter

1. Copy `platforms/_template/` to `platforms/<platform-id>/`
2. Fill in `adaptor.md` with platform-specific constants and formats
3. Optionally add a `templates/` directory with installable agent files
4. Do **not** change `references/` unless you are intentionally publishing an APS spec revision

## Contract

- Anything under `references/` is **normative** APS.
- Anything under `platforms/` is **non-normative** (documentation/templates/mappings only).
- Adapters should prefer **mapping + configuration** over rewriting APS core rules.

## Scope and Philosophy

Adapters are intended to **map** the APS standard to a host platform. They are **not** project generators.
We do not provide generic project scaffolding (like `settings.json` or root `CLAUDE.md` templates).

> See [ADR 0001: Adapter Scope](https://github.com/chris-buckley/agnostic-prompt-standard/blob/main/docs/adr/0001-adapter-scope-no-scaffolding.md)
