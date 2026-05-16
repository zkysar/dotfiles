# Personal context

This file is read by Claude (via the `personal-context` skill) when it needs
declared facts about Zach. Update freely. Claude is also instructed to propose
additions when it learns new facts during a session — confirm before writing.

**Distinction:** This file is *declared facts* (Zach told Claude). For *learned
patterns* (Claude observed across sessions), use the memory system at
`~/.claude/projects/-Users-zachkysar-projects-dotfiles/memory/`.

---

## Working hours

- Standard: Mon–Fri 9am–5pm Pacific
- Mornings preferred for focus work and errands
- (Add exceptions as they come up)

## Fitness

- Cardio 2x/week, gym 3x/week
- Mon cardio = run; Fri cardio = bike (default 2hr)
- Chest workout goes on PT day only when PT falls on a regular gym day (Tue–Thu). If PT is Mon or Fri, skip chest that week — gym is strictly Tue/Wed/Thu.
- Cook 2 meals/week, groceries 1x/week (~1hr 15, morning preferred)
- Cooking blocks default to 2 hours
- Meals to schedule: breakfast + lunch only (skip dinner)
  - Breakfast: 30 min, before first commitment
  - Lunch: 30 min, at least 1 hour from any workout
- Treat transit events (Lime, etc.) as transit, not conflicts

## Addresses

- **Home:** 555 4th Street, San Francisco
- (Add others as Claude encounters recurring locations — ask before adding)

## Transit times (from home)

- **PT:** ~20 min
- **Ferry Park:** ~15 min each way

## Recurring patterns

- (Seed empty — Claude detects from past 7-day calendar scan and proposes
  additions: bike day, Kai catchups, straw, etc.)

## Tasks to never auto-schedule

These Todoist tasks/categories should never be proposed for calendar
scheduling, even when they look schedulable. Grows as Claude learns —
when Zach rejects a scheduling proposal, ask if it should be added here.

- **PT** — physical therapy lives outside the planner; never auto-schedule
- **groceries** — Todoist task is a context list of items to remember; not a schedulable action
- (More to come)

## Relationships

- (Seed empty — names + context for people who appear in calendar/Todoist)

## Preferences for Claude

- Never add attendees to calendar events without explicit permission
- Always confirm changes one-at-a-time in plain English before executing
- Brief tone; propose → confirm → execute; no fluff
- If a week is overloaded, say so; don't silently drop targets
- Calendar timezone: `America/Los_Angeles` always
- **Default timezone for everyone:** Assume all meeting attendees are in Zach's
  timezone (Pacific) unless explicitly told a person is elsewhere
- **Light social touchpoints** (quick texts, check-ins like "text X") → Todoist
  entry, not calendar event
- **Todoist task additions:** always set `dueString: "today"` so the task
  appears in today's list — otherwise it gets lost. Do NOT pass
  `responsibleUser` for personal Inbox tasks (it errors out; only works on
  shared projects).
