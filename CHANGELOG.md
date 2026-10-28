# Changelog

All notable changes to the Clara integrations are documented here.

## Unreleased

- Connect to Clara at `https://mcp.nops.io` instead of the raw AWS endpoint, so clients show the nOps name and icon. Installs still using the old URL keep working; after updating, reconnect the `clara` connector once to sign in against the new URL.
- Initial release of Claude and Cursor plugins
