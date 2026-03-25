# Auto Compute Guide

## Overview
full-auto.sh automates the complete job lifecycle:
1. Submit job to chain
2. Run GPU inference via Docker
3. Fix bech32 address bug
4. Sign and broadcast result TX
5. Repeat every ~60 seconds

## Why full-auto instead of job-sidecar?
- Sidecar has a verification volume mount bug (cannot fix externally)
- full-auto gives full control and visibility
- Easier to debug and customize

## Start Everything
```bash
# 1. Ensure HTTP server is on port 8080
systemctl status republic-http.service | grep 8080

# 2. Start/verify Cloudflare tunnel
sudo systemctl start cloudflare-tunnel.service
sleep 10
cat ~/tunnel-url.txt  # Verify URL exists

# 3. Start full-auto
nohup ~/full-auto.sh >> ~/full-auto.log 2>&1 &
echo "PID: $!"

# 4. Start watchdog
nohup ~/watchdog.sh >> ~/watchdog.log 2>&1 &

# 5. Verify first job submitted correctly
sleep 60
LAST_JOB=$(grep "Inference done for job" ~/full-auto.log | tail -1 | awk '{print $NF}')
republicd query computevalidation job $LAST_JOB --node tcp://localhost:43657 -o json | jq '{endpoint: .job.result_fetch_endpoint, hash: .job.result_hash}'
```

## Monitor
```bash
tail -f ~/full-auto.log
```

## Stop
```bash
pkill -f full-auto.sh
pkill -f watchdog.sh
```

## Thermal Protection
Script auto-adjusts based on GPU temp:
- < 75°C → Normal (30s wait)
- 75-80°C → Slow (90s wait)
- 80-85°C → Hot (3min wait)
- > 85°C → Critical (5min wait)

## Performance (RTX 4050)
- Inference time: ~15-17 seconds
- Jobs per hour: ~40-50
- Success rate: ~94-99%
