# Contributing

## Ground rules

1. **`--dry-run` must stay honest.** Anything that mutates the filesystem goes
   through `run`, `fsed`, `emit` or `zshrc_block`. Never write a file directly.
2. **Failures are loud.** Return non-zero and say which command failed. A step
   that quietly does nothing is a bug.
3. **Destructive steps are opt-in.** If a step deletes anything, it belongs
   behind `--only` or `--opt-in` and must warn before running.
4. **Preview before asking.** If a choice has a visual result, give it a
   preview mode in `tf_pick`.
5. **Never write `.zshrc` directly.** Use `zshrc_block`. p10k and the shell
   hooks read config in order; a block in the wrong place is silently ignored.

## Before you open a PR

```bash
bash -n termux-forge install.sh commands/*
shellcheck -S error -e SC1091,SC1090 termux-forge install.sh commands/*
tf --dry-run
```

New steps need all four metadata fields or CI fails.
