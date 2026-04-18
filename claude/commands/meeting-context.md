---
description: Surface recent Granola meeting notes as context
---

Use the Obsidian MCP to search the vault for recent meeting notes and summarize
them for context.

Steps:
1. Use `mcp__obsidian-mcp-tools__list_vault_files` to list files in `Meetings/`
2. Sort by filename (which starts with date) to find the most recent 5
3. Use `mcp__obsidian-mcp-tools__get_vault_file` to read each one
4. Summarize: for each meeting show — date, title, attendees, and 2-3 bullet
   points of key topics or decisions
5. After the summary, note anything that seems relevant to what we're currently
   working on

If no meetings directory exists yet, say so and remind the user to run
`python3 ~/projects/utils/granola-obsidian/sync.py` first.
