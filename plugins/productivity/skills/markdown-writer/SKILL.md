---
name: markdown-writer
description: Write markdown that reads human, not AI slop — READMEs, docs, guides, comments, PR text. Enforces plain words, active voice, short sentences, clean structure, based on ASD-STE100 Simplified Technical English. Use when creating or editing any .md file, writing documentation, or when prose sounds robotic or AI-generated. Applies to prose, never code or identifiers.
---

# Markdown Writer

Write prose that gets to the point and sounds like a person wrote it. The rules below are adapted from ASD-STE100 Simplified Technical English (STE) and applied to everyday markdown. Apply them to every doc. They cover docs, READMEs, PR text, error messages, release notes, comments — never code.

## Words

- One name for one thing. Do not rename the same item mid-doc.
- Pick the short common word: use (not utilize/leverage), start (not begin/commence/initiate).
- No marketing adjectives: seamless, robust, powerful, effortless. Cut them.
- American spelling.

## Verbs

- Active voice. "The parser reads the file", not "the file is read".
- A verb, not a noun phrase. "Analyze the log", not "perform an analysis of the log".
- No stacked hedges. "This improves X", not "it is important to note that this may help to improve X".
- No "-ing" main verb where a simple tense works.

## Sentences

- One idea per sentence. Max ~25 words descriptive, ~20 words for instructions.
- Put a condition before its command: "If the build fails, check the log."

## Punctuation

- No semicolons. Write two sentences.
- No contractions in formal docs. A README can stay casual.

## AI slop — cut on sight

- "It is important to note that…" → state it.
- "This section covers…" → start with the content.
- "As you can see…" → show it, do not narrate it.
- "You might want to consider…" → "Use X when Y."
- "In order to" → "to".
- leverage / utilize / facilitate → use / use / help.

## Markdown delivery

- First sentence carries the point. No throat-clearing.
- Bullets for lists, prose for narrative. Do not bullet a single item.
- Clean heading hierarchy: one `#`, then `##`, then `###`.
- Code blocks get a language tag.
- Descriptive link text, not "click here".
- Tables for structured data only.
- Emoji: none by default. OK for status (✅ ❌ ⚠️), never decoration.

## Self-lint (run before you return the text)

1. Any sentence over the cap? Split it.
2. Any semicolon? Replace with a period.
3. Any contraction? Expand it (formal docs).
4. Passive voice with a known actor? Make it active.
5. "-ing" main verb, nominalization ("perform an analysis"), or phrasal verb ("spin up")? Use a plain verb.
6. Marketing adjective? Cut it.
7. Same thing named two ways? Pick one name.

## Strict mode

For runbooks, safety text, and error messages: cap every sentence at 20 words, no contractions, one instruction per sentence, numbered vertical steps with one action each. Otherwise stay relaxed (STE-flavored, so the text keeps enough range to read naturally).

Write only the requested text. No preamble, no summary, no closing remarks.

---
Rules adapted from ASD-STE100 Simplified Technical English. Free official standard (do not paste it in full; it is copyrighted): <https://asd-ste100.org>
