# Working in this repo

This is a unified dotfiles repo. Every tracked file under a category directory
(`shell/`, `tmux/`, `nvim/`, `git/`, `claude/`) is symlinked into `$HOME` per
`manifest.toml`. Editing a live file in `$HOME` is the same as editing the
file in this repo — the symlink makes them one.

## Layout

- `manifest.toml` — source of truth for which repo paths link to which `$HOME` paths
- `shell/keys.manifest.toml` — names of Keychain entries zshrc exports at shell start
- `bin/link` — create symlinks. Safe to run repeatedly.
- `bin/unlink` — remove managed symlinks (does not restore backups)
- `bin/doctor` — report symlink health and uncommitted drift
- `bin/bootstrap` — install Homebrew packages
- `bin/keys` — Keeper ↔ Keychain sync (`list` / `sync` / `add` / `rm`)

## Adding a new dotfile category

1. Create a top-level dir for the category (e.g. `vscode/`).
2. Drop the files in.
3. Add an entry to `manifest.toml`:
   ```toml
   [[link]]
   src  = "vscode/settings.json"
   dest = "~/Library/Application Support/Code/User/settings.json"
   ```
4. Run `bin/link`.
5. Commit.

## Adding a new secret

Never write a secret value into any file in this repo.

1. `bin/keys add NEW_ENV_VAR "Keeper/record/path"`
2. The script writes to Keychain and appends the manifest entry.
3. Manually add the record to Keeper (Commander `record-add` syntax is fiddly).
4. `bin/keys sync` to verify.

## Commit discipline

A symlink means editing `~/.zshrc` immediately changes `shell/zshrc` in this
repo. Check `bin/doctor` or `git status` regularly — the shell nag will remind
you on new terminals. Commit in this repo after editing any tracked dotfile.

## Secrets policy

- Never commit API keys, tokens, passwords, or any value from a `.env` file.
- `.gitignore` excludes `claude/hooks/.env`, `claude/settings.local.json`, and
  `shell/keys.sh`. If you add a file that contains secrets, gitignore it AND
  create a `*.template` sibling.
- `claude/mcp-library/.mcp.json` is in-tree if it contains no credentials;
  otherwise it must be gitignored with a `.mcp.json.template` committed.

## Gotcha: empty source directories

`bin/link` treats any existing path (file or dir, empty or not) as a valid
source. If you create a repo category directory but haven't populated it,
running `bin/link` will still back up the live target and symlink it to the
empty repo dir — appearing to wipe the live content (the real data is safely
in `~/.dotfiles-backup/<ts>/`). Populate repo dirs first, then link.
