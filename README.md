# pi-config

Stow package for [omp](https://omp.sh), the `oh-my-pi` coding agent. It mirrors the opencode setup where omp has an equivalent.

## Quick start

```sh
git clone git@github.com:benkalmus/pi-config.git
cd pi-config
make stow
```

## Layout

```text
pi/.omp/agent/AGENTS.md
pi/.omp/agent/keybindings.yml
```

Stow links each file into `~/.omp/agent/`. The Makefile passes `--no-folding`, so `~/.omp/agent` stays a real directory. omp writes databases and caches beside the stowed files.

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

## Not mirrored

omp has no equivalent for these opencode bindings.

- **`<leader>u` / `<leader>r`**, message undo and redo. omp branches with `/tree` and `/fork`. `tui.editor.undo` only affects the composer.
- **`<leader>w`**, transcript verbosity. omp has no leader key.
- **`agent.cycle`**, cycling primary agents. omp picks an agent per task.

## Notes

`AGENTS.md` reaches the main session and advisors. Task subagents do not inherit it. Put anything a subagent must follow in `~/.omp/agent/RULES.md`, which stays sticky across the whole request.

`config.yml` is not tracked here yet. The live file holds model roles and the theme.
