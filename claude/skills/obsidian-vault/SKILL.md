---
name: obsidian-vault
description: Use when the user asks about their Obsidian vault, a note, a daily note, a journal entry, or asks to search, read, create, or append to notes, or before running any `obsidian` CLI command. Covers the vault path, the CLI command table, and the access policy.
---

# Obsidian vault

**Vault path:** `~/projects/obsidian/vault/`

## Access policy

- Only access the vault when the user explicitly asks. Never proactively.
- Do not surface journal or daily notes unprompted. These are private.
- Before any write or create operation, read `<vault>/claude.md` for conventions.

**Obsidian must be running** for the CLI to work (it launches automatically if
not).

## Commands

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
