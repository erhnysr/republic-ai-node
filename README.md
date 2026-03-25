<div align="center">

# 🚀 Republic AI Node

[![CI](https://github.com/erhnysr/republic-ai-node/actions/workflows/ci.yml/badge.svg)](https://github.com/erhnysr/republic-ai-node/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Chain](https://img.shields.io/badge/Chain-raitestnet__77701--1-blue)](https://explorer.republicai.io)
[![Validator](https://img.shields.io/badge/Validator-ERHANREPU-green)](https://explorer.republicai.io)
[![GPU](https://img.shields.io/badge/GPU-RTX%204050-76b900)](https://github.com/erhnysr/republic-ai-node)
[![Rank](https://img.shields.io/badge/Leaderboard-%234%20Top%20Validator-gold)](https://explorer.republicai.io/compute)
[![Success Rate](https://img.shields.io/badge/Success%20Rate-94.6%25-brightgreen)](https://explorer.republicai.io/compute)

**Production-ready toolkit for Republic AI validators**
*Full-auto GPU compute • Thermal protection • Cloudflare tunnel • WSL2 support*

[Quick Start](#quick-start) • [Documentation](#documentation) • [Scripts](#scripts) • [Troubleshooting](#troubleshooting)

</div>

---

## ⚡ Quick Start
```bash
curl -sSL https://raw.githubusercontent.com/erhnysr/republic-ai-node/main/scripts/install.sh | bash
```

---

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────┐
│                  Republic AI Node                    │
│                                                      │
│  ┌─────────────┐    ┌──────────────────────────┐    │
│  │  republicd  │    │     full-auto.sh          │    │
│  │  (Cosmos)   │◄──►│  Submit → Inference       │    │
│  │  Port 43657 │    │  → Bech32 Fix → Submit    │    │
│  └─────────────┘    └──────────┬───────────────┘    │
│                                │                     │
│  ┌─────────────┐    ┌──────────▼───────────────┐    │
│  │  Cloudflare │    │   Docker GPU Container    │    │
│  │   Tunnel    │◄──►│  republic-llm-inference   │    │
│  │  (Public)   │    │  RTX 4050 • CUDA 11.8     │    │
│  └─────────────┘    └──────────────────────────┘    │
│                                                      │
│  ┌─────────────┐    ┌──────────────────────────┐    │
│  │  watchdog   │    │    HTTP Server :8080      │    │
│  │  (Monitor)  │    │  /var/lib/republic/jobs   │    │
│  └─────────────┘    └──────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

---

## 📦 What's Included

| Component | Description | Status |
|-----------|-------------|--------|
| `scripts/install.sh` | One-command node installer | ✅ |
| `scripts/full-auto.sh` | Full job automation + thermal protection | ✅ |
| `scripts/watchdog.sh` | Auto-restart on crash | ✅ |
| `scripts/start-tunnel.sh` | Cloudflare tunnel + auto URL update | ✅ |
| `scripts/health_check.sh` | Full node health checker | ✅ |
| `systemd/` | Production systemd service files | ✅ |
| `docs/WSL2-GUIDE.md` | WSL2 public URL solution | ✅ |
| `docs/TROUBLESHOOTING.md` | Real issues & battle-tested fixes | ✅ |
| `docs/AUTO-COMPUTE.md` | Job automation guide | ✅ |
| `monitoring/gpu_tracker.py` | GPU metrics tracker | ✅ |

---

## 🖥️ System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Ubuntu 22.04 | Ubuntu 24.04 / WSL2 |
| CPU | 4 cores | 8+ cores |
| RAM | 8 GB | 16 GB |
| Storage | 100 GB SSD | 200 GB NVMe |
| GPU | GTX 1080 (8GB) | RTX 3090+ (24GB) |
| Network | 100 Mbps | 1 Gbps |

---

## 📖 Documentation

| Guide | Description |
|-------|-------------|
| [WSL2-GUIDE.md](docs/WSL2-GUIDE.md) | Critical: public URL setup for WSL2 |
| [AUTO-COMPUTE.md](docs/AUTO-COMPUTE.md) | Full job automation guide |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Real issues & battle-tested fixes |

---

## ⚙️ Scripts

### Start Full-Auto Pipeline
```bash
# 1. Start Cloudflare tunnel (WSL2 only)
sudo systemctl start cloudflare-tunnel.service

# 2. Start full-auto
nohup ~/full-auto.sh >> ~/full-auto.log 2>&1 &

# 3. Start watchdog
nohup ~/watchdog.sh >> ~/watchdog.log 2>&1 &

# 4. Health check
bash scripts/health_check.sh
```

### Monitor
```bash
tail -f ~/full-auto.log
bash scripts/health_check.sh
```

---

## 🔧 Known Issues & Fixes

### ⚠️ WSL2: result_fetch_endpoint Empty
Most common issue. Check immediately if team says "endpoint not reachable":
```bash
grep "SERVER_IP" ~/full-auto.sh  # Must NOT be empty!
```
→ Full fix: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

### ⚠️ Bech32 Address Bug
`submit-job-result` sends `rai` prefix instead of `raivaloper` — TX rejected.
→ Already handled in `full-auto.sh` via Python fix.

### ⚠️ Wrong Key Name
Sidecar running with `--from wallet` but key name is `validator`.
→ Full fix: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

---

## 📊 Performance

| Metric | Value |
|--------|-------|
| GPU | NVIDIA RTX 4050 Laptop (6GB) |
| Inference time | ~15-17 seconds |
| Jobs per hour | ~40-50 |
| Total jobs processed | 725,000+ |
| Success rate | 94.6% |
| Leaderboard rank | #4 |

---

## 📬 Contact

- **Discord:** erhnysr
- **Twitter/X:** [@Erhnyasar](https://x.com/Erhnyasar)
- **Validator:** [ERHANREPU on Explorer](https://explorer.republicai.io/compute)

---

<div align="center">

**Built with ❤️ for the Republic AI community**

*If this helped you, please ⭐ star the repo!*

</div>
