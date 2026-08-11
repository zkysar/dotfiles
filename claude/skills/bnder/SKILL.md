---
name: bnder
description: Use when the user says "band todo list", "band tasks", "the band board", "Chez straw", or Bnder, or before calling any mcp__bnder__* tool. Covers the guild and project ids, the numeric kanban status field, deep-link format, Discord assignee ids, and the archive convention. Also use when the bnder MCP fails to connect.
---

# Bnder (band todo list)

"My band's todo list", "band tasks", "the band board", and similar phrasings all
mean the **Bnder** workspace **Chez straw** (Discord guild
`1400172357775134870`), reached through the `bnder` MCP server. Bnder is a
Discord-native task manager. Do not look in Todoist or the Obsidian vault for
these.

## Gotchas that will otherwise cost a round trip

- Nearly every tool requires both `guildId` and `projectId`. Resolve the project
  first via `get-projects` with the guild id above.
- Task `status` is a numeric index into that project's kanban columns, not a
  string. Read column names from `get-project` before setting a status.
- `search-project-contents` searches tasks, events, and documents in one call.
  Prefer it over listing each type separately.
- **Deep links** (undocumented; recovered from the app's own link-copy code in
  `https://bnder.net/app/main.dart.js`):
  `https://bnder.net/app/task/{guildId}/{projectId}/{taskId}` and
  `https://bnder.net/app/knowledge/{guildId}/{projectId}/{documentId}`.
  `projectId` is the task's `board_id`, defaulting to `default`. The app is a
  Flutter SPA that returns the same shell for *every* path under `/app/`, so a
  200 proves nothing. Never "verify" one of these with curl.
- There is no archive state. "Archive" means `update-task` with `in_bin: true`,
  which stamps a `delete_at` 30 days out and then permanently purges.
- Note Claude-made changes on the task itself via `add-comment-to-task`. Every
  write executes as Zach on a board shared with the band, so an unannotated
  change is indistinguishable from one he made by hand.

## Assignee ids

Assignees come back as bare Discord ids and **nothing in the API resolves them
to names**: there is no list-members endpoint, and
`GET /guilds/{guildId}/members/{memberId}` returns only `active_project_id`.

| Discord id | Name | Confidence |
|---|---|---|
| `166793917461692416` | Zach | confirmed |
| `363548832266584071` | Wei | confirmed by Zach |
| `194974359817814016` | Evan | confirmed by Zach |
| `392152472287838208` | Kyle | provisional (inferred from an old task comment) |
| `176872756405731329` | Matt | provisional (Zach's guess by elimination) |

## When the MCP won't connect

`Failed to reconnect to bnder: -32000` means the OAuth token cache is empty or
dead. Read `references/setup.md` in this skill directory for the bootstrap
procedure. Do not improvise it.
