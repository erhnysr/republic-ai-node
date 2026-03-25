#!/bin/bash
echo "Watchdog started..."

while true; do
  # full-auto kontrolü
  if ! pgrep -f "full-auto.sh" > /dev/null; then
    echo "[$(date '+%H:%M:%S')] full-auto.sh stopped! Restarting..."
    nohup ~/full-auto.sh >> ~/full-auto.log 2>&1 &
    echo "[$(date '+%H:%M:%S')] Restarted! PID: $!"
  fi

  # Cloudflare tunnel kontrolü
  if ! pgrep -f "cloudflared" > /dev/null; then
    echo "[$(date '+%H:%M:%S')] Cloudflare tunnel stopped! Restarting..."
    nohup cloudflared tunnel --url http://localhost:8080 > /tmp/cloudflare.log 2>&1 &
    sleep 8
    NEW_URL=$(grep -i "trycloudflare" /tmp/cloudflare.log | grep "https://" | awk '{print $NF}')
    echo "[$(date '+%H:%M:%S')] New tunnel URL: $NEW_URL"
    # full-auto.sh'daki URL'yi güncelle
    OLD_URL=$(grep "SERVER_IP=" ~/full-auto.sh | cut -d'"' -f2)
    sed -i "s|$OLD_URL|$NEW_URL|g" ~/full-auto.sh
    echo "[$(date '+%H:%M:%S')] full-auto.sh updated with new URL"
    # full-auto'yu yeniden başlat
    pkill -f "full-auto.sh"
    sleep 2
    nohup ~/full-auto.sh >> ~/full-auto.log 2>&1 &
    echo "[$(date '+%H:%M:%S')] full-auto restarted with new URL!"
  fi

  # HTTP server kontrolü
  if ! pgrep -f "http.server" > /dev/null; then
    echo "[$(date '+%H:%M:%S')] HTTP server stopped! Restarting..."
    cd /var/lib/republic/jobs && nohup python3 -m http.server 8080 > /tmp/http.log 2>&1 &
    echo "[$(date '+%H:%M:%S')] HTTP server restarted!"
  fi

  sleep 30
done
