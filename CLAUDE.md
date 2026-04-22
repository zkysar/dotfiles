# Working in this repo

This is a unified dotfiles repo. Every tracked file under a category directory
(`shell/`, `tmux/`, `nvim/`, `git/`, `claude/`) is symlinked into `$HOME` per
`manifest.toml`. Editing a live file in `$HOME` is the same as editing the
file in this repo — the symlink makes them one.

## Layout

- `manifest.toml` — source of truth for which repo paths link to which `$HOME` paths
- `dots link` — create symlinks. Safe to run repeatedly.
- `dots unlink` — remove managed symlinks (does not restore backups)
- `dots doctor` — report symlink health and uncommitted drift
- `dots bootstrap` — install Homebrew packages and load dotfiles-managed LaunchAgents
- `dots keys` — Keeper → Keychain one-way sync (`add` / `list` / `sync` / `rm`)

## Adding a new LaunchAgent

1. Create `launchd/<label>.plist` in the repo (use `com.zachkysar.*` label convention).
2. Add an entry to `manifest.toml`:
   ```toml
   [[link]]
   src  = "launchd/<label>.plist"
   dest = "~/Library/LaunchAgents/<label>.plist"
   ```
3. Run `dots link` to create the symlink, then `launchctl load ~/Library/LaunchAgents/<label>.plist`.
4. On a fresh machine, `dots bootstrap` handles the load automatically after `dots link` is run.
5. Commit.

## Adding a shell function

Shell functions live in `shell/functions/`, one file per function (`<name>.zsh`). `zshrc` auto-sources every `*.zsh` file in that directory — drop a file in and it's available on next shell start. No `manifest.toml` entry needed; files are sourced directly from the repo path.

1. Create `shell/functions/<name>.zsh` with the function definition.
2. Commit.

The syntax checker (`bin/test` suite 2) covers `shell/functions/` automatically via `find shell/ -type f`.

## Adding a new dotfile category

1. Create a top-level dir for the category (e.g. `vscode/`).
2. Drop the files in.
3. Add an entry to `manifest.toml`:
   ```toml
   [[link]]
   src  = "vscode/settings.json"
   dest = "~/Library/Application Support/Code/User/settings.json"
   ```
4. Run `dots link`.
5. Commit.

## Adding a new secret

Never write a secret value into any file in this repo.

Convention: Keeper is the source of truth. Any Keeper record whose title
matches `^[A-Z][A-Z0-9_]+$` (env var style, e.g. `TODOIST_API_TOKEN`) gets
synced into Keychain and exported by zshrc.

In your own terminal (Claude is denied from invoking `keeper`):

```bash
dots keys add MY_SECRET_NAME secretvalue
```

This creates the Keeper record and syncs to Keychain in one step. Open a new terminal — zshrc exports the new env var automatically.

Alternatively, create the Keeper record manually and run `dots keys sync`.

## Testing

`bin/test` runs three suites: manifest integrity, shell syntax, and secrets scan. It runs automatically as a pre-commit hook (via `core.hooksPath` → `git/hooks/`).

When adding features that touch the manifest, shell files, or introduce new bin scripts with logic, add or extend `bin/test` accordingly. Examples:
- New `manifest.toml` entry → covered automatically by the manifest integrity suite
- New shell file in `shell/` → covered automatically by the syntax suite
- New `bin/` script with meaningful logic → add an integration test case to `bin/test`

## Commit discipline

A symlink means editing `~/.zshrc` immediately changes `shell/zshrc` in this
repo. Check `dots doctor` or `git status` regularly — the shell nag will remind
you on new terminals. Commit in this repo after editing any tracked dotfile.

## Secrets policy

- Never commit API keys, tokens, passwords, or any value from a `.env` file.
- `.gitignore` excludes `claude/hooks/.env`, `claude/settings.local.json`, and
  `shell/keys.sh`. If you add a file that contains secrets, gitignore it AND
  create a `*.template` sibling.
- `claude/mcp-library/.mcp.json` is in-tree if it contains no credentials;
  otherwise it must be gitignored with a `.mcp.json.template` committed.

## Working with git worktrees

Always invoke the `superpowers:using-git-worktrees` skill before creating or using a worktree.

**Dotfiles-specific gotchas:**

- `$HOME` symlinks always point to the **main checkout**, not a worktree. Changes in a worktree are invisible to the live system — you cannot live-test zshrc, MCP configs, or Claude settings from a worktree.
- **Never run `dots link` from inside a worktree.** It would re-point all `$HOME` symlinks at the worktree paths, coupling the live system to a branch that may be deleted.
- Worktrees here are for *structuring and reviewing changes*, not live-testing. Merge to main and relink if a live test is needed.

## Gotcha: empty source directories

`dots link` treats any existing path (file or dir, empty or not) as a valid
source. If you create a repo category directory but haven't populated it,
running `dots link` will still back up the live target and symlink it to the
empty repo dir — appearing to wipe the live content (the real data is safely
in `~/.dotfiles-backup/<ts>/`). Populate repo dirs first, then link.
