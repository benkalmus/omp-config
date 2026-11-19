# pi-config

Stow package for [omp](https://omp.sh), the `oh-my-pi` coding agent. It mirrors the opencode setup where omp has an equivalent.

## Quick start

```sh
git clone git@github.com:benkalmus/omp-config.git
cd omp-config
make stow
```

## Layout

```text
omp/.omp/agent/AGENTS.md
omp/.omp/agent/APPEND_SYSTEM.md
omp/.omp/agent/RULES.md
omp/.omp/agent/WATCHDOG.md
omp/.omp/agent/WATCHDOG.yml
omp/.omp/agent/config.yml
omp/.omp/agent/keybindings.yml
omp/.omp/agent/agents/critic-behavior.md
omp/.omp/agent/agents/critic-structure.md
omp/.omp/agent/agents/critic-style.md
omp/.omp/agent/agents/subtractor.md
omp/.omp/agent/skills/style-harvest/SKILL.md
```

Stow links each file into `~/.omp/agent/` and `~/.config/hindsight/`. The Makefile passes `--no-folding`, so both parents stay real directories. omp writes databases and caches beside the stowed files.

## Setup

omp needs only the stow in Quick start. The Hindsight memory server needs one more step, after `make stow` has linked `omp/.config/hindsight/` to `~/.config/hindsight/`:

```sh
cp ~/.config/hindsight/.env.example ~/.config/hindsight/.env
# fill in HINDSIGHT_API_LLM_API_KEY=<your OpenRouter key>
docker compose --env-file .env -f ~/.config/hindsight/docker-compose.yml up -d
curl -fsS http://localhost:8888/health
```

Only after the health check returns 200:

```sh
omp config set memory.backend hindsight
omp config set hindsight.apiUrl http://localhost:8888
```

`.env` is gitignored; `.env.example` is tracked. The first image pull is about 9 GB. The server keeps no auth token, so omp needs no key itself; the key lives only inside the container.

## Runtime toggles

| Setting | Effect |
|---|---|
| `bash.gitGuard: true` | In the main checkout, refuses `git stash` (except `list`/`show`/`create`), `reset --hard`, `reset` to another commit, `switch`, branch `checkout`, and path `restore`. In a linked worktree, discarded changes are saved to `refs/omp/discarded` first. |
| `checkpoint.enabled: true` | The `checkpoint`/`rewind` pair: mark investigation state, then collapse it into a report. Conversation state, not filesystem snapshots. |
| `task.isolation.enabled: true` | Task items may set `isolated: true`. Patch merge applies to the parent checkout; a failed merge keeps recovery artifacts. `omp worktree clear --all` removes managed workspaces, including kept-alive leftovers. |
| `prewalk.enabled: true` | New sessions hand off to `@smol` at the first `edit`/`write`. `/prewalk off` cancels live. |
| `autolearn.enabled: true` | Experimental. Lesson-capture guidance, `manage_skill`, and with a memory backend the `learn` tool. Managed skills land in `~/.omp/agent/managed-skills`; any authored skill overrides them. |

## Author-critic loop

The opencode setup has one primary agent and three subagents. omp has no selectable primary agent, so the mapping is:

| opencode | omp | Why |
|---|---|---|
| `implementer` (primary) | `~/.omp/agent/APPEND_SYSTEM.md` | Appended to the main session prompt. Task subagents and advisors do not receive it. |
| `critic-structure` (subagent) | `agents/critic-structure.md` | Read-only task agent, discovered by name. |
| `critic-behavior` (subagent) | `agents/critic-behavior.md` | Read-only task agent with `bash` for test runs. |
| `subtractor` (subagent) | `agents/subtractor.md` | Task agent with `blocking: true`, so it runs in the foreground. |
| style annotations | `agents/critic-style.md` + `skills/style-harvest/SKILL.md` | `critic-style` enforces the repo's `STYLE.md` in the loop; `style-harvest` turns your `TODO(style)`/`FIX(style)`/`WARN(risk)`/`NOTE(intent)` annotations into that guide. |

`async.enabled` defaults to `true`, so the two critics return in the background and the user keeps talking to the implementer. The subtractor declares `blocking: true`, so nothing writes beside it.

The opencode `permissions` block has no omp equivalent. omp restricts a task agent by its `tools` list. The global `bash.patterns` deny list in `config.yml` blocks inline scripts, `.env` reads, and destructive shell for every session. A tool the agent does not hold is unavailable. A shell pattern outside that list is still a contract rule in the agent body, not an enforcement point.

`task.structured` is on in `config.yml`. Each subagent result is available at `agent://<id>` after the spawn returns.

### Advisor

The advisor is not a fourth critic. It attaches to the main session and steers the implementer back to the approved plan while the turn runs. The roster uses `reviewMode: turn`, `reviewInterval: 1`, and `syncBacklog: off`, so it never blocks the final answer. Only a `blocker` interrupts a running turn. A `concern` waits for the next boundary. `modelRoles.advisor` maps to the cheap `smol` model. `critic-behavior` still owns the verdict.

## Keybindings

omp has no leader key, so each binding is one chord. Action ids come from `packages/tui/src/app-keybindings.ts`.

| opencode | Key | omp action |
|---|---|---|
| `session.list` | `Ctrl+S` | `app.session.resume` |
| `model.list` | `Ctrl+O` | `app.model.selectTemporary` |
| `session.new` | `Ctrl+N` | `app.session.new` |
| `session.toggle.thinking` | `Ctrl+Y` | `app.thinking.toggle` |
| tool output expand | `Alt+O` | `app.tools.expand` |

`app.session.observe` is a legacy alias of `app.agents.hub`, and both default to `Ctrl+S`. The alias is disabled so `Ctrl+S` opens the session picker.

## Instruction files breakdown

| File | Main session | Task subagent | Advisor |
|---|---|---|---|
| `~/.omp/agent/AGENTS.md` | yes | no | yes |
| `~/.omp/agent/APPEND_SYSTEM.md` | yes | no | no |
| `~/.omp/agent/RULES.md` | yes | yes | yes |
| `.omp/AGENTS.md` (project) | yes | no | yes |
| `.omp/RULES.md` (project) | yes | yes | yes |
| Agent definition body | no | yes, for that agent | no |
| `WATCHDOG.md` / `WATCHDOG.yml` | no | no | yes |

