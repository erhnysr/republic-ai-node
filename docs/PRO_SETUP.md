# Pro Setup

This setup adds lightweight production monitoring for a Republic AI node environment.

## Current Architecture

### VPS
- Runs `republicd`
- Uses a watchdog timer to monitor:
  - service status
  - block progress
  - catching_up
  - jailed state

### WSL
- Runs `full-auto.sh`
- Uses a lightweight watchdog to monitor:
  - `full-auto.sh`
  - GPU availability via `nvidia-smi`

### Explicitly NOT monitored by WSL watchdog
- `cloudflared`
- `http.server`

These were intentionally removed from WSL watchdog handling to avoid interference with custom stable tunnel/server configuration.

---

## Telegram

export TELEGRAM_BOT_TOKEN="YOUR_TOKEN"
export TELEGRAM_CHAT_ID="YOUR_CHAT_ID"

