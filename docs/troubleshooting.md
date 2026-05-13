# Troubleshooting

## Authentication

**"Not authorized" or auth prompt loops**

Sign out of nOps in your browser, sign back in, then re-trigger Clara in your AI client to get a fresh authorization prompt.

**Session expired**

Clara sessions expire after a period of inactivity. Just follow the next auth prompt to re-authorize.

## MCP connection

**"Clara MCP server not found" or tools not available**

- Confirm the `.mcp.json` file is in the correct location for your client (plugin root for Claude, or added to Cursor MCP settings).
- Restart your AI client after installing or updating the plugin.
- Check that `https://bedrock-agentcore.us-west-2.amazonaws.com/runtimes/arn%3Aaws%3Abedrock-agentcore%3Aus-west-2%3A757559217499%3Aruntime%2FnOpsClaraAgentCore_Mcp-dGV1WrGQ5a/invocations?qualifier=DEFAULT` is reachable from your network (no firewall blocking outbound HTTPS).

**Tools appear but return errors**

- Verify your nOps account has access to the data you're requesting.
- Check the `applied_policies` field in any query response — it may indicate row-level access restrictions.

## Data issues

**Queries return zero rows**

- Savings datasets often exclude the current month. Try shifting your end date back to the first of the current month.
- Verify the date range — daily data queried over a monthly window and monthly data queried over the same window produce very different row counts.

**Unexpected or missing fields**

Field availability varies by tenant configuration and data ingestion state. Run `describe_dataset` on the relevant dataset to see exactly which fields are available to you.

## Still stuck?

Contact nOps support at [support.nops.io](https://support.nops.io) or reach out via the in-app chat.
