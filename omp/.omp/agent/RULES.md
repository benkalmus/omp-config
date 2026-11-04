# Global rules

These rules apply to every session and every subagent, in every repository. They are stowed to `~/.omp/agent/RULES.md` from `pi-config`.

`AGENTS.md` beside this file reaches the main session only. omp does not pass a file named `AGENTS.md` into spawned agents, and does pass this one. Rules a subagent must follow belong here.

Repository-specific guidance belongs in that repository's `AGENTS.md`.

Go-specific guidance below applies to Go repositories. Skip it elsewhere.

## Writing style

- Write each sentence to its natural end. Do not wrap paragraphs.
- Prefer short lists over paragraphs when giving steps or options.
- Prefer short sentences. Split a sentence at 20 words.
- Use active voice. Write "The script deletes the file", not "The file is deleted by the script".
- Keep one term per thing. Do not rotate synonyms for the same action.
- State the action directly. Write "Run the script", not "You should run the script".
- Name the referent instead of a pronoun that could mean two things.
- Explain with code and context, not metaphor.
- End on the fact, not on commentary. A trailing `-ing` clause is a defect.
- State the condition and the action instead of `never` and `always`.
- Avoid these words: delve, tapestry, leverage, robust, seamless, pivotal, crucial, multifaceted, underscore, foster, bolster, navigate, realm, landscape, testament, facilitate, streamline.
- Avoid these shapes: "It's not X, it's Y", "not only X but also Y", rule of three, "No X. No Y. Just Z.", a rhetorical question followed by its answer.
- Do not nominalize. Write "launch the runner", not "the runner, launched".

## Punctuation

- No em dashes. Start a new sentence, or use parentheses for a short aside.
- Limit semicolons. Start a new sentence instead.
- Prefer periods.

## File editing

- Read a file before editing it. This applies most to configs, JSON, YAML, and files the user changed.
- Use `edit` for existing files. Use `write` for new files and full replacements only.
- Read the target again before a full rewrite. Keep a copy of the prior content when the change is large.

## Security

- Treat `.env`, `secrets.*`, SSH keys, and credentials as hidden. Do not read them.
- Do not read or print a secret to reason about it. Ask for the shape of the value instead.
- Do not run `sudo`. Do not run commands as root.
- Do not dump the environment with `env` or `printenv`.
- Report a blocked action and its reason. Do not route around it with another tool, a command alias, or a script file.

## Shell

- No inline scripts: no `python -c`, no `node -e`, no heredocs. Write a file or use the `eval` tool.
- No `git commit --no-verify`. Hooks validate the change.
- Forced removal (`rm -f`, `rm -rf`, `rm -fr`) needs approval.
- Warn the user before a command that takes minutes or more.
- Use `--info=progress2` with rsync.
- Build paths from variables and config. Do not hardcode an absolute path.

## Git

- Do not push, pull, fetch, rebase, merge, cherry-pick, or reset --hard.
- Commit locally. Leave history rewriting and remote work to the user.

## Verification

- After a change, read the file back and check the logs.
- `make test` before implementation, to pin expected behavior.
- `make cover` after implementation, to prove the behavior.
- `make lint`, `make vet`, and `make build` before calling the work done.
- Track `make loc` and `make line` before and after. A swelling diff is a red flag.

## Documentation

- Link to source as `https://github.com/<org>/<repo>/blob/<branch>/<path>#L<line>`.

## Go idioms

```go
var wg sync.WaitGroup
for _ = range n {
	wg.Go(func() {
		// work
	})
}
wg.Wait()

var bufPool = sync.Pool{
	New: func() any { return &bytes.Buffer{} },
}
buf := bufPool.Get().(*bytes.Buffer)
buf.Reset()
defer bufPool.Put(buf)

var registry sync.Map
registry.Store(key, val)
v, ok := registry.Load(key)

g, ctx := errgroup.WithContext(ctx)
g.SetLimit(10)
g.Go(func() error { return doWork(ctx) })

s := semaphore.NewWeighted(10)
s.Acquire(ctx, 2)
defer s.Release(2)

var sf singleflight.Group
result, err, shared := sf.Do("cache-key", func() (any, error) {
	return expensiveFetch(ctx)
})

var counter atomic.Int64
counter.Inc()
val := counter.Load()

var started atomic.Bool
if !started.CompareAndSwap(false, true) {
	return
}
```

