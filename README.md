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
      "url": "https://bedrock-agentcore.us-west-2.amazonaws.com/runtimes/arn%3Aaws%3Abedrock-agentcore%3Aus-west-2%3A757559217499%3Aruntime%2FnOpsClaraAgentCore_Mcp-dGV1WrGQ5a/invocations?qualifier=DEFAULT"
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
