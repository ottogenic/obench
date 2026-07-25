# Leaderboard

## loudmouth-likes-hates (judge: gpt-5.6-sol · harness: loom-v3 @ 4d32663)

| Rank | Model | Total | First-pass code | Findings (R1) | Fix loop | Malformed | Date |
|---|---|---|---|---|---|---|---|
| 1 | **qwen3-coder-next-fp8** (37 tk/s) | **51:27** | **10:03** | 4 | 39:00 | 11 | 2026-07-25 |
| 2 | gpt-oss-120b (31 tk/s) | 87:43 | 74:00 | 7 | **8:36** | **6** | 2026-07-25 |
| 3 | laguna-s-2.1-nvfp4 (9 tk/s) | 107:25 | 47:02 | 4 | 53:16 | 9 | 2026-07-25 |

**Read of the field:** finding *classes* were near-identical across all three
(implicit-invariant integration bugs) — quality on this case is bounded by
instructions and the feature's inherent traps more than by worker choice; wall
clock then tracks effective (not nominal) token speed. gpt-oss is the outlier
profile: worst first pass, dramatically best fix loop and contract discipline.
Laguna DNF'd the orchestrator role entirely (runs 2+ used a fixed gpt-5.4-mini
orchestrator; qwen3's row used its own orchestration — recorded asymmetry).

Caveats: laguna/gpt-oss baselines contained the qwen3 review file (leakage window,
closed for future runs — see README ground rule 3).
