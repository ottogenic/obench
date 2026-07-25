#!/usr/bin/env python3
"""POST one message to an opencode session and wait for the reply.
usage: bench_post.py <session_id> <agent> <provider/model...> <text_file> [timeout_s]"""
import sys, json, urllib.request

sid, agent, ref, path = sys.argv[1:5]
timeout = int(sys.argv[5]) if len(sys.argv) > 5 else 2400
prov, _, mid = ref.partition("/")
body = {
    "agent": agent,
    "model": {"providerID": prov, "modelID": mid},
    "parts": [{"type": "text", "text": open(path, encoding="utf-8").read()}],
}
req = urllib.request.Request(
    f"http://localhost:4096/session/{sid}/message",
    data=json.dumps(body).encode(), headers={"content-type": "application/json"})
with urllib.request.urlopen(req, timeout=timeout) as r:
    resp = json.load(r)
text = "\n".join(p.get("text", "") for p in (resp.get("parts") or [])
                 if p.get("type") == "text")
err = ((resp.get("info") or {}).get("error"))
if err and not text:
    print("MODEL_ERROR:", str(err)[:300])
    sys.exit(1)
print(text)
