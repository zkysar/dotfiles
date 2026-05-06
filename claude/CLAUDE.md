# Global Rules (Zach)

These apply to every Claude Code session on this machine.

## Obsidian vault

**Vault path:** `~/projects/obsidian/vault/`

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

- **Pin npm versions in every wrapper.** Wrappers run with Keychain secrets exported to their env, so a compromised upstream release has high blast radius. Use `npx -y <pkg>@<version>` (not unpinned `npx -y <pkg>`); bumps must be intentional and reviewed.

**Paths in both config files must be absolute** — use `/Users/zachkysar/.claude/mcp-wrappers/<name>`, not `~`. Desktop does not reliably expand `~`.

**Keep both configs in sync manually.** There is no automation — the convention is: if it's in `~/.claude.json`, it should also be in the Desktop config, and vice versa.

To add a new MCP:
1. Drop a wrapper script in `claude/mcp-wrappers/<name>` and commit.
2. Add the `mcpServers.<name>` entry (with absolute path) to `~/.claude.json`.
3. Add the same entry to `~/Library/Application Support/Claude/claude_desktop_config.json`.
4. Quit and reopen Claude Desktop.

Do NOT add `mcpServers` blocks to `~/.claude/settings.json` — Claude Code does not read MCP config from there; entries are silently ignored.

## Hooks

**Hooks that POST to third-party services must not include conversation
content (assistant messages, tool args, user prompts) in the payload —
only non-content metadata (event type, timestamps, fixed strings).**
Conversation content can contain secrets, credentials, or PII that the
remote service has no legitimate need to receive. If a notification
needs more than "an event happened," route it through a service you
control or surface it locally instead.

## Dotfiles

Dotfiles repo: `~/projects/dotfiles/`. Many paths under `$HOME` (shell, tmux,
nvim, git, claude/, launchd plists, etc.) are symlinks into it. `manifest.toml`
in the repo is the authoritative list.

**Before editing any config in `$HOME`:** run `readlink -f <path>`. If it
resolves into `~/projects/dotfiles/`, edit the repo source and commit there —
don't edit the `$HOME` path as if it were standalone.

**Before writing a new config file in `$HOME`:** ask whether it should live in
the dotfiles repo (tracked via `manifest.toml` + `dots link`) before creating
it at the `$HOME` path. Default to asking — most durable configs belong in the
repo.

**Secrets:** API keys, tokens, and passwords are stored in Keeper (source of
truth), synced one-way into macOS Keychain, and exported as env vars by zshrc
at shell startup. Never write a secret into any file. Claude is denied from
invoking `keeper` directly — when a new secret is needed, ask the user to run
`dots keys add NAME` in their own terminal (it prompts for the value; passing
it on argv would leak to shell history and `ps`). See the dotfiles repo
CLAUDE.md for the full flow.
