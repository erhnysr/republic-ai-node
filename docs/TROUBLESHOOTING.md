# Troubleshooting Guide

## Issue 1: Wrong Key Name (Most Common!)
**Symptom:** No jobs assigned, sidecar running but silent
**Cause:** Sidecar running with `--from wallet` but key name is `validator`
```bash
# Diagnose
ps aux | grep job-sidecar | grep -v grep
republicd keys list --keyring-backend test --home $HOME/.republicd

# Fix
sudo sed -i 's|--from wallet|--from validator --home /home/$USER/.republicd|g' /etc/systemd/system/republic-sidecar.service
sudo systemctl daemon-reload && sudo systemctl restart republic-sidecar.service
```

## Issue 2: result_fetch_endpoint Empty/Broken
**Symptom:** Explorer shows `https:///JOB_ID/result.bin`, team warns "not reachable"
**Cause:** SERVER_IP variable empty in full-auto.sh
```bash
# Diagnose
grep "SERVER_IP" ~/full-auto.sh

# Fix
TUNNEL_URL=$(cat ~/tunnel-url.txt | sed 's|https://||')
sed -i "s|SERVER_IP=\".*\"|SERVER_IP=\"$TUNNEL_URL\"|g" ~/full-auto.sh
pkill -f full-auto.sh && nohup ~/full-auto.sh >> ~/full-auto.log 2>&1 &
```

## Issue 3: Bech32 Address Bug
**Symptom:** submit-job-result TX rejected, validator field wrong prefix
**Cause:** Chain expects `raivaloper` prefix but `rai` prefix is sent
```bash
# Fix (already in full-auto.sh via python3 bech32 fix)
python3 -c "
import bech32, json
tx = json.load(open('/tmp/tx_unsigned.json'))
_, data = bech32.bech32_decode('YOUR_WALLET')
valoper = bech32.bech32_encode('raivaloper', data)
tx['body']['messages'][0]['validator'] = valoper
json.dump(tx, open('/tmp/tx_unsigned.json', 'w'))
"
```

## Issue 4: Multiple Sidecar Processes
**Symptom:** pkill doesn't work, process respawns
**Cause:** Systemd auto-restarts the service
```bash
# Fix - stop via systemd not kill
sudo systemctl stop republic-sidecar.service
sudo systemctl disable republic-sidecar.service
pkill -9 -f "job-sidecar"
```

## Issue 5: Tunnel URL Changes After Restart
**Symptom:** Jobs submitted but result_fetch_endpoint points to old dead URL
**Cause:** Quick tunnel (trycloudflare.com) URL changes on every restart
```bash
# Permanent fix - make full-auto.sh read URL dynamically each loop
# Add this line inside the while loop in full-auto.sh:
SERVER_IP=$(cat ~/tunnel-url.txt | sed 's|https://||')
```

## Issue 6: HTTP Server Wrong Port
**Symptom:** `connection refused` on localhost:8080, sidecar can't verify
**Cause:** HTTP server running on 8081 instead of 8080
```bash
sudo sed -i 's|http.server 8081|http.server 8080|g' /etc/systemd/system/republic-http.service
sudo systemctl daemon-reload && sudo systemctl restart republic-http.service
```

## Quick Full Diagnosis
```bash
# Run all checks at once
ps aux | grep -E "full-auto|watchdog|cloudflared|republic" | grep -v grep
grep "SERVER_IP" ~/full-auto.sh
cat ~/tunnel-url.txt
LAST_JOB=$(grep "Inference done for job" ~/full-auto.log | tail -1 | awk '{print $NF}')
republicd query computevalidation job $LAST_JOB --node tcp://localhost:43657 -o json | jq '{status: .job.status, endpoint: .job.result_fetch_endpoint}'
curl -s -o /dev/null -w "URL reachable: %{http_code}\n" $(cat ~/tunnel-url.txt)/$LAST_JOB/result.bin
```
