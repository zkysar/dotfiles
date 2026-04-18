# Obsidian × Claude Code Integration

**Date:** 2026-04-18
**Status:** Draft — awaiting user approval

## Problem

Claude Code has no reliable, proactive access to the Obsidian vault. Two Obsidian MCPs (`obsidian` and `obsidian-mcp-tools`) are connected but:
- Heavily overlap in capability
- Are not tracked in dotfiles (config lives only in `~/.claude/settings.json`)
- Require permission prompts that interrupt flow
- Are not documented for Claude, so it doesn't know when or how to use them

The Obsidian CLI (official, shipped in Obsidian 1.8+) replaces both MCPs for all needed operations and is callable directly via Bash.

## Goal

Claude proactively reaches into the vault during conversations — surfacing relevant notes, checking daily context, writing well-formed notes — without interrupting the user for permissions, and without any MCP server dependency.

---

## Component 1: CLAUDE.md Addition

A new section added to `claude/CLAUDE.md` (symlinked to `~/.claude/CLAUDE.md`, global across all projects).

### Content

**Vault path:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/main/`

**When to proactively reach into the vault:**
- At the start of a task, search for relevant notes (`obsidian search`)
- When a topic, project, or person is mentioned that likely has a note
- When today's date is relevant, check the daily note
- When writing a new note or appending, consult the vault's `claude.md` for conventions

**CLI reference table** (the ~10 commands Claude needs):

| Operation | Command |
|---|---|
| Search vault | `obsidian search query="<term>"` |
| Read a note | `obsidian read file="<path or title>"` |
| Read today's daily note | `obsidian daily:read` |
| Append to daily note | `obsidian daily:append content="<text>"` |
| Create a note | `obsidian create name="<title>" content="<body>"` |
| Append to a note | `obsidian append file="<title>" content="<text>"` |
| List notes in folder | `obsidian list folder="<folder>"` |
| Read note metadata | `obsidian read file="<title>" metadata` |
| Get all tags | `obsidian tags` |
| Full command reference | `obsidian help` |

**Obsidian must be running** for the CLI to work (it launches automatically if not).

### What this does NOT include

- Vault folder structure (that belongs in the `obsidian-vault` skill)
- Writing style rules (same — skill)

---

## Component 2: settings.json Changes

Two changes to `~/.claude/settings.json`:

### 2a. Allowlist `obsidian` CLI

Add to `permissions.allow`:
```json
"Bash(obsidian *)"
```

This prevents permission prompts on every `obsidian` command, making proactive vault access seamless.

### 2b. Remove both Obsidian MCPs

Remove `obsidian` and `obsidian-mcp-tools` from `mcpServers`. The CLI replaces their read/write/search capabilities. The one capability lost is `show_file_in_obsidian` (opening a file in the Obsidian app UI) — this is rarely needed mid-conversation and can be done manually.

### 2c. Track settings.json in dotfiles

`~/.claude/settings.json` is currently not symlinked from the dotfiles repo. Add to `manifest.toml`:
```toml
[[link]]
src  = "claude/settings.json"
dest = "~/.claude/settings.json"
```

And move the file to `claude/settings.json` in the repo. `settings.local.json` (already gitignored) handles machine-local overrides.

---

## Component 3: Expand the Vault's `claude.md`

The vault already has a conventions file at `<vault>/claude.md`. Rather than a separate skill or slash command, we expand this file with the full conventions spec. CLAUDE.md then instructs Claude to read it before any vault write.

**Why this approach:**
- Single source of truth, editable directly in Obsidian
- No skill/command file to keep in sync with the vault
- The instruction in CLAUDE.md is what makes it "automatic" — Claude reads it before writing, not on user invocation

**Instruction added to CLAUDE.md:** "Before creating or appending to any vault note, read `<vault>/claude.md` for conventions."

### Expanded `claude.md` content

**Directory structure**
- `journals/` — daily entries (`YYYY-MM-DD.md`)
- `inbox/` — new/unsorted capture notes
- `archive/` — older content
- `meeting-notes/` — meeting notes (free-form, no strict template)
- `books/` — book notes and summaries
- `recipes/` — recipes
- `music/` — music-related notes and drafts
- `templates/` — Obsidian templates (do not write here)
- `japanese/` — language learning notes
- `Projects/` — project-level notes
- `Excalidraw/` — diagrams (do not write here)

**File naming conventions**
- All files: `kebab-case.md`
- Daily notes: `YYYY-MM-DD.md` — no exceptions
- Encode document type in the folder, not the filename: `music/lyrics/song-name.md` not `song-name-lyrics.md`
- No spaces, no capitals in filenames

**Frontmatter schema**
Daily notes:
```yaml
---
date: YYYY-MM-DD
type: daily
tags:
  - journal/daily
---
```
Meeting notes: no required frontmatter — use title as filename, free-form body.
New notes (non-daily): include `date` and `type` at minimum; add tags if note fits existing tag hierarchy.

**Writing style**
- Casual, first-person, stream-of-consciousness for journals — don't clean up or formalize
- Meeting notes: `##` headings per topic, bullet points for details, bold for key terms
- No emoji in vault notes
- Wikilinks for internal references: `[[note-title]]`
- Flat prose over nested bullets for journal entries

**Anti-patterns**
- Do not create files in `templates/` or `Excalidraw/`
- Do not use CamelCase or spaces in filenames
- Do not add elaborate frontmatter to meeting notes
- Do not reformat journal entries — preserve the user's raw voice
- Do not create duplicate notes — search first
- Do not place notes in vault root — always use the appropriate subdirectory

---

## Out of Scope

- `/daily-canvas` command (not changing)
- Granola → Obsidian sync (separate project, already planned in worktree)
- Obsidian plugin configuration
