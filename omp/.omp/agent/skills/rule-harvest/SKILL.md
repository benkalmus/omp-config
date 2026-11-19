---
name: rule-harvest
description: Collect the user's review annotations (TODO/FIX/WARN/NOTE/INFO/BUG, including decision notes) from any repository, triage their origin, discuss ambiguous clusters and rule conflicts with the user, and propose global lessons for ~/.omp/agent/RULES.md, managed skills, or memory. Waits for approval before editing.
---

# Rule harvest

Turn the user's code review annotations into the global ruleset. The annotations are evidence; the deliverable is portable judgment that applies to every repository and every domain. You read and report. You do not edit `RULES.md`, managed skills, memory, or any source file until the user approves the proposal.

## Annotation semantics

The repository's own `AGENTS.md` defines what its markers mean. Read that section first; local definitions win and the harvest maps them, it does not relabel them. A repository may add markers the table below does not list, and may reuse a name with a different meaning.

Default mapping when the repository is silent:

| Marker | Local meaning | Harvest type |
|---|---|---|
| `NOTE:` | Something the reader should know. | comment or naming rule, or a repo fact |
| `INFO:` | Highlight something important. | rarely a global rule; repo fact or emphasis |
| `TODO:` | Deferred work, possibly a feature cut from an MVP. | scope or decision rule, often repo debt |
| `WARN:` | Critical code, encroaching complexity, handle with care. | guard or boundary rule |
| `BUG:` / `FIX:` | A defect that needs fixing; detailed. | wrong-pattern rule with defect evidence |
| `NOTE(decision):` | A judgment call: the approach and why the alternatives lost. | decision rule |

Scoped forms such as `TODO(pkg):` are aliases and collect the same way. `NOTE(decision)` is an extension the harvest recognizes even where the repository does not define it; the decision marker is the highest-value input because it carries judgment the other markers only imply.

Markers are temporary review annotations by default. Remove them after the rules are extracted, unless the user says to keep them, and follow the repository's own convention when it says otherwise.

## Triage

Markers arrive from three origins. Classify every hit before clustering:

- **Review annotation** for this harvest: the strongest signal.
- **Pre-existing debt**: written before the learning practice, or unrelated to the current review.
- **Agent-written**: a task marker an agent left under the repository's instructions. It may encode a rule, contradict one, or be bookkeeping.

Raise every questionable marker with the user: ambiguous meaning, stale context, agent authorship, unknown marker, or conflict with an existing rule. Never drop a marker silently. Report the counts: review, debt, agent-written, unresolved.

## Collect

Run the search from the repository root:

```sh
rg -n --no-heading 'TODO:|FIX:|WARN:|NOTE:|INFO:|BUG:' -g '!node_modules/**' -g '!vendor/**' -g '!.git/**' <paths>
```

In a large repository, bound the harvest before searching: the review diff or file list when the user provides one, otherwise explicit paths. Ask for a bound when the repository is large and none was given. State the bound in the proposal so the user sees what was not harvested.

Add any other generated tree to the exclusions. Read the matched range of each hit so you understand the finding in context. `rg` alone is not enough context.

Annotations often cover more than formatting: package boundaries, file layout, dependency direction, ownership, error flow, and when to extract or inline. Read enough surrounding code to recover the lesson, not only the line.

Pre-existing markers in the codebase sweep into the harvest too. Treat them as data: the approval gate, not the regex, decides what becomes a rule. Separate markers written for this review from older debt when the clustering is ambiguous, and say which is which.

## Cluster

Group annotations by the lesson they imply, not by file or repository:

- The same weakness in several places is one rule with many evidence rows.
- A one-off finding still becomes a candidate rule because the user marked it.
- Separate deferred work (`TODO`) from defect findings (`BUG` / `FIX`). A deferral often supports a scope or decision rule; a defect supports a wrong-pattern rule.
- `WARN` maps to a guard or a boundary rule; `INFO` usually stays informational.
- `NOTE` maps to a comment, naming, or repo-fact lesson; `NOTE(decision)` maps to a decision rule.

## Discuss

Discussion happens before any proposal. One annotation often implies several lessons, and the user holds the context that separates them. Treat the discussion as the main work of the harvest, not a formality.

For each cluster, present a compact block:

