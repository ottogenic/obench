# Case: loudmouth-likes-hates

Add Likes/Hates personality traits (Places, Entities) to the Loudmouth WoW Classic
addon, influencing banter on zone entry and spell-cast-at-target. Full prompt:
[prompt.txt](prompt.txt) (byte-frozen; do not edit — new wording = new case).

## Why this case is hard (what it measures)

- **Implicit-invariant integration:** the new trait matching must splice into an
  existing resolution chain (exact -> alias -> substring -> subzone; action buckets;
  per-action cooldowns; guaranteed Generic fallback) whose invariants exist only in
  the code. This is where all tested models fail first.
- **Greenfield half:** the repo has NO existing target-detection code (verified);
  "casting at an NPC" requires net-new event handling, not imitation.
- **Constraint compliance:** Lua 5.1 only, Classic-Era API rules, macro/combat
  safety — all written in the repo overlays (models follow these reliably; the
  contrast with unwritten invariants is part of the measurement).

## Pinned inputs

| Input | Pin |
|---|---|
| Target repo | `vendor/loudmouth` @ `8a7546c` (tag `bench/likes-hates-base`) — pre-results baseline |
| Pipeline | `vendor/omodel-wire` @ `4d32663` (tag `bench/loom-v3`) — loom v3 |
| Prompt | `prompt.txt` |
| Judge | architect+review pinned to a strong cloud model (2026-07-25: `openai/gpt-5.6-sol`); model+date recorded per result — judges drift |
| Orchestrator | `openai/gpt-5.4-mini` (fixed after laguna's intake DNF; see results) |

## Variable under test

The local worker model serving `agent-code` / `agent-test` / `agent-research`.

## Metrics (extracted from the loom ledger per run)

Total wall clock; per-phase timings (plan/code/test/review+fix); review findings
round-1 count + classes; fix attempts on hardest finding; malformed replies;
blocked events; dispatches. Plus environment manifest: opencode version, vllm
container, omm profile, harness+target SHAs actually used.

## Procedure

See [run.sh](run.sh). Summary: launch model profile via omodel-manager -> route
workers to it (verify; `omw sync` follows prefs, not live models) -> witnessed
opencode serve restart from the target repo -> reset target to baseline -> run
prompt via `opencode run --agent loom --auto --attach` -> let the job run to true
completion (wrapper caps are snapshots, not endings) -> extract metrics from
loom.db -> write results/<date>-<model>.{md,json}.
