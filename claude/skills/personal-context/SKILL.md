---
name: personal-context
description: Use when you need declared facts about Zach — fitness preferences, addresses, working hours, recurring patterns, relationships, or any standing preference for how Claude should behave with him. Invoke at the start of any workflow that personalizes output (week planning, scheduling, errand suggestions, etc.).
---

# Personal context

You're being invoked because the current task needs declared facts about Zach.
Read the file below and use what's relevant.

## Where the facts live

**Single source of truth:** `~/.claude/context/personal.md`

Read it now if you haven't already this session. It's sectioned by topic:
- Working hours
- Fitness
- Addresses
- Recurring patterns
- Relationships
- Preferences for Claude

Pull only the sections you need; don't dump the whole file into responses.

## Context vs. memory

This skill maps to **declared facts** — things Zach told Claude.

**Learned patterns** (things Claude observed across sessions) live separately
in the memory system at:
`~/.claude/projects/-Users-zachkysar-projects-dotfiles/memory/`

If you're looking for "what Zach typically rejects" or "patterns from prior
runs," that's memory, not context. Don't conflate them.

## Keeping the file up to date

When you learn a new declared fact about Zach during a session — an address,
a recurring commitment, a working-hours exception, a relationship, a
standing preference — **propose adding it to the context file**. Use the
confirmation pattern Zach requires:

> "I learned that <X>. Want me to add this to your personal context file
> under the <section> section? It would say: <exact text>."

Only edit the file after explicit "yes." One addition per confirmation. Use
the `Edit` tool with surgical changes — don't rewrite the file.

If a fact looks more like a *pattern Claude noticed* (rejection trends,
preference inferences) rather than something Zach explicitly stated, it
belongs in memory, not context. Be honest about which it is.

## When NOT to use this skill

- Don't invoke for tasks that don't personalize behavior (general code
  reviews, debugging, library questions, etc.)
- Don't invoke just to "see what's in the file" — only when the facts will
  inform the current task