- **Evidence**: the `file:line` rows and the marker text.
- **Inferred lesson**: your reading, one sentence.
- **Adjacent lessons**: other rules the same evidence suggests, each phrased as a question.
- **Edge cases**: conditions, exceptions, or domains where the rule would misfire.
- **Conflict**: an existing `RULES.md` bullet this contradicts or overlaps, quoted with its section.

Ask targeted questions and batch them. Challenge the user's instruction when it over-generalizes, contradicts an existing rule, or cannot pass the portability test. Name the specific evidence and the cost of the wrong reading. When the user overrides a conflict or answers a doubt, record the decision in the proposal so the next harvest does not reopen it.

The user may expand a cluster: one comment can seed several rules. Offer the expansions you see and let the user confirm which are global, which are repo-specific, and which are not rules at all.

Close the phase when the user says the clusters are settled. Only then generalize and propose.

## Generalize

State each lesson as a portable rule. The portability test:

- The rule text names no repository, package, file, or symbol. Those live in the evidence column only.
- The rule states a condition and an action ("When X, do Y"), not a story about one codebase.
- Language-specific mechanics stay language-specific and are marked as such.

A lesson learned in a Go project is offered globally in two forms when both exist:

- The domain-neutral rule goes into the nearest general section.
- The Go mechanics go under `Go idioms`, prefixed as Go-only, with the general rule cross-referenced.

A lesson that cannot survive the portability test is not global. Classify it instead as repo-specific and propose the repository's `AGENTS.md`, naming the files it covers.

## Classify

| Destination | Holds | Written by |
|---|---|---|
| `~/.omp/agent/RULES.md` | Normative rules every session and subagent follows. Global scope only. | Edit the repo copy `omp/.omp/agent/RULES.md` after approval. |
| Managed skill | A repeatable procedure, setup sequence, or debugging recipe. | `manage_skill` after approval. |
| Long-term memory | A durable fact, project decision, or preference that informs without binding. | `learn` after approval. |
| Repository `AGENTS.md` | Guidance that only makes sense inside one repository. | Edit that repository after approval. |

`RULES.md` reaches subagents; `AGENTS.md` does not. Any rule a subagent must follow belongs in `RULES.md`. Repository guidance that does not generalize goes to that repository's `AGENTS.md`, never to `RULES.md`.

## Dedupe and cost

Every `RULES.md` line is injected into every session and every subagent. Treat each new bullet as a permanent token cost.

- Search `RULES.md` for the lesson's concept before proposing it. A lesson already covered becomes a `covered, no change` row, not a synonym bullet.
- Merge into an existing bullet when the wording carries both ideas.
- Name contradictions with existing bullets and propose replace or remove, not coexistence.
- Propose at most five new bullets per harvest unless the user asks for more. Prefer one sharp bullet over three narrow ones.

## Propose

After the clusters are settled, write the proposal to `local://rule-harvest-<date>.md` and show it to the user. Use this shape per rule:

| # | Lesson | Type | Evidence | Destination | Proposed wording | Conflict |
|---|---|---|---|---|---|---|

- `Lesson` is one sentence, stated as the code or decision should read after the fix.
- `Type` is `missing-pattern`, `wrong-pattern`, `guard`, `comment`, or `decision`.
- `Evidence` is every `file:line` that supports the rule.
- `Destination` is a `RULES.md` section, `managed skill`, `memory`, or `<repo> AGENTS.md`.
- `Proposed wording` is the exact bullet text, short enough to merge.
- `Conflict` names an existing bullet this replaces or contradicts, or `none`.

Also propose:

- Merge and deletion candidates when the harvest touches an existing concept.
- The decisions and overrides from the discussion, with the reason, so the reasoning survives the harvest.
- The cleanup step listing every annotation line to remove, after the user approves.
- Which rules were already covered, so the user sees what the harvest did not add.

## Gate

Show the proposal and stop. Wait for the user to approve, edit, or reject each rule. Only after approval:

1. Edit `RULES.md` one section at a time, keeping the existing format and tone.
2. Create or update a managed skill with `manage_skill` for approved procedures.
3. Store approved facts with `learn`.
4. Remove the approved annotation markers, one file at a time, running the tests after each.
5. Re-read `RULES.md` and confirm no duplicated bullets and no orphaned wording.

Never add a rule the user rejected, and never strengthen a rule beyond the evidence.
