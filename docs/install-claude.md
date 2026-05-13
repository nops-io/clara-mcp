# Installing the Clara Plugin for Claude

## Prerequisites

- Claude Code CLI (`claude`) v2.1.128 or later
- An active nOps account

## Install

1. Download the latest `clara-claude-plugin-v*.zip` from the [Releases](../releases) page.

2. Install the plugin:

   ```sh
   claude plugin install ./clara-claude-plugin-v*.zip
   ```

   Or load it for a single session without installing permanently:

   ```sh
   claude --plugin-dir ./clara-claude-plugin-v*.zip
   ```

3. Confirm the plugin is active:

   ```sh
   claude plugin list
   ```

## Verify

Start a conversation and ask: _"List my Clara datasets."_

Claude will prompt you to authorize with nOps on the first request. See [auth.md](auth.md) for details.

## What's included

| Path | Purpose |
|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest |
| `.mcp.json` | Clara MCP server — auto-registered when the plugin loads |
| `skills/commitment-analysis/` | Commitment analysis skill |
| `skills/query-clara/` | General Clara query skill |

## Uninstall

```sh
claude plugin uninstall clara
```
