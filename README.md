# dotfiles

macOS dotfiles: shell, tmux, neovim, git, and Claude Code config. Public repo;
no secrets committed. Secrets live in Keeper (authoritative) and mirror to
macOS Keychain (fast, offline).

## Install (new machine)

```bash
git clone https://github.com/zkysar/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles
dots bootstrap    # Homebrew + packages (git, neovim, tmux, fzf, jq, keepercommander)
dots link         # symlink everything into $HOME
keeper login      # one-time Keeper auth
dots keys sync    # pull ENV_VAR_STYLE-titled records from Keeper into Keychain
```

Open a new terminal. Shell reads secrets from Keychain; Claude Code picks up
`~/.claude/*` via the symlinks.

## Secrets model

Keeper is the source of truth. Any Keeper record whose title matches
`^[A-Z][A-Z0-9_]+$` (env var style, e.g. `TODOIST_API_TOKEN`) is synced to
Keychain by `dots keys sync` and exported by zshrc at shell start. No local
manifest to maintain — create a record in Keeper, run `sync`, open a new
terminal.

## Daily use

- Edit any symlinked file — the edit lands in this repo automatically.
- `dots doctor` prints drift.
- Commit in this repo after every meaningful change.
- New shells show a one-line nag if there's uncommitted drift.

## Adding things

- **A new dotfile category:** drop it in, add a `[[link]]` to `manifest.toml`,
  run `dots link`.
- **A new secret:** create a record in Keeper (title = env var name, value in
  password field), then run `dots keys sync`. Never write values directly into
  the repo.

See [CLAUDE.md](CLAUDE.md) for more detail.
