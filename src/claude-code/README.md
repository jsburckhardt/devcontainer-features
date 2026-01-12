# Claude Code (claude-code)

Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows -- all through natural language commands.

## Example Usage

```json
"features": {
    "ghcr.io/jsburckhardt/devcontainer-features/claude-code:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of Claude Code to install (e.g., 1.0.58 or latest) | string | latest |

## Installation

This feature uses the official Claude Code installation script from https://claude.ai/install.sh which downloads the appropriate binary for your platform from Anthropic's servers.

## Usage

After installation, you can use the `claude` command in your terminal:

```bash
claude
```

For more information, see the [official documentation](https://code.claude.com/docs/en/overview).

---

_Note: you will need to configure Claude Code with your API key after installation. See the [setup documentation](https://code.claude.com/docs/en/setup) for details._
