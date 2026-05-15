# Installing the Clara Plugin for Claude

## Prerequisites

- Claude desktop app or Claude Code CLI (`claude`) v2.1.128 or later
- An active nOps account

## Install

1. Download the latest `clara-claude-plugin-v*.zip` from the [Releases](https://github.com/nops-io/clara-mcp/releases) page.
2. In Claude, go to **Settings → Plugins** and click the **+** next to Personal plugins.
3. Select the downloaded `.zip` file.
4. Clara will appear in the left sidebar under Personal plugins.

## Install — Claude Code

Alternatively, install via the Claude Code CLI:

```sh
claude plugin install ./clara-claude-plugin-v*.zip
```

Or load it for a single session without installing permanently:

```sh
claude --plugin-dir ./clara-claude-plugin-v*.zip
```

To keep the plugin up to date as new versions are released:

```sh
claude plugin update clara
```

## Connect the MCP server

After installing, the Clara MCP connector must be connected before you can query data:

1. Open the Clara plugin in the sidebar and go to **Connectors**.
2. Click **Install** next to the `clara` connector.
3. Follow the OAuth prompt to authorize with your nOps account.

Once connected, the center panel will show the available Clara tools. See [auth.md](auth.md) for more on authentication.

## Verify

Start a conversation and ask: _"List my Clara datasets."_

## What's included

| Path | Purpose |
|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest |
| `.mcp.json` | Clara MCP server — registered automatically when the plugin loads |
| `skills/commitment-analysis/` | Commitment analysis skill |
| `skills/query-clara/` | General Clara query skill |

## Uninstall

**Desktop app** — right-click Clara in the sidebar and select Remove.

**CLI:**
```sh
claude plugin uninstall clara
```
