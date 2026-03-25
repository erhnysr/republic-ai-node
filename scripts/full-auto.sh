#!/bin/bash

VALOPER="raivaloper1xnjkyyggaz54288vtrsle9wjwqz5tz4lttk8ka"
WALLET="rai1xnjkyyggaz54288vtrsle9wjwqz5tz4lv7k6at"
NODE="tcp://localhost:43657"
CHAIN_ID="raitestnet_77701-1"
SERVER_IP="webster-interpretation-declared-professionals.trycloudflare.com"
JOBS_DIR="/var/lib/republic/jobs"
JOB_FEE="5000000000000000arai"

echo "Full Auto started with thermal protection..."

while true; do
  SERVER_IP=$(cat /home/erhn/tunnel-url.txt | sed 's|https://||')
  # Ag kontrolu
  BLOCK=$(curl -s http://localhost:43657/status 2>/dev/null | jq -r ".result.sync_info.latest_block_height" 2>/dev/null)
  if [ -z "$BLOCK" ] || [ "$BLOCK" = "null" ]; then
    echo "Ag durdu, 60 saniye bekleniyor..."
    sleep 60
    continue
  fi
  echo "Block: $BLOCK"

  # Sicaklik kontrolu
  TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
  echo "GPU Temp: ${TEMP}C"

  if [ -n "$TEMP" ] && [ "$TEMP" -ge 85 ]; then
    echo "CRITICAL: ${TEMP}C - 5 dakika bekleniyor..."
    sleep 300
    continue
  elif [ -n "$TEMP" ] && [ "$TEMP" -ge 80 ]; then
    echo "HOT: ${TEMP}C - 3 dakika bekleniyor..."
    sleep 180
    continue
  elif [ -n "$TEMP" ] && [ "$TEMP" -ge 75 ]; then
    echo "WARM: ${TEMP}C - 90 saniye bekleniyor..."
    WAIT=90
  else
    echo "COOL: ${TEMP}C - Normal hiz"
    WAIT=30
  fi

  echo "Submitting new job..."
  TX=$(republicd tx computevalidation submit-job \
    $VALOPER \
    republic-llm-inference:latest \
    https://$SERVER_IP/upload \
    https://$SERVER_IP/result \
    example-verification:latest \
    $JOB_FEE \
    --from validator \
    --home $HOME/.republicd \
    --chain-id $CHAIN_ID \
    --gas auto \
    --gas-adjustment 1.5 \
    --gas-prices 1000000000arai \
    --node $NODE \
    --keyring-backend test \
    -y 2>/dev/null | grep txhash | awk '{print $2}')
  echo "TX: $TX"

  if [ -z "$TX" ]; then
    echo "TX bos, ag sorunu olabilir. 30 saniye bekleniyor..."
    sleep 30
    continue
  fi

  sleep 15

  JOB_ID=$(republicd query tx $TX --node $NODE -o json 2>/dev/null | \
    jq -r '.events[] | select(.type=="job_submitted") | .attributes[] | select(.key=="job_id") | .value')
  echo "Job ID: $JOB_ID"

  if [ -z "$JOB_ID" ]; then
    echo "Job ID not found, skipping..."
    sleep 30
    continue
  fi

  RESULT_FILE="$JOBS_DIR/$JOB_ID/result.bin"
  mkdir -p $JOBS_DIR/$JOB_ID

  timeout 60 docker run --rm --gpus all \
    -v $JOBS_DIR/$JOB_ID:/output \
    republic-llm-inference:latest 2>/dev/null

  if [ $? -ne 0 ]; then
    echo "Docker error for job $JOB_ID, skipping..."
    sleep 30
    continue
  fi

  echo "Inference done for job $JOB_ID"

  if [ -f "$RESULT_FILE" ]; then
    SHA256=$(sha256sum $RESULT_FILE | awk '{print $1}')

    republicd tx computevalidation submit-job-result \
      $JOB_ID \
      https://$SERVER_IP/$JOB_ID/result.bin \
      example-verification:latest \
      $SHA256 \
      --from validator \
      --home $HOME/.republicd \
      --chain-id $CHAIN_ID \
      --gas 300000 \
      --gas-prices 1000000000arai \
      --node $NODE \
      --keyring-backend test \
      --generate-only 2>/dev/null > /tmp/tx_unsigned.json

    python3 -c "
import bech32, json
tx = json.load(open('/tmp/tx_unsigned.json'))
_, data = bech32.bech32_decode('$WALLET')
valoper = bech32.bech32_encode('raivaloper', data)
tx['body']['messages'][0]['validator'] = valoper
json.dump(tx, open('/tmp/tx_unsigned.json', 'w'))
print('Fixed:', valoper)
"

    republicd tx sign /tmp/tx_unsigned.json \
      --from validator \
      --home $HOME/.republicd \
      --chain-id $CHAIN_ID \
      --node $NODE \
      --keyring-backend test \
      --output-document /tmp/tx_signed.json 2>/dev/null

    republicd tx broadcast /tmp/tx_signed.json \
      --node $NODE \
      --chain-id $CHAIN_ID 2>/dev/null | grep txhash | \
      awk '{print "Job '$JOB_ID' submitted! TX: "$2}'

    sleep 15
  fi

  echo "Waiting ${WAIT} seconds..."
  sleep $WAIT
done
