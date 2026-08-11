---
name: draft-in-editor
description: Use when Zach asks for a prose artifact he will send, publish, or hand-revise (an email, message, post, announcement, letter, spec, agenda, or system prompt), or when he says "draft that", "open it in my editor", "put that in a file", or "I want to edit that". Covers the ~/tmp/draft-<slug>.md convention, the clickable handoff, the `draft` command, and the no-overwrite rule. Do NOT use for code, commit messages, PR descriptions, plans, files that already have a home in a repo, or answers to questions.
---

# Draft in editor

The terminal is fine for reading and bad for editing. When the output is
something Zach will hand-revise, put it in a file and give him a way in.

**Default to a clickable link, not a window.** He is often doing something else
when you finish. A link waits for him; a window interrupts him. Only launch the
editor when he asks for it.

## Fire only if both hold

1. The request names a prose artifact he will send or publish.
2. Its destination is outside this repo and outside the chat.

Judge these from his message, before you generate. Do not gate on output length.
You cannot know it yet, and generating first to measure defeats the purpose.

## Never fire

- Code, commit messages, PR descriptions, test files.
- Anything with a home file in a repo. Edit that file directly. Do not open a
  window over it, and never over a dotfiles-managed `$HOME` symlink: an
  atomic-saving editor replaces the symlink with a regular file.
- Implementation plans. Those go to `~/projects/plans/` per CLAUDE.md.
- Secrets. `~/tmp/CLAUDE.md` advertises `~/tmp` as a scratch dir, so anything
  there is readable by any future Claude session for up to 14 days.
  Non-secret content only.

## Procedure

1. Path is `~/tmp/draft-<slug>.md`. Top level, because the 14-day TTL sweep uses
   `-maxdepth 1` and would otherwise expire a subdirectory wholesale.
2. **Never rewrite a draft in place.** If `draft-<slug>.md` already exists, write
   the revision to `draft-<slug>-v2.md`, then `-v3.md`, and open that. He may
   have unsaved edits in the buffer; overwriting silently destroys either his
   work or yours. Versioning removes the race entirely.
3. `Write` the content.
4. End the turn with the clickable handoff below.

## The clickable handoff

Print both forms. They are clickable in different places and cost one line each:

> Drafted: `/Users/zachkysar/tmp/draft-<slug>.md:1`
> `file:///Users/zachkysar/tmp/draft-<slug>.md`
> Edit and save, then tell me to read it back. Say "open it" for an nvim window.

The `path:line` form is clickable in the Claude Code UI. The `file://` form is
clickable in Ghostty (`link-url = true`) and opens in CotEditor, his default
`.md` handler. Use absolute paths, not `~`, since neither form expands a tilde.

## Only when he asks for the editor

Run `draft <slug>`. It opens `~/tmp/draft-<slug>.md` in a dedicated Ghostty
window running nvim with an RPC socket at `~/.cache/nvim/draft.sock`. Later calls
send the file to that same nvim rather than opening a second window, which is
what keeps a draft from being opened twice.

It takes a slug, never a path, and refuses an invalid slug, a missing file, or an
empty file.

**Never run it when you are a subagent, or when the session is non-interactive**
(`claude -p`, a hook, a launchd job). Concurrent sessions are normal here and
stealing window focus from unrelated work is the worst failure this skill has.
Write the file and print the links instead.

Read its output rather than assuming success. Three outcomes matter:

- `opened new draft window` — a fresh window. Hand off normally.
- `reused existing draft window` — the file went into the window that was
  already open, and **it will not raise itself**. Say so, since he may be
  looking at something else.
- `draft window is busy` — nvim is still starting up. The file is written and
  safe. Tell him to re-run `draft <slug>` in a moment. Do not work around this
  by opening a second window.

## Resuming

- Read the file and work from his version. His edits win over yours.
- If he asks for changes, that is a new version file, not an overwrite.
- If his next message is unrelated, drop the thread. Do not re-read, do not nag.
- When the round-trip is done and the content has a durable home, move it there.
  Otherwise it expires in 14 days.
