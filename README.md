# dotfiles

macOS + Linux/WSL dotfiles: shell, tmux, neovim, git, and Claude Code config.
Public repo; no secrets committed. On macOS, secrets live in Keeper
(authoritative) and mirror to macOS Keychain (fast, offline). On Linux/WSL,
secrets are out of scope — GitHub auth goes through the `gh` CLI.

`dots bootstrap` detects the OS and runs the right path; `link`, `doctor`,
`style`, and `push` are cross-platform. `keys` is macOS-only.

## Install — macOS

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

## Install — Linux / WSL

Supported on apt-based distros (Debian/Ubuntu, including Ubuntu-on-WSL). On
other distros, install `git git-lfs neovim tmux fzf jq zsh` plus `gitleaks` and
`gh` via your package manager, then skip to `bin/dots link`.

```bash
git clone https://github.com/zkysar/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles
bin/bootstrap     # apt packages + gitleaks + gh; on WSL also Fira Code +
                  # Windows Terminal styling, and sets zsh as the login shell
gh auth login     # one-time GitHub auth (the git credential helper delegates to gh)
bin/dots link     # symlink everything into $HOME
bin/dots doctor   # sanity check
# open a new terminal — it lands in zsh with the styled prompt
```

Use `bin/dots` / `bin/bootstrap` (not bare `dots`) for the first run: the
dotfiles `bin/` only joins `PATH` once you're in the new zsh shell. GitHub auth
needs `gh` installed and `gh auth login` run — without it, git over HTTPS to
GitHub fails. Secrets (Keeper → Keychain) are macOS-only; `dots keys` is
rejected here.

### Terminal styling (WSL)

`ghostty/config` is the single source of truth for colors and font. On WSL
there's no ghostty, so `dots style` translates that palette into a Windows
Terminal color scheme (`dots-onedark`) and points the Ubuntu profile at it.
`dots bootstrap` runs it automatically; re-run `dots style` after editing
`ghostty/config`. `dots style --print-scheme` prints the derived scheme without
writing anything.

Windows Terminal renders fonts from Windows, not WSL. `dots style` installs
Fira Code per-user on Windows automatically; if that warns or is skipped,
install Fira Code on Windows yourself, then restart Windows Terminal to pick it
up. (`dots style` is a safe no-op on macOS and non-WSL Linux.)

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

## Backups

When `dots link` displaces a real file or directory at a managed destination,
it moves the original to `~/.dotfiles-backup/<ISO-timestamp>/` rather than
deleting it. Each `dots link` run also sweeps that directory and removes
entries older than 30 days, so `.env` files and similar don't accumulate
indefinitely. Pruning errors are non-fatal.

## Adding things

- **A new dotfile category:** drop it in, add a `[[link]]` to `manifest.toml`,
  run `dots link`.
- **A new secret:** create a record in Keeper (title = env var name, value in
  password field), then run `dots keys sync`. Never write values directly into
  the repo.
- Shell config is shared with the NAS toolbox (`homelab/toolbox`); keep `shell/zsh/common.zsh` portable.

## Secrets scan

`bin/test` includes a secrets-pattern scan and runs at three layers:
pre-commit (via `core.hooksPath` → `git/hooks/`), pre-push (same delegation),
and CI (`.github/workflows/secrets-scan.yml`). A `--no-verify` commit still
gets caught at push or in CI.

See [CLAUDE.md](CLAUDE.md) for more detail.
