# dotfiles

macOS dotfiles: shell, tmux, neovim, git, and Claude Code config. Public repo;
no secrets committed. Secrets live in Keeper (authoritative) and mirror to
macOS Keychain (fast, offline).

## Install (new machine)

```bash
git clone https://github.com/zkysar/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles
bin/bootstrap     # Homebrew + packages (git, neovim, tmux, fzf, jq, keepercommander)
bin/link          # symlink everything into $HOME
keeper login      # one-time Keeper auth
bin/keys sync     # pull secrets from Keeper into Keychain
```

Open a new terminal. Shell reads secrets from Keychain; Claude Code picks up
`~/.claude/*` via the symlinks.

## Daily use

- Edit any symlinked file — the edit lands in this repo automatically.
- `bin/doctor` prints drift.
- Commit in this repo after every meaningful change.
- New shells show a one-line nag if there's uncommitted drift.

## Adding things

- **A new dotfile category:** drop it in, add a `[[link]]` to `manifest.toml`,
  run `bin/link`.
- **A new secret:** `bin/keys add NAME "Keeper/path"` — never write values
  directly into the repo.

See [CLAUDE.md](CLAUDE.md) for more detail.
