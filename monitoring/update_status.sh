#!/usr/bin/env bash
set -u

OUT="$HOME/republic-ai-node/monitoring/status.json"
VPS_HOST="154.12.118.199"
VALOPER="raivaloper1xnjkyyggaz54288vtrsle9wjwqz5tz4lttk8ka"

# -------- WSL full-auto --------
if pgrep -f "full-auto.sh" >/dev/null 2>&1; then
  FULL_AUTO="running"
else
  FULL_AUTO="stopped"
fi

# -------- WSL GPU --------
GPU_OK="no"
GPU_NAME="N/A"
GPU_TEMP="N/A"
GPU_UTIL="N/A"

if command -v nvidia-smi >/dev/null 2>&1; then
  GPU_NAME="$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)"
  GPU_TEMP="$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)"
  GPU_UTIL="$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)"

  if [ -n "$GPU_TEMP" ] && [ "$GPU_TEMP" != "N/A" ]; then
    GPU_OK="yes"
  else
    GPU_OK="no"
    GPU_NAME="N/A"
    GPU_TEMP="N/A"
    GPU_UTIL="N/A"
  fi
fi

# -------- VPS raw JSON over SSH --------
STATUS_JSON="$(ssh -o BatchMode=yes -o ConnectTimeout=5 root@$VPS_HOST 'republicd status 2>/dev/null || true' 2>/dev/null)"
VALIDATOR_JSON="$(ssh -o BatchMode=yes -o ConnectTimeout=5 root@$VPS_HOST "republicd query staking validator $VALOPER -o json 2>/dev/null || true" 2>/dev/null)"

export OUT FULL_AUTO GPU_OK GPU_NAME GPU_TEMP GPU_UTIL STATUS_JSON VALIDATOR_JSON

python3 <<'PY'
import json, os
from pathlib import Path
from datetime import datetime

out = Path(os.environ["OUT"])

def safe_json_load(s: str):
    s = (s or "").strip()
    if not s:
        return {}
    try:
        return json.loads(s)
    except Exception:
        return {}

status = safe_json_load(os.environ.get("STATUS_JSON", ""))
validator = safe_json_load(os.environ.get("VALIDATOR_JSON", ""))

def pick(d, paths, default="N/A"):
    for path in paths:
        cur = d
        ok = True
        for key in path:
            if isinstance(cur, dict) and key in cur:
                cur = cur[key]
            else:
                ok = False
                break
        if ok and cur not in (None, "", "null"):
            return cur
    return default

height = pick(status, [
    ("sync_info", "latest_block_height"),
    ("SyncInfo", "latest_block_height"),
    ("result", "sync_info", "latest_block_height"),
    ("result", "SyncInfo", "latest_block_height"),
])

catching = pick(status, [
    ("sync_info", "catching_up"),
    ("SyncInfo", "catching_up"),
    ("result", "sync_info", "catching_up"),
    ("result", "SyncInfo", "catching_up"),
])

voting = pick(status, [
    ("validator_info", "voting_power"),
    ("ValidatorInfo", "VotingPower"),
    ("result", "validator_info", "voting_power"),
    ("result", "ValidatorInfo", "VotingPower"),
])

val_status = pick(validator, [
    ("validator", "status"),
    ("status",),
], default="N/A")

jailed = pick(validator, [
    ("validator", "jailed"),
    ("jailed",),
], default="N/A")

data = {
    "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "wsl": {
        "full_auto": os.environ.get("FULL_AUTO", "stopped"),
        "gpu_ok": os.environ.get("GPU_OK", "no"),
        "gpu_name": os.environ.get("GPU_NAME", "N/A"),
        "gpu_temp": os.environ.get("GPU_TEMP", "N/A"),
        "gpu_util": os.environ.get("GPU_UTIL", "N/A"),
    },
    "vps": {
        "height": str(height),
        "catching_up": str(catching).lower() if str(catching).lower() in ("true", "false") else str(catching),
        "voting_power": str(voting),
        "validator_status": str(val_status),
        "jailed": str(jailed).lower() if str(jailed).lower() in ("true", "false") else str(jailed),
    }
}

out.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"updated: {out}")
print(json.dumps(data, ensure_ascii=False, indent=2))
PY
