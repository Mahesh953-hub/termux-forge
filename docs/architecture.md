# Architecture

## Why the script is shaped like this

`termux-forge` is a single bash file plus a directory of preview helpers. That
is deliberate: it has to run on a phone, with no build step and no runtime
dependencies beyond what Termux already ships.

```
termux-forge          the installer — steps, state, prompts
install.sh            one-line installer
commands/             preview + helper commands, installed to $PREFIX/bin
assets/               brand art
.github/workflows/    CI
```

## State

Append-only key=value in `state/session`:

```
enabled_plugins=git zsh-autosuggestions …
p10k=done
hostname=kailashhh
```

`state_get` reads the last value, so re-running a step simply appends and
supersedes. Nothing needs parsing or migration.

## The `.zshrc` ordering problem

This is the single most important thing to understand before editing the
generated `.zshrc`.

```
  1  instant prompt preamble     (must be first)
 …
 34  source ~/.p10k.zsh          (p10k snapshots its config HERE)
 …
 87  # termux-forge: prompt      (settings written here are DISCARDED)
```

powerlevel10k reads `POWERLEVEL9K_*` and `ZSH_THEME` once, when it is sourced,
and then redraws `PROMPT` itself on every prompt. Anything assigned after that
line is thrown away without warning.

`zshrc_block before <anchor> <tag> <body>` exists for this. It strips any
previous copy of the tag, then inserts the new block immediately before the
first line matching the anchor. If the anchor is missing it appends instead, so
a block is never silently lost.

Use `append` for things that must win — keybindings, for instance, since p10k
and atuin both rebind keys.

## Colour and dry-run

Every mutation routes through one of four helpers, all of which honour
`DRY_RUN`:

| helper | for |
|---|---|
| `run` | shell commands |
| `fsed` | in-place `sed -i` without quoting pain |
| `emit` | heredoc writes |
| `zshrc_block` | tagged, idempotent `.zshrc` edits |

## Previews

`tf_pick <title> <mode>` wraps fzf and routes the preview pane by mode:

| mode | preview command |
|---|---|
| `art` | `tfart --preview {}` |
| `style` | `tf-style-preview {}` |
| `anim` | `tfloop --frame {}` |
| `prompt` | `tf-prompt-preview {}` |
| `theme` | `tf-theme-preview {}` |
| `keys` | `tf-keys-preview {}` |
| `font` | `tf-font-preview {}` |

Preview helpers must work **without a tty** — fzf's preview pane is not one.
That is why `tfloop` has a separate `--frame` path.
