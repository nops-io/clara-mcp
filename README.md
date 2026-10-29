# Clara MCP Plugins

Install packages and setup guides for connecting Clara to Claude, Cursor, and other AI clients.

## Supported clients

| Client | Install guide |
|---|---|
| Claude | [docs/install-claude.md](docs/install-claude.md) |
| Cursor | [docs/install-cursor.md](docs/install-cursor.md) |

## Standalone MCP setup

The Claude and Cursor plugins above include the MCP server config and register it automatically. If you're using a different MCP-compatible client, add the following manually:

```json
{
  "mcpServers": {
    "clara": {
      "type": "http",
      "url": "https://mcp.nops.io"
    }
  }
}
```

**Claude Code** — add to `.mcp.json` in your project root, or to `~/.claude/mcp.json` for global access.

**Cursor** — add to `.cursor/mcp.json` in your project root, or to `~/.cursor/mcp.json` for global access.

**Gemini CLI** — `gemini extensions install https://github.com/nops-io/clara-mcp`

**Other clients** — consult your client's MCP documentation for where to place server configuration.

Clara is also published to the [official MCP Registry](https://registry.modelcontextprotocol.io/v0.1/servers?search=io.github.nops-io/clara) as `io.github.nops-io/clara` (see [`server.json`](server.json)).

Clara authenticates via OAuth on first use. See [docs/auth.md](docs/auth.md) for details.

## Authentication

Clara authenticates via OAuth on first use. See [docs/auth.md](docs/auth.md).

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md).
