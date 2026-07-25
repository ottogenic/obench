# Case: coder-oneshot-likes-hates

Isolates **coder model quality** from pipeline behavior. One frozen packet -> one
`agent-code` session -> capture the diff -> grade it. No orchestrator, no test/review
loop, no fix iterations. Repeatable N times per model/serving config.

## Why this case exists

The pipeline case (`loudmouth-likes-hates`) measures the whole loom system; its
finding counts move with orchestration noise (nudges, fix loops, tester behavior).
This case removes all of that so the only variable is the coder model + serving stack.

## Frozen inputs

| Input | Pin |
|---|---|
| Packet | [packet.txt](packet.txt) -- byte-identical to what job 88's coder received (goal, architect's plan + acceptance criteria, scope boundary, role instructions, Return Contract). 12,757 chars. Do not edit; edits create a new case. |
| Repo baseline | `vendor/loudmouth` @ tag `bench/likes-hates-base` (`8a7546c`) |
| Harness | [coder_bench.sh](coder_bench.sh) + [bench_post.py](bench_post.py) |

## Procedure

`coder_bench.sh <n_runs> <provider/model>` -- per iteration: hard-reset repo to the
baseline tag, create a fresh session in the repo directory, POST the packet with an
explicit model override, wait for completion, save `git diff` as the artifact, append
a row to `coder_runs.jsonl`.

Grading is deliberately **out-of-band**: a single grader reads each patch and scores
CRITICAL / MAJOR / MINOR + letter grade against the packet's own acceptance criteria.
(An in-harness LLM grader was tried and abandoned -- reading files outside the session
directory blocks forever on an unanswerable permission prompt over the HTTP API path.)

## Severity rubric

- **CRITICAL** -- feature broken, unreachable, or crashes at runtime.
- **MAJOR** -- wrong behavior a player hits in normal use, or a stated repo rule violated.
- **MINOR** -- edge case, dead code, doc/template inconsistency, scope nit.

## Grading notes / traps

- The packet does **not** contain the original prompt's example banter lines
  (Ironforge, Dark Iron Dwarf, ...). The architect abstracted them away. Do not
  penalize their absence.
- The plan explicitly prescribes shared `actions["Likes"]` / `actions["Hates"]`
  buckets. That design is required, not a defect.
- Scope lists "existing personality files as examples" as in-scope to modify.
- Watch for Lua forward references: helpers declared `local function` *after*
  `Loudmouth.Trigger` but called inside it resolve to nil globals at runtime.
