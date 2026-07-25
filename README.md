# obench

Personal, repeatable, real-world model benchmarks. Public benchmarks say how a model
scores; obench says how it performs on **my** problems, in **my** pipeline, against a
**constant judge** — with receipts.

## How it works

- **`cases/<name>/`** — a frozen problem: the exact prompt, a case card (what's being
  tested, why it's hard, success criteria, judge config), and a run harness.
- **`vendor/`** — git submodules pinned to exact SHAs: the target repo in its
  pre-test baseline state, and the orchestration pipeline (omodel-wire/loom) as it
  existed at test time. `git clone --recursive` reproduces the input state exactly.
  Matching `bench/*` tags exist in the source repos.
- **`results/<case>/`** — one narrative review (`.md`) + one metrics file (`.json`)
  per model run. Environment facts that can't be pinned (opencode version, cloud
  judge model, vllm build) are **recorded, not restored** — drift is documented,
  never silently ignored.
- **`leaderboard.md`** — generated summary across results.

## Ground rules learned the hard way

1. The pipeline is part of the instrument: results are only comparable when they
   record the same harness SHA.
2. The judge is part of the instrument: cloud judges drift; every result records
   judge model + date, and raw findings text is stored for future re-judging.
3. Results never live in the target repo — a baseline that contains previous
   results hands future models a cheat sheet.
4. Verify the serving process, not the config: record what actually served, from
   the ledger, not what was configured.

## Cases

- **loudmouth-likes-hates** — multi-file WoW-addon feature requiring integration
  with an existing stateful resolution chain (implicit invariants, Lua 5.1,
  Classic-Era API constraints). First run set: 2026-07-25, three local worker
  models vs a constant gpt-5.6-sol plan/review bar.
