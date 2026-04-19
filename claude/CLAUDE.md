# Global Rules (Zach)

These apply to every Claude Code session on this machine.

## Obsidian vault

**Vault path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/main/`

**Access policy:**
- Only access the vault when the user explicitly asks — never proactively
- Do not surface journal or daily notes unprompted — these are private
- Before any write or create operation, read `<vault>/claude.md` for conventions

**Obsidian must be running** for the CLI to work (it launches automatically if not).

| Operation | Command |
|---|---|
| Search vault | `obsidian search query="<term>"` |
| Read a note | `obsidian read file="<path or title>"` |
| Read today's daily note | `obsidian daily:read` |
| Append to daily note | `obsidian daily:append content="<text>"` |
| Create a note | `obsidian create name="<title>" content="<body>"` |
| Append to a note | `obsidian append file="<title>" content="<text>"` |
| List notes in folder | `obsidian list folder="<folder>"` |
| Read note metadata | `obsidian read file="<title>" metadata` |
| Get all tags | `obsidian tags` |
| Full command reference | `obsidian help` |

---

## Implementation plans

Save all implementation plans to `~/projects/plans/YYYY-MM-DD-<feature>.md`.

**Do not** save plans inside a project repo's `docs/` (or anywhere in-tree) unless
the plan specifically documents durable architecture of that repo. Plans are
usually scaffolding — they belong outside the code they describe.

This overrides the default in `superpowers:writing-plans` (which saves to
`docs/superpowers/plans/`).

## MCP server config

MCPs must be registered in **two places**:

1. **`~/.claude.json`** — read by Claude Code (CLI). Edit directly; not dotfiles-tracked.
2. **`~/Library/Application Support/Claude/claude_desktop_config.json`** — read by Claude Desktop and by Claude Cowork. Cowork bridges Desktop's stdio MCPs into the Cowork VM via an SDK bridge, so any MCP you want available in Cowork must be in the Desktop config. Code-only MCPs (registered only in `~/.claude.json`) do not appear in Cowork.

Wrapper scripts live in `claude/mcp-wrappers/` in this repo (version-controlled) and are symlinked to `~/.claude/mcp-wrappers/` via `manifest.toml` + `dots link`.

**Paths in both config files must be absolute** — use `/Users/zachkysar/.claude/mcp-wrappers/<name>`, not `~`. Desktop does not reliably expand `~`.

**Keep both configs in sync manually.** There is no automation — the convention is: if it's in `~/.claude.json`, it should also be in the Desktop config, and vice versa.

To add a new MCP:
1. Drop a wrapper script in `claude/mcp-wrappers/<name>` and commit.
2. Add the `mcpServers.<name>` entry (with absolute path) to `~/.claude.json`.
3. Add the same entry to `~/Library/Application Support/Claude/claude_desktop_config.json`.
4. Quit and reopen Claude Desktop.

Do NOT add `mcpServers` blocks to `~/.claude/settings.json` — Claude Code does not read MCP config from there; entries are silently ignored.
