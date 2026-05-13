# Clara Integrations

Public install packages and setup guides for connecting Clara to Claude Code, Cursor, and other AI clients.

This repository contains the client-facing integration assets for Clara.

The packages in this repo connect supported AI clients to Clara’s hosted MCP endpoint and provide client-specific skills, rules, and setup documentation.

## Supported clients

- Claude Code
- Cursor

## Repository structure

```text
clara-integrations/
  README.md

  docs/
    install-claude.md
    install-cursor.md
    auth.md
    troubleshooting.md

  packages/
    claude/
      .claude-plugin/
        plugin.json
      .mcp.json
      README.md

    cursor/
      .cursor-plugin/
        plugin.json
      .mcp.json
      README.md
      rules/
        clara.mdc

  shared/
    skills/
      commitment-analysis/
        SKILL.md
      query-clara/
        SKILL.md

  scripts/
    package-all.sh
    package-claude.sh
    package-cursor.sh

  dist/