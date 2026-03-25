#!/bin/bash
# Republic AI Node - Enhanced Health Check
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo "🔍 Republic AI Node Health Check"
echo "================================="

# 1. Process check
echo -e "\n📊 Processes:"
pgrep -f "full-auto.sh" > /dev/null && echo -e "  ${GREEN}✅ full-auto.sh running${NC}" || echo -e "  ${RED}❌ full-auto.sh NOT running!${NC}"
pgrep -f "watchdog.sh" > /dev/null && echo -e "  ${GREEN}✅ watchdog.sh running${NC}" || echo -e "  ${RED}❌ watchdog.sh NOT running!${NC}"
pgrep -f "cloudflared" > /dev/null && echo -e "  ${GREEN}✅ cloudflared running${NC}" || echo -e "  ${RED}❌ cloudflared NOT running!${NC}"
systemctl is-active --quiet republic-http.service && echo -e "  ${GREEN}✅ HTTP server running (8080)${NC}" || echo -e "  ${RED}❌ HTTP server NOT running!${NC}"

# 2. Tunnel URL check
echo -e "\n🌐 Tunnel URL:"
TUNNEL_FILE="$HOME/tunnel-url.txt"
if [ -f "$TUNNEL_FILE" ]; then
    TUNNEL_URL=$(cat $TUNNEL_FILE)
    echo "  URL: $TUNNEL_URL"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$TUNNEL_URL" 2>/dev/null)
    [ "$HTTP_CODE" != "000" ] && echo -e "  ${GREEN}✅ Reachable (HTTP $HTTP_CODE)${NC}" || echo -e "  ${RED}❌ NOT reachable!${NC}"
else
    echo -e "  ${RED}❌ tunnel-url.txt not found!${NC}"
fi

# 3. SERVER_IP in full-auto.sh check
echo -e "\n🔗 full-auto.sh SERVER_IP:"
SCRIPT_URL=$(grep "SERVER_IP=" $HOME/full-auto.sh | head -1 | cut -d'"' -f2)
if [ -z "$SCRIPT_URL" ]; then
    echo -e "  ${RED}❌ SERVER_IP is EMPTY! Jobs will have broken endpoint!${NC}"
else
    echo -e "  ${GREEN}✅ $SCRIPT_URL${NC}"
fi

# 4. Last job on-chain check
echo -e "\n📋 Last Job On-Chain:"
LAST_JOB=$(grep "Inference done for job" $HOME/full-auto.log 2>/dev/null | tail -1 | awk '{print $NF}')
if [ ! -z "$LAST_JOB" ]; then
    JOB_INFO=$(republicd query computevalidation job $LAST_JOB --node tcp://localhost:43657 -o json 2>/dev/null)
    ENDPOINT=$(echo $JOB_INFO | jq -r '.job.result_fetch_endpoint' 2>/dev/null)
    STATUS=$(echo $JOB_INFO | jq -r '.job.status' 2>/dev/null)
    echo "  Job ID: $LAST_JOB"
    echo "  Status: $STATUS"
    echo "  Endpoint: $ENDPOINT"
    [[ "$ENDPOINT" == *"trycloudflare.com"* ]] && echo -e "  ${GREEN}✅ Endpoint looks correct${NC}" || echo -e "  ${RED}❌ Endpoint broken! (empty or localhost)${NC}"
fi

# 5. GPU check
echo -e "\n🎮 GPU:"
GPU_INFO=$(nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null)
if [ ! -z "$GPU_INFO" ]; then
    echo -e "  ${GREEN}✅ $GPU_INFO${NC}"
else
    echo -e "  ${YELLOW}⚠️  nvidia-smi not available${NC}"
fi

# 6. Validator status
echo -e "\n🎯 Validator:"
VAL_STATUS=$(republicd query staking validator raivaloper1xnjkyyggaz54288vtrsle9wjwqz5tz4lttk8ka --node tcp://localhost:43657 -o json 2>/dev/null | jq -r '.validator.status' 2>/dev/null)
[ "$VAL_STATUS" == "BOND_STATUS_BONDED" ] && echo -e "  ${GREEN}✅ BONDED (active)${NC}" || echo -e "  ${RED}❌ Status: $VAL_STATUS${NC}"

echo -e "\n================================="
echo "📊 Explorer: https://explorer.republicai.io/compute"
