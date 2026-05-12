# Markdown Document Questions

Ask only relevant questions based on what you already know from context. If the answer is obvious, skip the question.

## When to Use Which Questions

### Always Ask (if not obvious from context)
These clarify the fundamentals:

**What's the document's primary purpose?**
- What should readers be able to do after reading this?
- Is this a reference, guide, tutorial, or overview?

Skip if: Document type is obvious (e.g., README.md, CONTRIBUTING.md)

**What must be included?**
List the essential information that cannot be omitted.

Skip if: User already specified exact content needed

### Ask When Audience is Unclear

**Who's the audience?**
- Are they already familiar with the topic?
- What level of detail do they need?
- Are they scanning or reading deeply?

Skip if: Audience is clear from context or project type

### Ask for Complex/Long Documents

**What would be nice to have but isn't critical?**
Identify content that could be:
- Moved to a separate file
- Linked externally
- Omitted entirely

Skip if: Document is clearly short/simple

**Should this be one file or multiple?**
If multiple:
- How should files be split? (by topic, by depth, by audience)
- Where should they live? (doc/, root, docs/)

Skip if: Clearly single-purpose/short document

**How should content be organized?**
- Linear flow (do A, then B, then C)?
- Reference lookup (scan headings, jump to section)?
- Problem-solution pairs?

Skip if: Organization is obvious from document type

### Ask When Context Exists

**Are there existing documents to reference or replace?**
- What conventions should we follow?
- What patterns work well in similar docs?
- What should change from the old approach?

Skip if: New project with no existing docs

### Ask When Examples Are Relevant

**What examples would be most valuable?**
- Real-world use cases?
- Common commands/operations?
- Before/after comparisons?

Skip if: Document is purely conceptual or examples are obvious

### Ask for Measurable Outcomes

**What's the success metric?**
- Can someone complete X task in Y minutes?
- Reduces support questions about Z?
- Onboards new users faster?

Skip if: Success criteria are obvious or informal doc

### Ask When There Are Constraints

**Are there any specific requirements or constraints?**
- Must follow specific style guide?
- Integration with existing docs?
- Company/project conventions?

Skip if: No special requirements mentioned

## Example Contexts

**Context: "Create a README for this new CLI tool"**
Ask only:
1. What must be included? (if not in existing code/context)
2. What examples would be most valuable?

Skip: Audience (CLI users), purpose (README), structure (standard README flow)

**Context: "Document this complex API with 50+ endpoints"**
Ask:
1. Who's the audience? (internal devs vs public API?)
2. Should this be one file or multiple?
3. How should content be organized?
4. What examples would be most valuable?

Skip: Purpose (API reference), must-include (endpoints themselves)

**Context: "Write installation guide for enterprise users"**
Ask:
1. Are there existing docs to reference?
2. What's the success metric?
3. Are there specific requirements? (security, compliance)

Skip: Audience (enterprise users), purpose (installation)

## Using the Answers

After gathering responses:
1. Identify patterns (e.g., audience is experienced → skip basics)
2. Remove anything not serving the primary purpose
3. Structure based on how content will be used
4. Apply KISS principles to what remains
5. Verify against success metric (if defined)
