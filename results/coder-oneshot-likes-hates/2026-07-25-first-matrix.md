# 2026-07-25 — first matrix: llama.cpp Q8 vs OpenRouter vs vllm FP8

Same weights family (Qwen3-Coder-Next), same frozen packet, same grader, all runs
post-firmware-update and post-reboot. Grades are one grader's judgment against the
packet's acceptance criteria (rubric in the case card).

| # | Serving | Time | Files | +/- | CRIT | MAJ | MIN | Grade |
|---|---|---|---|---|---|---|---|---|
| A | llama.cpp Q8 | 307s | 2 | +205/-7 | 1 | 3 | 3 | D |
| B | llama.cpp Q8 | 486s | 5 | +302/-6 | 1 | 1 | 2 | D |
| C | llama.cpp Q8 | 232s | 3 | +286/-0 | 0 | 2 | 1 | C |
| D | OpenRouter | 132s | 4 | +490/-7 | 0 | 1 | 2 | B- |
| E | OpenRouter | 97s | 4 | +278/-6 | 1 | 2 | 0 | D |
| F | OpenRouter | 366s | 2 | +111/-4 | 1 | 2 | 1 | D- |
| G | vllm FP8 | 377s | 4 | +220/-37 | 0 | 2 | 1 | C+ |
| H | vllm FP8 | 996s | 4 | +292/-8 | 0 | 2 | 1 | C |

Patch artifacts: `patches/<stamp>-r<n>.patch`; machine rows: `coder_runs.jsonl`.

## Headline

**vllm FP8 was the most consistent leg — zero CRITICAL defects in 2/2, both complete
implementations.** llama.cpp crashed in 2/3. OpenRouter shipped a crash and a
half-built feature in 2/3. Within-stack spread exceeds between-stack difference at
this n.

This **contradicts** the earlier pipeline-case impression (hosted 0 findings vs local
4, and llama.cpp 2 vs vllm 4). Those were n=1 comparisons; one spanned a firmware
change. Repetition dissolved both. Do not conclude "the serving stack is why local
code is worse" from the pipeline case alone.

## Defect classes (the durable signal)

| Class | Rate | Notes |
|---|---|---|
| `.luacheckrc` global omitted when `UnitName` used | 5/6 applicable | Repo rule exists and was ignored |
| Cooldown not integrated / key asymmetry | 6/8 | Writes `Cooldowns["Hates"]`, check reads `Cooldowns[action]` |
| Forward-reference crash | 3/8 | `local function` declared after `Trigger`, called inside it |
| Incomplete vs acceptance criteria | 3/8 | Worst: F implemented place traits only, but documented entity traits as working |

All eight runs obeyed the **written** Classic-Era / Lua 5.1 repo rules without
exception — direct evidence that written instructions are followed reliably. The
recurring defects are all things the repo does NOT say out loud.

## Caveats

n=2–3 per cell; single grader (consistent, not blind); grades are ordinal. Run H's
996s is an outlier worth re-testing. `contract_line: 0` on every run — the one-shot
coder never emits the Return Contract trailer without loom's nudge, which is expected
here and not graded.
