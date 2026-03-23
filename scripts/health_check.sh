#!/bin/bash
# Republic AI Node - Health Check Script
# Checks validator status, sync status, and alerts if issues found

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Republic AI Node Health Check"
echo "================================="
echo ""

# Check if republicd is installed
if ! command -v republicd &> /dev/null; then
    echo -e "${RED}❌ republicd not found!${NC}"
    echo "Install: curl -sSL https://raw.githubusercontent.com/erhnysr/republic-ai-node/main/scripts/install.sh | bash"
    exit 1
fi

# Check if service is running
echo "📊 Checking service status..."
if systemctl is-active --quiet republicd 2>/dev/null; then
    echo -e "${GREEN}✓ Service is running${NC}"
    UPTIME=$(systemctl show -p ActiveEnterTimestamp republicd | cut -d'=' -f2)
    echo "  Uptime: $UPTIME"
else
    if pgrep -x "republicd" > /dev/null; then
        echo -e "${YELLOW}⚠ Process running but no systemd service${NC}"
    else
        echo -e "${RED}❌ republicd is NOT running!${NC}"
        exit 1
    fi
fi

echo ""
echo "🔗 Checking node status..."

# Get node status
STATUS=$(republicd status 2>&1 || echo "error")

if [[ "$STATUS" == "error" ]]; then
    echo -e "${RED}❌ Cannot connect to node${NC}"
    exit 1
fi

# Parse status
BLOCK_HEIGHT=$(echo $STATUS | jq -r '.sync_info.latest_block_height' 2>/dev/null || echo "N/A")
CATCHING_UP=$(echo $STATUS | jq -r '.sync_info.catching_up' 2>/dev/null || echo "N/A")
VOTING_POWER=$(echo $STATUS | jq -r '.validator_info.voting_power' 2>/dev/null || echo "0")
MONIKER=$(echo $STATUS | jq -r '.node_info.moniker' 2>/dev/null || echo "N/A")

echo "  Moniker: $MONIKER"
echo "  Block Height: $BLOCK_HEIGHT"
echo "  Voting Power: $VOTING_POWER"

# Check sync status
if [[ "$CATCHING_UP" == "false" ]]; then
    echo -e "  Sync: ${GREEN}✓ Synced${NC}"
else
    echo -e "  Sync: ${YELLOW}⚠ Catching up...${NC}"
fi

echo ""
echo "🎯 Checking validator status..."

# Get validator info (replace with your validator address)
VALIDATOR_ADDR="raivaloper1xnjkyyggaz54288vtrsle9wjwqz5tz4lttk8ka"
VAL_INFO=$(republicd query staking validator $VALIDATOR_ADDR --home ~/.republic 2>&1 || echo "error")

if [[ "$VAL_INFO" == "error" ]] || [[ "$VAL_INFO" == *"not found"* ]]; then
    echo -e "${YELLOW}⚠ Validator info not available${NC}"
else
    VAL_STATUS=$(echo $VAL_INFO | grep -oP 'status: \K\S+' || echo "N/A")
    VAL_TOKENS=$(echo $VAL_INFO | grep -oP 'tokens: "\K[^"]+' || echo "0")
    
    echo "  Status: $VAL_STATUS"
    echo "  Tokens: $VAL_TOKENS"
    
    if [[ "$VAL_STATUS" == "BOND_STATUS_BONDED" ]]; then
        echo -e "  ${GREEN}✓ Validator is ACTIVE${NC}"
    elif [[ "$VAL_STATUS" == "BOND_STATUS_UNBONDING" ]]; then
        echo -e "  ${RED}❌ Validator is UNBONDING!${NC}"
        echo "  Fix: republicd tx slashing unjail --from <KEY> --chain-id raitestnet_77701-1"
    else
        echo -e "  ${YELLOW}⚠ Validator status: $VAL_STATUS${NC}"
    fi
fi

echo ""
echo "💾 System Resources..."

# Check disk space
DISK_USAGE=$(df -h ~/.republic | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo -e "  Disk: ${RED}❌ ${DISK_USAGE}% used (WARNING!)${NC}"
else
    echo -e "  Disk: ${GREEN}✓ ${DISK_USAGE}% used${NC}"
fi

# Check memory
MEM_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
if [ "$MEM_USAGE" -gt 90 ]; then
    echo -e "  Memory: ${RED}❌ ${MEM_USAGE}% used${NC}"
else
    echo -e "  Memory: ${GREEN}✓ ${MEM_USAGE}% used${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Health check complete!${NC}"
echo ""
