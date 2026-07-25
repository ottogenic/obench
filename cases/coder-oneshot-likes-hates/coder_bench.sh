#!/usr/bin/env bash
# coder_bench.sh <n_runs> <coder provider/model> [tag]
# Frozen packet -> ONE agent-code session -> capture diff. No grading here:
# patches are graded out-of-band (consistent single grader, no API-path hangs).
set -u
N=${1:?n_runs}
MODEL=${2:?coder model ref}
TAG=${3:-bench/likes-hates-base}
REPO=/home/otto/Documents/loudmouth
OB=/home/otto/obench
RUNS=$OB/runs
OUT=/tmp/coder_bench.out
mkdir -p "$RUNS"
: > "$OUT"
log() { echo "[$(date -u +%H:%M:%S)] $*" >> "$OUT"; }

STAMP=$(date -u +%m%d%H%M)
log "leg start: $N runs, model=$MODEL, stamp=$STAMP"
for i in $(seq 1 "$N"); do
  log "=== run $i/$N ==="
  cd "$REPO" && git checkout -qf "$TAG" && git clean -qfd
  SID=$(curl -s -X POST "http://localhost:4096/session?directory=$REPO" \
        -H "content-type: application/json" -d "{\"title\": \"coder-bench $STAMP r$i\"}" \
        | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")
  [ -n "$SID" ] || { log "FAIL: no session"; continue; }
  S=$(date +%s)
  python3 "$OB/bench_post.py" "$SID" agent-code "$MODEL" \
    "$OB/packet-likes-hates.txt" 2100 > "$RUNS/$STAMP-r$i-reply.txt" 2>&1
  RC=$?
  E=$(($(date +%s)-S))
  git -C "$REPO" diff > "$RUNS/$STAMP-r$i.patch"
  git -C "$REPO" status --short > "$RUNS/$STAMP-r$i.status"
  DIFFSTAT=$(git -C "$REPO" diff --shortstat | tr -d "\n")
  PROTO=$(grep -cE "^\s*\`?STATUS\`?\s*:" "$RUNS/$STAMP-r$i-reply.txt" || true)
  echo "{\"stamp\":\"$STAMP\",\"run\":$i,\"model\":\"$MODEL\",\"rc\":$RC,\"coder_secs\":$E,\"diffstat\":\"$DIFFSTAT\",\"contract_line\":${PROTO:-0},\"patch\":\"$STAMP-r$i.patch\"}" >> "$OB/coder_runs.jsonl"
  log "run $i done: ${E}s; $DIFFSTAT; rc=$RC"
done
cd "$REPO" && git checkout -qf "$TAG" && git clean -qfd
log "CODER_BENCH_DONE"
