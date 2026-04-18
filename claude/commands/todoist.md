---
description: Invoke BEFORE any Todoist action or Todoist-related reasoning. TRIGGER when the user mentions Todoist, tasks, inbox items, "add to my list," "my todos," groceries, watchlist/backlog queries, or when about to call any mcp__todoist__* tool. Encodes personal conventions — media P1 ≠ urgent, Inbox-as-capture, dead labels, scope boundaries — that change how to interpret the data.
---

# Todoist Coach

You have access to my Todoist via the `mcp__todoist__*` tools (official Doist MCP).
This file is the source of truth for how I use Todoist — read it before doing
anything, and interpret my setup through these conventions, not generic ones.

## Project Taxonomy

- **Inbox** — the only real working project. Everything lands here. Gets stale.
- **To Watch / To Listen / To Read / To Learn** — passive backlogs. P1 here means
  "top of queue / want this," NOT urgent. No due dates.
- **Media** — empty parent container.
- **Meena and Zach** — lightweight nudge channel with my partner. Not a managed
  task list.

## Priority / Due-Date Rules

- **P1 in media projects** = "want this," not urgency. Ignore these when looking
  for things that need attention today.
- **@PT** tasks are P1 with no due date — aspirational routine, not overdue.
- **Recurring Inbox tasks (typically P4)** = aspirational habits. Missing them
  is expected, not a failure signal.
- **Real deadlines** live on one-off Inbox tasks with actual due dates.

## The `today | overdue` Filter Is Noisy

It surfaces media P1 items and aspirational @PT exercises that have no actual
due date. When I ask "what's urgent," filter out media projects and @PT first.

## Label Conventions

**Active:**
`@PT` (physical therapy) · `@Routine` · `@Weekly` · `@self` · `@Project` ·
`@Save_Money` · `@Self_Improvement` · `@groceries` · `@Music` · `@book`

**Dead — flag for cleanup if you see them:**
`@KT` · `@KTLO` · `@equityresearch` · `@Japan` · `@Japan2025` · `@BeforeSF`

## What Todoist IS For

- Quick capture (things from conversations, things to remember)
- Grocery lists
- Media backlogs
- Nudges to Meena
- Aspirational habits/routines
- Staging: "I need to write this somewhere but don't know where yet"

## What Todoist IS NOT For

- Calendar events → stay in calendar
- Email items → stay in email
- Finalized notes → eventually move to Obsidian

**Hard rule: no duplication across systems.**

## Rituals

None formal. I open Todoist ad-hoc. Treat it as a capture buffer, not a plan.

## How You Should Help

**Safe:**
- Add tasks when I mention something in conversation that belongs in Todoist
- Triage/cleanup passes: stale Inbox items, dead labels, noisy filter offenders
- Summarize state when I ask, applying the conventions above (don't treat P1
  media as urgent)

**Ask first before:**
- Completing tasks on my behalf
- Bulk-deleting or mass-editing
- Restructuring projects/sections

**Don't:**
- Assume "overdue" means I'm behind — check if it's a media P1 or @PT first
- Invent new labels or projects without asking
- Duplicate items from calendar/email into Todoist

## When This File Is Stale

I update this file as my Todoist usage evolves. If something in here contradicts
what you see in my actual Todoist (e.g., a label listed as dead is now active,
or a new project exists), tell me — don't silently adapt.
