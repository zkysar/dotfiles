# Working in this repo

This is a unified dotfiles repo. Every tracked file under a category directory
(`shell/`, `tmux/`, `nvim/`, `git/`, `claude/`) is symlinked into `$HOME` per
`manifest.toml`. Editing a live file in `$HOME` is the same as editing the
file in this repo — the symlink makes them one.

## Layout

- `manifest.toml` — source of truth for which repo paths link to which `$HOME` paths
- `bin/link` — create symlinks. Safe to run repeatedly.
- `bin/unlink` — remove managed symlinks (does not restore backups)
- `bin/doctor` — report symlink health and uncommitted drift
- `bin/bootstrap` — install Homebrew packages
- `bin/keys` — Keeper → Keychain one-way sync (`add` / `list` / `sync` / `rm`)

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

Convention: Keeper is the source of truth. Any Keeper record whose title
matches `^[A-Z][A-Z0-9_]+$` (env var style, e.g. `TODOIST_API_TOKEN`) gets
synced into Keychain and exported by zshrc.

In your own terminal (Claude is denied from invoking `keeper`):

```bash
bin/keys add MY_SECRET_NAME secretvalue
```

This creates the Keeper record and syncs to Keychain in one step. Open a new terminal — zshrc exports the new env var automatically.

Alternatively, create the Keeper record manually and run `bin/keys sync`.

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

## Working with git worktrees

Always invoke the `superpowers:using-git-worktrees` skill before creating or using a worktree.

**Dotfiles-specific gotchas:**

- `$HOME` symlinks always point to the **main checkout**, not a worktree. Changes in a worktree are invisible to the live system — you cannot live-test zshrc, MCP configs, or Claude settings from a worktree.
- **Never run `bin/link` from inside a worktree.** It would re-point all `$HOME` symlinks at the worktree paths, coupling the live system to a branch that may be deleted.
- Worktrees here are for *structuring and reviewing changes*, not live-testing. Merge to main and relink if a live test is needed.

## Gotcha: empty source directories

`bin/link` treats any existing path (file or dir, empty or not) as a valid
source. If you create a repo category directory but haven't populated it,
running `bin/link` will still back up the live target and symlink it to the
empty repo dir — appearing to wipe the live content (the real data is safely
in `~/.dotfiles-backup/<ts>/`). Populate repo dirs first, then link.
