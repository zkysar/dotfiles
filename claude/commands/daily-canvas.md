# Daily Canvas Generator

Generate today's task canvas by combining Todoist tasks + daily note todos into a 2x2 matrix (Urgent/Not Urgent × Easy/Hard).

**Usage:** `/daily-canvas`

---

You will:

1. Get today's date in YYYY-MM-DD format
2. **Fetch Todoist tasks due today** - use find-tasks-by-date with startDate='today', daysCount=1. Extract just task titles/content.
3. **Read today's daily note** from Obsidian at `journals/YYYY-MM-DD.md`
   - If it doesn't exist, create it with proper frontmatter first
   - Extract all task items - they appear as indented/nested lists (not necessarily starting with `-` or `*`, just whitespace-indented sections with tasks)
   - Skip canvas embeds and prose
4. **Combine tasks**: Deduplicate tasks from both sources
5. **Create canvas JSON** with 4 quadrants:
   - Urgent + Easy
   - Urgent + Hard
   - Not Urgent + Easy
   - Not Urgent + Hard
   - Plus staging area, labels, and task nodes
6. **Write canvas file** to `journals/canvas/YYYY-MM-DD.canvas` (create subdirectory if needed)
7. **Update daily note**: Embed `![[canvas/YYYY-MM-DD.canvas]]` at the bottom if not already there

Use this reference canvas structure but adapt the quadrant labels:
```json
{
  "nodes":[
    {"id":"staging","type":"group","x":620,"y":-400,"width":320,"height":800,"color":"6","label":"Tasks"},
    {"id":"q-urgent-easy","type":"group","x":-540,"y":-400,"width":520,"height":380,"color":"4","label":"Urgent + Easy"},
    {"id":"q-urgent-hard","type":"group","x":20,"y":-400,"width":520,"height":380,"color":"3","label":"Urgent + Hard"},
    {"id":"q-noturgent-easy","type":"group","x":-540,"y":40,"width":520,"height":380,"color":"5","label":"Not Urgent + Easy"},
    {"id":"q-noturgent-hard","type":"group","x":20,"y":40,"width":520,"height":380,"color":"1","label":"Not Urgent + Hard"},
    {"id":"label-easy","type":"text","text":"**← EASY**","x":-540,"y":-490,"width":140,"height":40},
    {"id":"label-noturgent","type":"text","text":"**↓ NOT URGENT**","x":-30,"y":430,"width":190,"height":50},
    {"id":"label-hard","type":"text","text":"**HARD →**","x":400,"y":-490,"width":140,"height":40},
    {"id":"label-urgent","type":"text","text":"**↑ URGENT**","x":-30,"y":-495,"width":190,"height":50}
  ],
  "edges":[]
}
```

Report: number of Todoist tasks, daily note todos, and total tasks placed in canvas.
