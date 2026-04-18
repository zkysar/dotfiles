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

MCP servers are registered in `~/.claude.json` (machine-state, not dotfiles-tracked).
The dotfiles repo manages the **wrapper scripts** in `claude/mcp-wrappers/` —
those are what `~/.claude.json` entries point to. Do NOT add `mcpServers` blocks
to `~/.claude/settings.json` (the dotfiles-managed file) — Claude Code does not
read MCP config from there, the entries are silently ignored.

To add a new MCP:
1. Drop a wrapper script in `claude/mcp-wrappers/<name>` (commit to dotfiles)
2. Edit `~/.claude.json` directly to add the `mcpServers.<name>` entry pointing
   to `~/.claude/mcp-wrappers/<name>`
