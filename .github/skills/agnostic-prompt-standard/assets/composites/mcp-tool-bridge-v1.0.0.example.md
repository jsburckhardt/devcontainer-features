<!-- APS v1.0 — MCP tool bridge example
     This composite asset shows one MCP Tool object, one canonical
     predefinedTools.json entry, one config.json ALIAS mapping, and one APS
     process excerpt that uses the canonical tool id. -->

# MCP tool bridge example

This example shows how to bridge one MCP tool into APS without putting host config in the prompt.

## 1. Raw MCP Tool (`tools/list` result)

```json
{
  "name": "search_docs",
  "title": "Search Docs",
  "description": "Search the documentation site.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search text"
      }
    },
    "required": ["query"]
  },
  "outputSchema": {
    "type": "object",
    "properties": {
      "matches": {
        "type": "array"
      }
    }
  },
  "annotations": {
    "readOnlyHint": true,
    "destructiveHint": false,
    "idempotentHint": true,
    "openWorldHint": true
  }
}
```

## 2. Canonical `predefinedTools.json` entry

```json
[
  {
    "name": "search_docs",
    "displayName": "Search Docs",
    "description": "Search the documentation site.",
    "inputSchema": {
      "type": "object",
      "properties": {
        "query": {
          "type": "string",
          "description": "Search text"
        }
      },
      "required": ["query"]
    },
    "outputSchema": {
      "type": "object",
      "properties": {
        "matches": {
          "type": "array"
        }
      }
    },
    "hints": {
      "readOnly": true,
      "destructive": false,
      "idempotent": true,
      "openWorld": true
    },
    "source": {
      "kind": "mcp",
      "server": "docs",
      "toolName": "search_docs"
    }
  }
]
```

## 3. Host alias in `config.json`

Use `config.json` only when the host exposes a decorated runtime name.

```json
{
  "alias": {
    "mcp__docs__search_docs": "search_docs"
  }
}
```

## 4. APS process excerpt

```text
<process id="lookup_docs" name="Look up docs" args="QUERY: String">
USE `search_docs` where: query=QUERY
CAPTURE RESULTS from `search_docs`
RETURN: RESULTS
</process>
```

## Notes

- `search_docs` is the canonical APS tool id.
- The prompt stays neutral. It does not include transport or host config.
- The host-specific runtime name stays in external config.
- The engine can resolve the alias before tool execution.
