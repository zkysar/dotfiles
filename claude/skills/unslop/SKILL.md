---
name: unslop
description: Cut AI tells from prose so it reads like a person wrote it. Use when writing or revising anything Zach will read or send (a reply in this session, an email, a message, a post, a README, a doc, a commit message, a PR description), and when he says "unslop", "make it sound human", "that reads like AI", or "rewrite that". Do NOT use for code, identifiers, or text quoted from a source.
---

# Unslop

Remove the patterns that make writing obviously machine-generated, then put a
voice back in.

Adapted from `unslop` in [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop).

## Process

1. Scan against the catalog below.
2. Rewrite. Keep the meaning. Match the intended tone.
3. Add voice (next section). Sterile writing is its own tell.
4. Self-audit: "what in this still reads as AI?" Fix what you find.

**Write it clean the first time.** A cleanup pass after the fact catches less
than not generating the bad sentence at all.

## Add voice

- **Have an opinion.** React to a fact instead of neutrally listing pros and cons.
- **Vary the rhythm.** Short sentences land a point. Longer ones carry a fact
  with its condition. Mixing them is what sounds human.
- **Be specific.** Not "this is concerning" but "the sync silently drops rows
  when the API returns 429".
- **Use "I" when it fits.** First person is not unprofessional.
- **Let some mess in.** Perfectly parallel structure looks machine-made.

## The catalog

### Style

1. **No em dashes. At all.** Do not swap in parentheses or an en dash either,
   that trades one tell for another. End the sentence, or use a comma.
2. **No colon as a mid-sentence connector.** A colon before a list or an example
   is fine. "If you're coming from X: instead of Y, you do Z" is not.
3. **No decorative emoji.** In headings, in bullets, as bullets.
4. **Don't bold every proper noun.** Bold marks the thing you'd point at, not
   every noun in the paragraph.
5. **No inline-header lists that restate themselves.** The tell is a bold label
   plus a colon whose text repeats the label: "**Performance:** Performance
   improved by 40%". A bold lead-in that names the item and is followed by
   genuinely new detail is fine.
6. **Sentence case headings.** Not Title Case Like This.
7. **Straight quotes, not curly.**

### Chat artifacts

8. **No sycophantic openers.** "Great question!", "You're absolutely right!",
   "Excellent catch!" Answer the thing.
9. **No closing fluff.** "Hope this helps!", "Let me know if you have any other
   questions!", "Happy to dig deeper!"
10. **No self-congratulation.** "Found the smoking gun!", "Perfect!", "Got it
    working flawlessly!" State what happened and what it means.

### Language

11. **AI vocabulary.** additionally, crucial, delve, enhance, fostering, garner,
    interplay, intricate, landscape (as a metaphor), pivotal, robust, seamless,
    showcase, tapestry, testament, underscore, vibrant. Use the plain word.
12. **Fancy ways to say "is".** "serves as", "stands as", "boasts", "features".
    Say "is" or "has".
13. **"Not just X, but Y."** State the point directly.
14. **Forced rule of three.** Use the natural number of items, not three.
15. **Synonym cycling.** Do not call one thing "the sync", "the pipeline", and
    "the ingestion flow" in one paragraph. Pick one name and repeat it.
16. **False ranges.** "from X to Y" where X and Y are not on a scale. Just list
    the things.
17. **Puffery.** "pivotal moment", "a testament to", "evolving landscape",
    "sets the stage for". Say what actually happened.
18. **Vague attribution.** "experts believe", "some argue", "reports suggest".
    Name the source or cut the claim.

### Jargon

19. **Abstract metaphor nouns.** substrate, wedge, vector, locus, nexus,
    primitive (as a noun), surface (as in "API surface"), bedrock, scaffolding
    (as a metaphor), paradigm, flywheel, north star, endgame, ratchet, evacuate
    (for moving code). These sound technical and almost always have a plainer
    concrete word. "Substrate" is "base". "Wedge in" is "add". "Vector" is
    "way". "Evacuate" is "move out". Pick the concrete word.
20. **Expand an acronym on first use.** Per CLAUDE.md. "RLS (row-level
    security)", then "RLS" after that.

### Filler

21. **Filler phrases.** "in order to" is "to". "due to the fact that" is
    "because". "it is important to note that" is nothing, delete it.
22. **Stacked hedging.** "could potentially possibly be argued that it might" is
    "may". One hedge maximum, and only when the uncertainty is real.
23. **Generic conclusions.** "The future looks bright." "This sets us up well."
    State a specific next step or say nothing.

### Plain speech

24. **Say what it does, not how it feels.** "the database stays close at hand"
    names a feeling. "`.toSQL()` returns the exact string sent to the database"
    names a mechanism. If you cannot restate a sentence as a concrete fact,
    instruction, or number, cut it. Second check: if the sentence would read
    identically in a different project's docs, it says nothing about this one.
25. **One idea per sentence.** If the reader has to backtrack to parse it, split
    it or drop a clause.
26. **Active voice.** Catch "is/are/was/were + past participle" and name the
    actor. "queries are validated" becomes "the compiler validates queries".
    Passive is fine only when the actor is genuinely unknown.
27. **Cut the adverb or use a better verb.** "runs quickly" is "is fast", or the
    number. An adverb propping up a weak verb means the verb is wrong.
28. **Prefer the plain word.** utilize is use. leverage is use. facilitate is
    help. numerous is many. in the event that is if.

## Where this does not apply

- Code, identifiers, file paths, commands, and log output.
- Text quoted from a source. Quote it as written.
- A direct quote of someone else's words.

Rules 1, 3, and 8 through 10 are also stated in CLAUDE.md, in one line, because
they have to hold on every turn whether or not this skill loads. They are
repeated here in full so this file works as a standalone checklist.

## When a rule makes it worse

The rules serve the reader. A sentence that obeys every rule and still sounds
machine-written has failed. Fix it another way, or leave it alone.
