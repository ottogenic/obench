# Leaderboard

## loudmouth-likes-hates (judge: gpt-5.6-sol - harness: loom-v3 @ 4d32663)

| Rank | Model | Total | First-pass code | Findings (R1) | Fix loop | Malformed | Date |
|---|---|---|---|---|---|---|---|
| 1 | **qwen3-coder-next (OpenRouter)** | **22:20** | 18:41 | **0** | **1:40** | 4 | 2026-07-25 |
| 2 | qwen3-coder-next-fp8 local (37 tk/s) | 51:27 | **10:03** | 4 | 39:00 | 11 | 2026-07-25 |
| 3 | gpt-oss-120b (31 tk/s) | 87:43 | 74:00 | 7 | **8:36** | **6** | 2026-07-25 |
| 4 | laguna-s-2.1-nvfp4 (9 tk/s) | 107:25 | 47:02 | 4 | 53:16 | 9 | 2026-07-25 |

**Headline:** the same qwen weights family hosted vs local-FP8-on-GB10: zero findings vs four, half the wall clock. The quality gap between benchmark hype and local experience appears to be a serving-stack artifact, not the model. (n=1; see the openrouter result notes for bundled variables.)

**Read of the field:** finding *classes* were near-identical across all three
(implicit-invariant integration bugs) - quality on this case is bounded by
instructions and the feature's inherent traps more than by worker choice; wall
clock then tracks effective (not nominal) token speed. gpt-oss is the outlier
profile: worst first pass, dramatically best fix loop and contract discipline.
Laguna DNF'd the orchestrator role entirely (runs 2+ used a fixed gpt-5.4-mini
orchestrator; qwen3's row used its own orchestration - recorded asymmetry).

Caveats: laguna/gpt-oss baselines contained the qwen3 review file (leakage window,
closed for future runs - see README ground rule 3).

## coder-oneshot-likes-hates (single-grader rubric, 2026-07-25)

One frozen packet -> one coder session -> graded diff. No orchestration.

| Serving | Runs | CRITICAL | Grades | Read |
|---|---|---|---|---|
| **vllm FP8 (local)** | 2 | **0** | C+, C | most consistent; complete features, no crashes |
| llama.cpp Q8 (local) | 3 | 2 | D, D, C | crashes in 2/3 (Lua forward references) |
| OpenRouter (hosted) | 3 | 2 | B-, D, D- | widest spread; best single run and a half-built one |

**This reverses the pipeline case's n=1 impression.** Serving stack is not what makes
this model's code good or bad -- the same defect classes appear on all three. Details:
results/coder-oneshot-likes-hates/2026-07-25-first-matrix.md
