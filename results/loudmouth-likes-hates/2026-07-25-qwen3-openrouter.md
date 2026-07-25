# Session Review — qwen3-coder-next via OpenRouter (2026-07-25, job 93)

Same prompt, same harness (loom-v3 @ 4d32663), same judge (gpt-5.6-sol), same agent
topology as the local qwen3 baseline (qwen orchestrates itself). Baseline was the
leakage-free tag. The ONLY variable vs the local baseline: serving stack (hosted
full-service vs local FP8 on GB10 vllm).

| Metric | local qwen3 FP8 (job 88) | OpenRouter qwen3-coder-next (job 93) |
|---|---|---|
| Total wall clock | 51:27 | **22:20** |
| plan | 1:54 | 1:59 |
| code (first pass) | 10:03 | 18:41 |
| test | 0:34 | 0:12 |
| review + fix loop | 39:00 | **1:40 (zero findings)** |
| Review findings (R1) | 4 | **0** |
| Malformed replies | 11 | 4 |
| Pre-build self-ask | 1 | 0 |

## Reading

The hosted model wrote slower (network + possibly more tokens) and dramatically
BETTER: sol -- who found 4/4/7 findings across three local models on this feature --
found nothing. No fix loop at all. Total time under half the local baseline despite
the slower code phase. Orchestration was also cleaner (no self-ask; correct PR
deferral to operator approval).

## Caveat

n=1, and "serving stack" bundles quantization, vllm build, sampling defaults, and an
unknown OpenRouter backend precision. But the direction is unambiguous and large:
the practical-quality gap Otto observed vs benchmark hype looks like a LOCAL-SERVING
artifact, not a property of the model. Follow-ups worth running: (a) repeat hosted run
(variance), (b) local run with nvfp4 quant profile, (c) local run with OpenRouter-
matched sampling params.
