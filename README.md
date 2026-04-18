# dotfiles

macOS dotfiles: shell, tmux, neovim, git, and Claude Code config. Public repo;
no secrets committed. Secrets live in Keeper (authoritative) and mirror to
macOS Keychain (fast, offline).

## Install (new machine)

```bash
git clone https://github.com/zkysar/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles
bin/bootstrap     # Homebrew + packages (git, neovim, tmux, fzf, jq, keepercommander, gcalcli, bun)
bin/link          # symlink everything into $HOME
keeper login      # one-time Keeper auth
bin/keys sync     # pull ENV_VAR_STYLE-titled records from Keeper into Keychain
```

Open a new terminal. Shell reads secrets from Keychain; Claude Code picks up
`~/.claude/*` via the symlinks.

Start the claude-mem memory worker so Claude retains context across sessions:

```bash
npx claude-mem start   # runs on http://localhost:37777
```

## Claude Code setup

Claude Code config lives under `claude/` and symlinks into `~/.claude/`:

| Directory | Purpose |
|-----------|---------|
| `claude/settings.json` | Permissions, hooks, plugins, MCP servers |
| `claude/hooks/` | Hook scripts (custom-reminder.py, pushover, etc.) |
| `claude/mcp-wrappers/` | Credential-free MCP launcher scripts (read from Keychain) |
| `claude/commands/` | Slash commands |
| `claude/agents-library/` | Reusable subagent definitions |

### MCP servers

Three MCP servers are pre-configured in `settings.json`:

- **email** — Claude's dedicated Gmail account (`zachkysar.claude@gmail.com`). Requires `CLAUDE_GMAIL_APP_PASSWORD` in Keychain.
- **whoop** — WHOOP fitness data via `~/projects/mcp/whoop-mcp`.
- **hevy** — Hevy workout tracker via `@chrisdoc/hevy-mcp` (npx).

Add new servers by editing `claude/settings.json` or via `.mcp.json` in individual project repos.

### Adding an MCP wrapper

For servers that need credentials: add a launcher script to `claude/mcp-wrappers/`,
pull the secret from Keychain (`security find-generic-password`), and reference the
script in `mcpServers`. Never write credentials directly into `settings.json`.

## Secrets model

Keeper is the source of truth. Any Keeper record whose title matches
`^[A-Z][A-Z0-9_]+$` (env var style, e.g. `TODOIST_API_TOKEN`) is synced to
Keychain by `bin/keys sync` and exported by zshrc at shell start. No local
manifest to maintain — create a record in Keeper, run `sync`, open a new
terminal.

## Daily use

- Edit any symlinked file — the edit lands in this repo automatically.
- `bin/doctor` prints drift.
- Commit in this repo after every meaningful change.
- New shells show a one-line nag if there's uncommitted drift.

## Adding things

- **A new dotfile category:** drop it in, add a `[[link]]` to `manifest.toml`,
  run `bin/link`.
- **A new secret:** create a record in Keeper (title = env var name, value in
  password field), then run `bin/keys sync`. Never write values directly into
  the repo.

See [CLAUDE.md](CLAUDE.md) for more detail.
