# ~/tmp

Scratch space for temporary files. Managed by dotfiles.

## TTL

Every file here is automatically deleted 14 days after it was last modified.
The sweep runs daily at 9am via launchd (`com.zachkysar.tmp-sweep`).
If the machine is asleep at 9am, the sweep runs at next wake.

## Usage

Drop any file here that you want to keep short-term:
- Backups before migrations
- Downloaded files you haven't processed yet
- Scratch exports, zips, logs

No action needed — it expires automatically.

## What is NOT deleted

- Symlinks (this CLAUDE.md is a symlink from dotfiles)
- The CLAUDE.md file itself

## Manual sweep

```bash
~/projects/dotfiles/shell/tmp-sweep
```

## Logs

Sweep output: `/tmp/tmp-sweep.log`
Errors: `/tmp/tmp-sweep-error.log`

## launchd job

```bash
launchctl list | grep tmp-sweep          # confirm it's loaded
launchctl start com.zachkysar.tmp-sweep  # run immediately
```
