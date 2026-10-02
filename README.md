<div align="center">

```
████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗        ███████╗ ██████╗ ██████╗  ██████╗ ███████╗
 ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║██║  ██║        ██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║███████║        █████╗  ██║     ██║   ██║██████╔╝█████╗
    ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║██╔══██║        ██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝
    ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██║  ██║        ██║     ██████╗╚██████╔╝██║  ██║███████╗
    ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝        ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

**TERMUX FORGE** — a rich, interactive, resumable Termux setup installer.

[![lint](https://github.com/OWNER/termux-forge/actions/workflows/lint.yml/badge.svg)](https://github.com/OWNER/termux-forge/actions/workflows/lint.yml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

</div>

---

## What it is

One command that turns a stock Termux install into a tuned, themed,
backed-up development environment. Every step explains itself, previews the
result before you commit to it, can be declined, and is recorded so an
interrupted run resumes exactly where it stopped.

```bash
curl -fsSL https://raw.githubusercontent.com/OWNER/termux-forge/main/install.sh | bash
tf
```

Prefer to look before you leap:

```bash
tf --dry-run     # print every command, change nothing
tf --list        # list all steps with descriptions
```

---

## Why it exists

Termux ships with a bare shell. Getting to a good setup means answering the
same twenty questions every time: which font, which color scheme, which
keyboard row, which prompt theme, is `git` even configured. This answers them
for you, shows you what each answer looks like, and writes down what it did so
you can undo it.

Three properties everything else follows from:

1. **Nothing is silent.** A failing step says which command failed, with what
   exit code, and stops the run with the exact command to retry it.
2. **Nothing is destructive by surprise.** Steps that delete things are opt-in
   and say so before running.
3. **Everything is reversible.** Every mutating step takes a timestamped
   tarball of your dotfiles first.

---

## Steps

| id | what it does |
|---|---|
| `preflight` | verify Termux, pkg, storage permission, network |
| `backup` | timestamped tarball of `.zshrc`, `.zshenv`, `.p10k.zsh`, `.termux/`, … |
| `packages` | zsh, git, fzf, bat, eza, ripgrep, delta, atuin, python3, … |
| `zsh` | set zsh as the login shell |
| `omz` | oh-my-zsh |
| `plugins` | plugin set, each confirmed, `git` always included |
| `p10k` | powerlevel10k + a tuned preset, or run the real wizard |
| `fonts` | nerd font install, face picker with glyph preview, optional bold |
| `colors` | color scheme with live preview |
| `keyboard` | extra-keys layout, preview-first, includes a TOP/tmux preset |
| `theme` | **new** — switch prompt theme, injected before p10k reads it |
| `hostname` | **new** — hostname shown in banner and prompt |
| `banner` | ASCII art + 24 info styles, live preview, optional animation takeover |
| `zshrc` | generated `.zshrc` |
| `speedup` | trim `.zshenv` PATH, completion cache, lighter `chpwd` |
| `prompt` | **new** — 8 prompt personalities with live preview |
| `polish` | bat pager, git identity, delta, fzf defaults, font trim, Ctrl-R, goon mode |
| `cleanup` | opt-in — remove orphan clones |
| `repair` | opt-in — fix known breakages |
| `commands` | install the helper commands |
| `finish` | apply settings, re-exec zsh so changes land *now* |

---

## The good bits

**Live previews everywhere.** Every picker shows the result in a side pane
before you press enter — prompt personalities, info styles, animations, font
faces, themes, keymaps.

**`tfloop` — full-screen animations.** Procedural, so they never repeat:

```bash
tfloop tunnel     # breathing concentric rings
tfloop warp       # starfield into hyperspace
tfloop plasma     # full-bleed hue-cycling colour wash
tfloop ripple     # expanding pulses
tfloop moire      # two interfering grids
```

Alternate screen buffer, so it never pollutes scrollback. Any key exits.
Pick one from the banner step and it plays on every shell start.

**Goon mode.** A glyph and your command's duration after every command,
coloured by exit code, in a hue that drifts with system load:

```
❋  0.46s
✗ 2  0.11s
```

Turn it off with `_tf_goon=0`.

**Theming that actually applies.** p10k reads its configuration once, when it
is sourced. Settings written after that line are silently thrown away — which
is why most prompt-tweaking scripts appear to do nothing. `tf` injects before
the anchor.

**Resumable.** Interrupted runs pick up where they stopped. `tf --flush` wipes
backups, logs and state for a clean slate.

---

## Flags

| flag | effect |
|---|---|
| `--list` | list every step and exit |
| `--dry-run` | print commands, change nothing |
| `--yes` / `--no` | accept or decline every step |
| `--only a,b` | run only these steps |
| `--skip a,b` | skip these steps |
| `--force` | re-run steps already marked done |
| `--opt-in` | include the destructive steps |
| `--reset` | wipe session state, keep backups |
| `--flush` | delete backups + logs + state |
| `--state-dir`, `--backup-dir`, `--log-dir` | relocate working directories |
| `--help` | usage |

---

## Development

```bash
bash -n termux-forge install.sh commands/*    # syntax
shellcheck -S error -e SC1091,SC1090 termux-forge install.sh commands/*
```

CI also enforces the structural invariants: every step id in `STEPS` must have
a `step_<id>` function and all four metadata fields, `VERSION` must match
`VERSION` the file, and no machine state (`state/`, `logs/`, `backups/`) may be
committed.

### Adding a step

1. `step_<id>() { … }` — return non-zero on failure, it will be reported
2. Add `<id>` to `STEPS`
3. Set `STEP_NAME`, `STEP_DESC`, `STEP_EXPLAIN`, `STEP_RISK`
4. Use `run` for anything that mutates so `--dry-run` stays honest
5. Use `zshrc_block before|append` for `.zshrc` edits — never write `.zshrc` directly

## License

MIT — see [LICENSE](LICENSE).