# WSL2 Setup Guide

## The Critical Problem
WSL2 has no public IP. Verification committee CANNOT reach localhost.
**Success rate = 0% if result_fetch_endpoint is localhost.**

## 1. Cloudflare Tunnel Setup
```bash
# Install
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# Start (gets public URL automatically)
cloudflared tunnel --url http://localhost:8080
```

## 2. Auto-update Tunnel as Systemd Service
```bash
sudo cp systemd/cloudflare-tunnel.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cloudflare-tunnel.service
```

## 3. Verify URL is Correct On-Chain
```bash
LAST_JOB=$(grep "Inference done for job" ~/full-auto.log | tail -1 | awk '{print $NF}')
republicd query computevalidation job $LAST_JOB --node tcp://localhost:43657 -o json | jq '.job.result_fetch_endpoint'
# Must show: "https://xxxx.trycloudflare.com/JOB_ID/result.bin"
# NOT: "https:///JOB_ID/result.bin" (broken!) or "localhost" (unreachable!)
```

## 4. Fix Wrong Port (8081 → 8080)
```bash
sudo sed -i 's|http.server 8081|http.server 8080|g' /etc/systemd/system/republic-http.service
sudo systemctl daemon-reload && sudo systemctl restart republic-http.service
```
