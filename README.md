# operator-loop-kit

A small, self-contained kit to bootstrap the "Claude run -> Codex review/approve -> merge" operator loop.

## Quickstart

### Install Into An Existing Repo

```bash
# from this repo
bash ./install.sh /path/to/your/repo

# or from within the target repo
bash /path/to/operator-loop-kit/install.sh .
```

### Clone A .rev/.dev Pair

```bash
./bin/oploop clone <git_url> <name> [base_dir]
```

This creates:

- `<base_dir>/<name>.rev`
- `<base_dir>/<name>.dev` (worktree on `ai/claude`)

## Contents

- `install.sh`: installs the operator loop files into an existing repo (idempotent, backs up overwritten files with `.bak`).
- `bin/oploop`: helper to clone a repo into `<name>.rev` and create a sibling `<name>.dev` worktree.
- `kit/`: the canonical files copied into target repos.

## Install

```bash
bash ./install.sh [TARGET_DIR]
# default TARGET_DIR is "."
```

The installer ensures:

- `.ai/approvals/`, `.ai/transcripts/`, `.ai/LAST_RUN_ID`
- `.ai/TRIGGER_CLAUDE_RUN.md`, `.ai/TRIGGER_CODEX_REVIEW.md`
- `scripts/ai_pack.sh`, `scripts/ai_gate.sh`, `scripts/test.sh` (and `chmod +x`)
- `.gitignore` rules for packets/transcripts
- `Makefile` is created if missing, or `operator-test` target is added if missing

## Operator Triggers

- `kit/.ai/TRIGGER_CLAUDE_RUN.md`
- `kit/.ai/TRIGGER_CODEX_REVIEW.md`
