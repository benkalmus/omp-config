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
omp/.omp/agent/agents/subtractor.md
```

Stow links each file into `~/.omp/agent/`. The Makefile passes `--no-folding`, so `~/.omp/agent` stays a real directory. omp writes databases and caches beside the stowed files.

## Author-critic loop

The opencode setup has one primary agent and three subagents. omp has no selectable primary agent, so the mapping is:

| opencode | omp | Why |
|---|---|---|
| `implementer` (primary) | `~/.omp/agent/APPEND_SYSTEM.md` | Appended to the main session prompt. Task subagents and advisors do not receive it. |
| `critic-structure` (subagent) | `agents/critic-structure.md` | Read-only task agent, discovered by name. |
| `critic-behavior` (subagent) | `agents/critic-behavior.md` | Read-only task agent with `bash` for test runs. |
| `subtractor` (subagent) | `agents/subtractor.md` | Task agent with `blocking: true`, so it runs in the foreground. |

`async.enabled` defaults to `true`, so the two critics return in the background and the user keeps talking to the implementer. The subtractor declares `blocking: true`, so nothing writes beside it.

The opencode `permissions` block has no omp equivalent. omp restricts a task agent by its `tools` list. The global `bash.patterns` deny list in `config.yml` blocks inline scripts, `.env` reads, and destructive shell for every session. A tool the agent does not hold is unavailable. A shell pattern outside that list is still a contract rule in the agent body, not an enforcement point.

`task.structured` is on in `config.yml`. Each subagent result is available at `agent://<id>` after the spawn returns.

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

