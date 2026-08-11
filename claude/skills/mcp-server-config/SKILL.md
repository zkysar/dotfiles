---
name: mcp-server-config
description: Use when adding, removing, editing, or debugging an MCP server on this machine, when writing an MCP wrapper script, when an MCP works in Claude Code but not Claude Desktop or Cowork, or when about to edit ~/.claude.json or claude_desktop_config.json.
---

# MCP server config

MCPs must be registered in **two places**:

1. **`~/.claude.json`** — read by Claude Code (CLI). Edit directly; not
   dotfiles-tracked.
2. **`~/Library/Application Support/Claude/claude_desktop_config.json`** — read
   by Claude Desktop and by Claude Cowork. Cowork bridges Desktop's stdio MCPs
   into the Cowork VM via an SDK bridge, so any MCP you want available in Cowork
   must be in the Desktop config. Code-only MCPs (registered only in
   `~/.claude.json`) do not appear in Cowork.

**Keep both configs in sync manually.** There is no automation. The convention
is: if it's in `~/.claude.json`, it should also be in the Desktop config, and
vice versa.

**Paths in both config files must be absolute** — use
`/Users/zachkysar/.claude/mcp-wrappers/<name>`, not `~`. Desktop does not
reliably expand `~`.

Do NOT add `mcpServers` blocks to `~/.claude/settings.json`. Claude Code does
not read MCP config from there; entries are silently ignored.

## Wrapper scripts

Wrapper scripts live in `claude/mcp-wrappers/` in the dotfiles repo
(version-controlled) and are symlinked to `~/.claude/mcp-wrappers/` via
`manifest.toml` + `dots link`.

**Pin npm versions in every wrapper.** Wrappers run with Keychain secrets
exported to their env, so a compromised upstream release has high blast radius.
Use `npx -y <pkg>@<version>`, not unpinned `npx -y <pkg>`. Bumps must be
intentional and reviewed.

## To add a new MCP

1. Drop a wrapper script in `claude/mcp-wrappers/<name>` and commit.
2. Add the `mcpServers.<name>` entry (with absolute path) to `~/.claude.json`.
3. Add the same entry to
   `~/Library/Application Support/Claude/claude_desktop_config.json`.
4. Quit and reopen Claude Desktop.
