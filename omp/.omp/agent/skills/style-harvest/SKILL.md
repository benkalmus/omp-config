---
name: style-harvest
description: Collect the user's review annotations (TODO/FIX/WARN/NOTE style markers), cluster them into inferred rules, and propose a STYLE.md plus critic-style checks. Waits for approval before editing.
---

# Style harvest

Collect the user's annotations from a repository, cluster them into rules, and propose a style guide the critics can enforce. You read and report. You do not edit `STYLE.md`, `RULES.md`, or any source file until the user approves the proposal.

## Annotation convention

The user annotates review findings as line or block comments:

| Marker | Meaning |
|---|---|
| `TODO:` | A missing pattern or convention the code should follow. |
| `FIX:` | A wrong pattern the code should be corrected to. |
| `WARN:` | A risk the code should guard against. |
| `NOTE:` | Intent or non-obvious context a reader needs. |

Scoped forms such as `TODO(style):` are accepted aliases and collect the same way.

These are temporary review markers, not normal code comments. Remove them after the rules are extracted, unless the user says to keep them.

## Collect

Run the search from the repository root:

```sh
rg -n --no-heading 'TODO:|FIX:|WARN:|NOTE:' -g '!node_modules/**' -g '!vendor/**' -g '!.git/**'
```

If the repository uses other exclusions (`dist`, `target`, generated trees), add them to the glob list.

Pre-existing `TODO:` comments in the codebase sweep into the harvest too. Treat them as data: the proposal gate, not the regex, decides what becomes a rule. Separate markers written for this review from older debt when the clustering is ambiguous, and say which is which in the proposal.

Read the matched range of each hit so you understand the finding in context. `rg` alone is not enough context.

## Cluster

Group annotations by the rule they imply, not by file:

- Same weakness found in several places is one rule with many evidence rows.
- One-off findings still become a candidate rule if the user marked them.
- Separate missing-pattern (`TODO`) from wrong-pattern (`FIX`) findings. A rule can cover both, but state the difference.
- `WARN(risk)` maps to a guard or boundary rule. `NOTE(intent)` maps to a comment or naming rule.

## Propose

Write the proposal to `local://style-harvest-<date>.md` and show it to the user. Use this shape per rule:

| # | Rule | Type | Evidence | Proposed STYLE.md section | Proposed critic check |
|---|---|---|---|---|---|

- `Rule` is one sentence, stated as the code should read after the fix.
- `Type` is `missing-pattern`, `wrong-pattern`, `guard`, or `comment`.
- `Evidence` is every `file:line` that supports the rule.
- `Proposed STYLE.md section` names the section the rule belongs in (naming, errors, tests, comments, structure, dependencies, security, performance).
- `Proposed critic check` names what `critic-style` would grep or read to enforce it.

Also propose:

- The full draft `STYLE.md` content, ordered by section.
- Any rule that conflicts with `~/.omp/agent/RULES.md`, with the conflict named.
- A cleanup step listing every annotation line to remove, after the user approves.

## Gate

Show the proposal and stop. Wait for the user to approve, edit, or reject each rule. Only after approval:

1. Write the approved `STYLE.md` at the repository root (or the path the user names).
2. Remove the approved annotation markers, one file at a time, running the tests after each.
3. Name the follow-up: dispatch `critic-style` in the author-critic loop with the new guide.

If the repository already has a `STYLE.md`, diff your proposal against it and name the additions and conflicts instead of overwriting it.
