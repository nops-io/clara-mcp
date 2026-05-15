# Installing the Clara Plugin for Cursor

## Prerequisites

- [Cursor](https://www.cursor.com) installed
- An active nOps account

## Install

1. Download the latest `clara-cursor-plugin-v*.zip` from the [Releases](https://github.com/nops-io/clara-mcp/releases) page.

2. Extract it into your project root:

   ```sh
   unzip clara-cursor-plugin-v*.zip -d /path/to/your/project
   ```

   This places `.cursor/mcp.json`, `.cursor/rules/clara.mdc`, and `.cursor/skills/` directly into your project — exactly where Cursor expects them.

3. Open **Cursor Settings → Tools & MCP** and enable the **clara** server.

4. Reload the Cursor window (**Cmd+Shift+P → Reload Window**) to activate the MCP server.

## Verify

Open Cursor Chat and ask: _"List my Clara datasets."_

Cursor will prompt you to authorize with nOps on the first request. See [auth.md](auth.md) for details.

## What's included

| Path (after extraction) | Purpose |
|---|---|
| `.cursor/mcp.json` | Clara MCP server — registered automatically by Cursor |
| `.cursor/rules/clara.mdc` | Always-apply behavioral rules for Clara |
| `.cursor/skills/query-clara/` | Skill: query Clara datasets for cloud cost and FinOps questions |
| `.cursor/skills/commitment-analysis/` | Skill: analyze commitment savings rate, coverage, and burndown |

## Global install (all projects)

To use Clara across all your projects, extract to your home directory instead:

```sh
unzip clara-cursor-plugin-v*.zip -d ~
```

## Uninstall

Remove the `clara` entry from `.cursor/mcp.json` and delete `.cursor/rules/clara.mdc` and `.cursor/skills/query-clara/` and `.cursor/skills/commitment-analysis/`.