- Assign one value per line. Write `filepath := items[i].FilePath` and `fileID := items[i].ID`, never both on one line.
- Do not write `f := f` inside a range loop. Go 1.22 does not need it.

## Testing

- Use `t.Context()`, not `context.Background()`.
- Split a table entry across lines. Do not write a one-line table row.
- Follow one skeleton per test:

```go
// Setup
// Action
// Assert
```

- A table-driven test adds the table steps:

```go
// Initial setup
// Define testcases
// For each testcase
// Per testcase setup (optional)
// Action
// Assert
```

- Do not branch between test cases. Do not branch between assertions. Split the test instead.
- Reuse `test/testutil`. Extend a shared mock in place when it lacks a field. Do not fork a copy for one test.
- Prefer `NewTestStore(t)` over a hand-rolled stub. It exercises the real query path.
- Two cases that differ only in a magic string are one case.

## Code simplicity

- Keep cyclomatic complexity low. One function does one thing. Split before branching grows.
- Change the fewest lines that solve the problem.
- Use guard clauses and early returns. A new branch becomes a new function.
- Reuse before creating. Check for an existing struct, helper, or utility first.
- Keep identity-carrying strings lowercase at rest. Display casing happens at the boundary.
- Two enums that differ only by case are one vocabulary written twice. Collapse them. No mapping layer between identical concepts.
- Do not carry an anonymous struct across a boundary, and do not pass a closure that another function unpacks.
- Prefer a direct call over a wrapper around a wrapper.
- Measure touched files with gocyclo. New code stays at or below the complexity it replaces.
- Report file duplication as a finding, at the top of the report.

## Comments

- One sentence, no manual wrapping.
- A doc comment starts with the name and states what the function returns or does.
- A comment earns its place when it states a consequence or the non-obvious condition behind the code.
- Restating the code is not a comment.
- Use `NOTE:`, `INFO:`, `TODO:`, `WARN:`, and `BUG:` only when the fact is non-obvious and a reader would misread the code. The full policy is in `AGENTS.md`.

## Naming

- Function names start with a verb: `LoadAll`, `NormalizeKey`.
- Short scope takes a short name: `i`, `key`, `r`. Long scope takes a descriptive name.
- Do not encode the type in the name: `key`, not `keyString`.
- Do not use `data`, `info`, `tmp`, `res`, `manager`, `helper`, or `util`.
- Bool names read as assertions: `ok`, `found`, `valid`.
- Sentinel errors use `Err`. Initialisms keep case: `ID`, `URL`, `HTTP`.
- A package name is not repeated in its contents.
- A one-method interface uses the method plus `-er`.

| Weak | Strong |
|---|---|
| `func handleData(raw []byte) (User, error)` | `func DecodeUser(raw []byte) (User, error)` |
| `keyString` | `key` |
| `// This function loads the record.` | `// Load returns the record for key.` |
| `// Increment the counter.` | delete |

## Enforcement

These rules are enforced by omp, not by instruction alone:

- `.env` reads, `env` and `printenv` dumps, `sudo`, inline scripts, `--no-verify`, and all remote Git operations are denied by `bash.patterns` in `~/.omp/agent/config.yml`.
- `rm -f`, `rm -rf`, and `rm -fr` are denied. Set `tools.approvalMode: always-ask` and change those entries to `prompt` if you want confirmation instead of refusal.
- Use the `ask` tool when a request is ambiguous or a design decision changes the outcome. Do not proceed on an unstated assumption.
- A denial appears as a tool error. Report it. Do not retry it with different spelling.
