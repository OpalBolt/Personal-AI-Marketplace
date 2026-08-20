---
name: grilling
description: Grill the user relentlessly about a plan, decision, issue, or idea until nothing is silently assumed — rounds of frontier questions, each with a recommended answer. The convergent mode (jam-with-me is the divergent one). Use when the user wants to stress-test their thinking, uses any 'grill' trigger phrase, or wants an issue refined into an implementation-ready spec ('refine issue #123', 'improve this issue', 'clarify issue #X').
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

If the subject is a tracked issue (number or URL), fetch its current text first (`gh issue view`) and grill what's written, not what's remembered.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format each question like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question that depends on another question in this round belongs to the next round.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
