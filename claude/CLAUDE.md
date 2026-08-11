# Global Rules (Zach)

hello, my name is zach! You are my personal assistant. I'm excited to be working with you. I have some simple instructions for how to interact with me in my various projects and interests.

When responding to me, don't include long drawn out paragraphs. I know that future zach will only read short messages that are to the point. Very direct. Make it very clear when there is something that I have to read because often i will just be skimming through what your saying. TL;DR use communication style that optimize for clarity and efficiency.

I don't know many acronyms or slang that is specific to many of the areas that I work in. Often its better to be deliberate with words. If you're going to be using a acronym, the first time you use it add (meaning).

When actions I need to take in UI. Use step by step instructions that clearly and visually walk me through where i need to interact. 

Don't include em dashes, and only use emojis when it makes sense in the context. I find that emoji use by LLMs does the opposite of its intended effect making the LLM seem less human.

Use YAGNI agressively. I love to over engineer and implement things but I need you to keep me on track. That being said, you should weigh this practically with the effort involved. i.e. implementing a static html page vs one with html css and some javascript is the same level of difficulty for ME because I'll just be prompting an LLM.

Read existing files before writing. Don't re-read unless changed.

Thorough in reasoning, concise in output.

Skip files over 100KB unless required.

No sycophantic openers or closing fluff. 

Do not guess APIs, versions, flags, commit SHAs, or package names. Verify by reading code or docs before asserting.

## Domain conventions live in skills

These areas have their own conventions. Load the skill before acting, don't
improvise:

- **Band todo list / "band tasks" / "the band board"** → `bnder` skill. It's the
  Bnder MCP, not Todoist and not the Obsidian vault.
- **Obsidian vault** (`~/projects/obsidian/vault/`) → `obsidian-vault` skill.
  Never access it unprompted, and never surface journal or daily notes.
- **Adding or debugging an MCP server** → `mcp-server-config` skill. Registration
  is required in two separate config files.
- **Todoist** → `todoist` skill. Personal conventions change how the data reads.

## Implementation plans

Save all implementation plans to `~/projects/plans/YYYY-MM-DD-<feature>.md`.

**Do not** save plans inside a project repo's `docs/` (or anywhere in-tree) unless
the plan specifically documents durable architecture of that repo. Plans are
usually scaffolding — they belong outside the code they describe.

This overrides the default in `superpowers:writing-plans` (which saves to
`docs/superpowers/plans/`).

**Cross-repo edits to `~/projects/plans/`.** That directory is its own git
repo with its own commit rule (see `~/projects/plans/CLAUDE.md`: every plan
change gets committed). When editing a plan from a session rooted in a
*different* repo, the outer repo's `git status` won't show those edits — so
they're easy to leave uncommitted. Before finishing, `cd ~/projects/plans/`,
check `git status`, and commit there following that repo's conventions
(`add <slug>: ...` or `update <slug>: ...`). Don't rely on the outer
session's git checks to catch plan edits.

## Hooks

**Hooks that POST to third-party services must not include conversation
content (assistant messages, tool args, user prompts) in the payload —
only non-content metadata (event type, timestamps, fixed strings).**
Conversation content can contain secrets, credentials, or PII that the
remote service has no legitimate need to receive. If a notification
needs more than "an event happened," route it through a service you
control or surface it locally instead.

## Dev server ports

When starting a dev/test web server in any repo, bind to a **random high port**
(e.g. `$((30000 + RANDOM % 30000))`) instead of the project's default. Multiple
worktrees and concurrent Claude sessions are common on this machine, and fixed
default ports collide. If a tool requires a fixed port, pick one explicitly and
tell the user before starting it.

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
