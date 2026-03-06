# P1 Policy: Operator Loop Safety

This policy is designed to keep the operator loop safe and predictable.

## Scope

- operator-loop-kit (infra repo)
- research projects created as `<name>.rev` / `<name>.dev`

## Rules

### 1) operator-loop-kit (infra)

- Codex may **commit locally**, but **must not push**.
- Claude is the only actor allowed to push to the remote.

### 2) research projects (.rev/.dev)

- Codex may review, approve, merge, and push.
- Codex must **not directly edit code** in the project.
- Codex may only create/modify the **whitelisted files** listed below when doing approvals/review bookkeeping.

### 3) Whitelist

Allowed paths:

- `.ai/approvals/`
- `.ai/transcripts/`
- `.ai/LAST_RUN_ID`
- `README.md`
- `.ai/PLAN.md`
- `.ai/HANDOFF_TO_CLAUDE.md`
- `.ai/STATE.md`
- `.ai/REVIEW.md`

Any change outside this list is treated as **unexpected scope**.

## Enforcement

- Purpose: the guard prevents Codex from accidentally mixing arbitrary code changes into main during review/merge.
- Claude implementation changes are normal; the guard only blocks policy violations right before approve/merge.

- `kit/scripts/guard_codex_whitelist.sh` must be run before merge/push.
- If the guard reports `BLOCKED`, treat the run as `REQUEST_CHANGES`.
- Do not approve/merge/push until the change set is brought back into the allowed scope.
