#!/bin/bash
pkill -f "cloudflared tunnel" 2>/dev/null
sleep 2
cloudflared tunnel --url http://localhost:8080 --logfile /tmp/cloudflared.log &
sleep 8
NEW_URL=$(grep -o 'https://[a-z0-9-]*.trycloudflare.com' /tmp/cloudflared.log | tail -1)
if [ ! -z "$NEW_URL" ]; then
  echo $NEW_URL > /home/erhn/tunnel-url.txt
  sed -i "s|SERVER_IP=\".*trycloudflare.com\"|SERVER_IP=\"${NEW_URL#https://}\"|g" /home/erhn/full-auto.sh
  echo "URL güncellendi: $NEW_URL"
  # full-auto'yu yeniden başlat
  pkill -f "full-auto.sh" 2>/dev/null
  sleep 2
  nohup /home/erhn/full-auto.sh >> /home/erhn/full-auto.log 2>&1 &
  echo "full-auto yeniden başlatıldı: $!"
fi
# Tunnel'ın çalışmaya devam etmesi için bekle
wait
