#!/usr/bin/env bash
# run.sh <model-profile> -- execute this case against one local worker model.
# Runs ON the GPU box (DGX). Generalized from the 2026-07-25 harness.
set -u
PROFILE="${1:?usage: run.sh <omodel-manager-profile>}"
REPO=/home/otto/Documents/loudmouth          # working checkout of the target
BASELINE_TAG="bench/likes-hates-base"
OMM="python3 /home/otto/Documents/omodel-manager/omodel-manager"
DB=/home/otto/.local/share/otools/loom.db
ORCH_MODEL="openai/gpt-5.4-mini"             # fixed orchestrator (see case.md)
PROMPT="$(dirname "$0")/prompt.txt"

# 1. serve the model under test
for c in $(docker ps --format "{{.Names}}" | grep "^otools-vllm"); do
  $OMM stop "${c#otools-vllm-}" >/dev/null 2>&1 || docker stop "$c" >/dev/null
done
sleep 5
$OMM launch "$PROFILE" >/dev/null 2>&1 &
MODEL_ID=""
for i in $(seq 1 120); do
  MODEL_ID=$(curl -s --max-time 5 http://localhost:8000/v1/models 2>/dev/null \
    | python3 -c "import sys,json;print(json.load(sys.stdin)['data'][0]['id'])" 2>/dev/null)
  [ -n "$MODEL_ID" ] && break; sleep 10
done
[ -n "$MODEL_ID" ] || { echo "FAIL: model never came up"; exit 1; }

# 2. route workers to it EXPLICITLY (omw sync follows prefs, not live models)
cd /home/otto/Documents/omodel-wire && python3 omodel-wire.py sync >/dev/null 2>&1
python3 - "$MODEL_ID" "$ORCH_MODEL" <<'PYEOF'
import json, sys
mid, orch = sys.argv[1], sys.argv[2]
p = "/home/otto/.config/opencode/opencode.json"
c = json.load(open(p))
for a in ("agent-code", "agent-test", "agent-research"):
    c["agent"][a]["model"] = f"dgx-localhost-8000/{mid}"
c["agent"]["loom"]["model"] = orch
json.dump(c, open(p, "w"), indent=2)
PYEOF

# 3. witnessed serve restart FROM THE TARGET REPO (session directory inherits it)
owner() { ss -tlnp 2>/dev/null | grep "127.0.0.1:4096" | grep -oP "pid=\K[0-9]+" | head -1; }
P=$(owner); [ -n "$P" ] && kill "$P"; sleep 3
cd "$REPO" && nohup /home/otto/.opencode/bin/opencode serve --port 4096 >/tmp/oc_serve.log 2>&1 &
sleep 6
NP=$(owner); [ -n "$NP" ] || { echo "FAIL: serve did not bind"; exit 1; }
[ "$(readlink /proc/$NP/cwd)" = "$REPO" ] || { echo "FAIL: serve wrong cwd"; exit 1; }

# 4. reset target to the pinned baseline and run
cd "$REPO" && git fetch -q origin && git checkout -qf "$BASELINE_TAG" && git clean -qfd
J0=$(sqlite3 "$DB" "select coalesce(max(id),0) from jobs")
S=$(date +%s)
/home/otto/.opencode/bin/opencode run --agent loom --auto --attach http://localhost:4096 \
  "$(cat "$PROMPT")" >/tmp/obench_run.oc 2>&1
# the CLI may exit before fix loops finish -- wait for the JOB, not the client
J=$(sqlite3 "$DB" "select max(id) from jobs")
while :; do
  ST=$(sqlite3 "$DB" "select status from jobs where id=$J")
  case "$ST" in done|error|paused) break;; esac
  sleep 30
done
E=$(($(date +%s)-S))

# 5. extract metrics (finish by hand into results/<date>-<model>.{md,json})
echo "=== $PROFILE ($MODEL_ID) job=$J elapsed=${E}s status=$ST ==="
sqlite3 -separator "  " "$DB" "select time(ts,'unixepoch'),detail from events where job_id=$J and kind='phase'"
sqlite3 -separator "  " "$DB" "select kind,count(*) from events where job_id=$J and kind in ('malformed','blocked','dispatch') group by kind"
sqlite3 -separator " | " "$DB" "select n,substr(text,1,140) from findings where job_id=$J order by n"
echo "env: opencode=$(/home/otto/.opencode/bin/opencode --version 2>/dev/null | tail -1) target=$(cd "$REPO" && git rev-parse --short HEAD)"
