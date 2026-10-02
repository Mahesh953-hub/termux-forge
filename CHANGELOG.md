# Changelog

All notable changes to this project are documented here.
Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - unreleased

### Added
- **`theme` step** — switch p10k/oh-my-zsh theme with a live preview
  (`powerlevel10k`, `agnoster`, `pure`, `robbyrussell`, `avit-xlTips`).
  Injected *before* `source ~/.p10k.zsh`, because p10k snapshots its config once.
- **`hostname` step** — set the hostname shown in the banner and prompt without
  touching the real system hostname. Reversible, instant.
- **`fonts` step actually implemented.** `STEPS` referenced `step_fonts`, which
  never existed, so the step failed on every run. It now installs/validates a
  nerd font, offers a face picker with a glyph preview, and can force bold
  (real Bold face, or `font-bold=true` to synthesise).
- **`prompt` step** — 8 prompt personalities with live preview
  (`nerdy`, `leet`, `hacker`, `rainbow`, `minimal`, `corporate`, `chaotic`, `boxy`).
- **`tfloop`** — full-screen looping animation player with five procedural
  generators (`plasma`, `tunnel`, `warp`, `ripple`, `moire`). Uses the
  alternate screen buffer, exits on any key, never repeats because hue rotates.
  `--frame` renders a single frame for preview panes.
- **Animation takeover** — pick one from the banner step and it plays for a few
  seconds on every shell start.
- **Goon mode** — a glyph plus command duration after every command, coloured
  by exit code, in a hue that drifts with system load. `_tf_goon=0` disables it.
- **TOP/tmux keyboard preset** and a preview-first keyboard template picker.
- **`install.sh`** — one-line installer, idempotent.
- **CI** (`.github/workflows/lint.yml`) — `bash -n` on every script,
  `shellcheck -S error`, plus structural checks that every step id has a
  function and all four metadata fields, VERSION is in sync, and no machine
  state is committed.
- `--opt-in` flag to include the destructive steps.
- `--backup-dir` and `--log-dir` flags.

### Fixed
- **`--dry-run` lied.** ~15 call sites wrote files directly, bypassing `run()`.
  Worst case `--dry-run --flush --yes` would `rm -rf` every backup. Added an
  `fsed` helper, gated `rm`/`cp`/`zshrc_append`/`tf_flush`.
- **delta was broken.** `--configure-git-features` does not exist in delta
  0.19.2; it printed an error twice per shell. Now wired through `git config`.
- **p10k instant-prompt warning** — our own preset emitted
  `POWERLEVEL9K_INSTANT_PROMPT=verbose`. Now `quiet`.
- **atuin is unusable on Android.** 18.23.0 (newest in the Termux repo) fails
  its keyring because `keyctl` is denied, so `atuin init zsh` errored on every
  prompt. The forge now probes `atuin history list` and falls back to
  `HISTFILE` plus an fzf-backed Ctrl-R.
- **Prompt modifications were silently discarded.** The block was written after
  `source ~/.p10k.zsh`, which snapshots its config at startup. New
  `zshrc_block before <anchor>` inserts it ahead of that line. Idempotent, with
  an append fallback if the anchor is missing.
- **Heavy glyph lag** — removed the forced `POWERLEVEL9K_BOLD` and
  `ICON_PADDING=none` that made redraw crawl on Android.
- **Font trim prompted on every run** asking to delete 0 files.
- **Duplicate blocks** — renaming a tag left the old block behind; Ctrl-R was
  bound twice.
- **`eza` permission spew** — `cd /` printed errors via the `chpwd` hook. Now
  `-1 --no-user`, no pager, stderr suppressed.
- **warp animation** put every star on every row (repeating bands, not a
  starfield); plasma/moire drew twice the terminal width and wrapped.
- **`%.2f` inside `print -P`** collided with `%f` (colour reset) and printed
  `~2fs`. `(( ))` truncated float timings to 0.
- **`--only` was not authoritative** for opt-in steps.
- Phantom `--resume` was advertised in the finish output.

### Changed
- **Failures are loud.** A failing step names the command and exit code, marks
  the step failed, and stops the run with the exact command to retry. No more
  silent no-ops.
- `ask_yn` accepts `y`/`n`/`q`, handles EOF instead of looping forever, and
  reports invalid input.
- `cleanup` and `repair` are opt-in — they delete things and no longer run
  during a normal pass.
- `step_finish` re-execs zsh so changes apply to the *current* terminal.

## [1.0.1]

Initial interactive installer: packages, zsh, oh-my-zsh, plugins, p10k,
fonts, colors, keyboard, banner, `.zshrc`, speedups, polish, cleanup, repair,
helper commands.