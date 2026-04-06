# Platforms

APS is designed to be **platform-agnostic**, but real hosts (IDEs, agent runtimes, CI bots) differ in:

- File discovery conventions (where prompts, agents, and skills live)
- YAML frontmatter dialects (which fields exist and which are optional)
- Tool availability, naming, and approval UX
- Safety constraints (auto-approve settings, restricted file paths)
- Multi-agent orchestration surfaces (how a coordinator invokes workers)

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
      # no templates/             # (generic / external tools)
```

The `adaptor.md` file contains three APS sections:

1. `<instructions>` — platform-specific generation instructions
2. `<constants>` — metadata such as platform ID, detection markers, file conventions, subagent depth policy, and tool registries
3. `<formats>` — frontmatter and output format contracts

The `generic/` adapter is the neutral option for tool-agnostic or external-tool-only workflows.
It has no detection markers and no installable templates.

## Subagent authoring contract

Adapters should document the host-specific orchestration surface for coordinator and worker authoring.
At minimum, an adapter should state:

- which artifact type is the coordinator
- which artifact type is the worker
- which tool or surface invokes the worker
- the documented depth policy
- how APS worker `<input>` maps to caller dispatch args
- how worker outputs are captured back into the caller

If nested delegation is undocumented, the adapter should default to **portable depth-1 authoring**.
That means one coordinator dispatches leaf workers, and all platform-specific routing stays in the caller dispatch layer.

→ See [`guides/subagent-architecture-v1.0.0.guide.md`](../guides/subagent-architecture-v1.0.0.guide.md)

## Add a new platform adapter

1. Copy `platforms/_template/` to `platforms/<platform-id>/`
2. Fill in `adaptor.md` with platform-specific constants and formats
3. Document coordinator/worker roles, dispatch surface, and depth policy
4. Optionally add a `templates/` directory with installable agent files
5. Do **not** change `references/` unless you are intentionally publishing an APS spec revision

## Contract

- Anything under `references/` is **normative** APS.
- Anything under `platforms/` is **non-normative** (documentation, templates, and mappings only).
- Adapters should prefer **mapping + configuration** over rewriting APS core rules.

## Scope and philosophy

Adapters are intended to **map** the APS standard to a host platform. They are **not** project generators.
We do not provide generic project scaffolding (like `settings.json` or root `CLAUDE.md` templates).

> See [ADR 0001: Adapter Scope](https://github.com/chris-buckley/agnostic-prompt-standard/blob/main/docs/adr/0001-adapter-scope-no-scaffolding.md)
