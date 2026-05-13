# Clara Integrations

Install packages and setup guides for connecting Clara to Claude, Cursor, and other AI clients.

## Supported clients

| Client | Install guide |
|---|---|
| Claude | [docs/install-claude.md](docs/install-claude.md) |
| Cursor | [docs/install-cursor.md](docs/install-cursor.md) |

## Standalone MCP setup

To connect Clara to any MCP-compatible client without installing a full plugin, add the following to your client's MCP configuration:

```json
{
  "mcpServers": {
    "clara": {
      "type": "http",
      "url": "https://mcp.clara.nops.io/mcp"
    }
  }
}
```

**Claude Code** — add to `.mcp.json` in your project root, or to `~/.claude/mcp.json` for global access.

**Cursor** — add to `.cursor/mcp.json` in your project root, or to `~/.cursor/mcp.json` for global access.

**Other clients** — consult your client's MCP documentation for where to place server configuration.

Clara authenticates via OAuth on first use. See [docs/auth.md](docs/auth.md) for details.

## Authentication

Clara authenticates via OAuth on first use. See [docs/auth.md](docs/auth.md).

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md).
