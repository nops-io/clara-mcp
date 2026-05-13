# Authentication

Clara uses OAuth to authenticate your nOps account. Authentication happens automatically the first time you invoke a Clara tool — you will be redirected to nOps to log in, and then returned to your AI client.

## What you need

- An active nOps account
- The Clara plugin installed in your AI client ([Claude](install-claude.md) | [Cursor](install-cursor.md))

## How it works

1. In your AI client, ask Clara anything — for example: _"Show me my cloud costs for last month."_
2. On the first request, your client will prompt you to authorize Clara. Follow the link to complete login via nOps.
3. After authorizing, your session is stored. Subsequent requests do not require re-authentication.

## Re-authenticating

If your session expires or you switch nOps accounts, run the Clara MCP tool again and follow the authorization prompt, or sign out and back in to nOps in your browser first.

## Troubleshooting auth issues

See [troubleshooting.md](troubleshooting.md).
