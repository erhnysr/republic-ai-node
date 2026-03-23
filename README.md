<div align="center">

# 🚀 Republic AI Node

[![CI](https://github.com/erhnysr/republic-ai-node/actions/workflows/ci.yml/badge.svg)](https://github.com/erhnysr/republic-ai-node/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Chain](https://img.shields.io/badge/Chain-raitestnet__77701--1-blue)](https://explorer.republicai.io)
[![Validator](https://img.shields.io/badge/Validator-ERHANREPU-green)](https://explorer.republicai.io)
[![GPU](https://img.shields.io/badge/GPU-RTX%204050-76b900)](https://github.com/erhnysr/republic-ai-node)
[![Jobs](https://img.shields.io/badge/Jobs%20Processed-200K%2B-orange)](https://github.com/erhnysr/republic-ai-node)

**Production-ready toolkit for Republic AI validators**
*Full-auto GPU compute • Thermal protection • Cloudflare tunnel • WSL2 support*

[Quick Start](#quick-start) • [Documentation](#documentation) • [Scripts](#scripts) • [Monitoring](#monitoring)

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
│  │  (Cosmos)   │◄──►│  Job Submit → Inference   │    │
│  │  Port 43657 │    │  → Result Submit          │    │
│  └─────────────┘    └──────────┬───────────────┘    │
│                                │                     │
│  ┌─────────────┐    ┌──────────▼───────────────┐    │
│  │  Cloudflare │    │   Docker GPU Container    │    │
│  │   Tunnel    │◄──►│  republic-llm-inference   │    │
│  │  (Public)   │    │  RTX 4050 • CUDA          │    │
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
| `scripts/full-auto.sh` | Full job automation pipeline | ✅ |
| `scripts/watchdog.sh` | Auto-restart on crash | ✅ |
| `scripts/unjail.sh` | Auto-unjail monitor | ✅ |
| `scripts/monitor.sh` | Real-time dashboard | ✅ |
| `scripts/health_check.sh` | Node health checker | ✅ |
| `monitoring/gpu_tracker.py` | GPU metrics tracker | ✅ |
| `docker-compose.yml` | Full stack deployment | ✅ |

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
| [SETUP.md](docs/SETUP.md) | Full node setup guide |
| [AUTO-COMPUTE.md](docs/AUTO-COMPUTE.md) | Job automation guide |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common issues & fixes |
| [WSL2-GUIDE.md](docs/WSL2-GUIDE.md) | Windows WSL2 setup |

---

## ⚙️ Scripts

### Start Full-Auto Pipeline
```bash
# Start HTTP server
cd /var/lib/republic/jobs && python3 -m http.server 8080 &

# Start Cloudflare tunnel
cloudflared tunnel --url http://localhost:8080 &

# Start full-auto
nohup ~/full-auto.sh >> ~/full-auto.log 2>&1 &

# Start watchdog
nohup ~/watchdog.sh >> ~/watchdog.log 2>&1 &
```

### Monitor
```bash
# Real-time logs
tail -f ~/full-auto.log

# Health check
bash scripts/health_check.sh

# GPU status
nvidia-smi
```

---

## 📊 Performance

| Metric | Value |
|--------|-------|
| GPU | NVIDIA RTX 4050 Laptop (6GB) |
| Inference time | ~15-17 seconds |
| Jobs per hour | ~40-50 |
| Total jobs processed | 200,000+ |
| Success rate | 99.3% |
| Uptime | 24/7 |

---

## 🔧 Known Issues & Fixes

### Bech32 Address Bug
```bash
# submit-job-result sends 'rai' prefix instead of 'raivaloper'
# Fix: use --generate-only + python fix + manual sign
```
See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for full fix.

### WSL2 Public URL
```bash
# WSL2 has no public IP — use Cloudflare tunnel
cloudflared tunnel --url http://localhost:8080
```

---

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

1. Fork the repo
2. Create your branch: `git checkout -b feat/your-feature`
3. Commit: `git commit -m 'feat: add your feature'`
4. Push: `git push origin feat/your-feature`
5. Open a Pull Request

---

## 📬 Contact

- **Discord:** erhnysr
- **Twitter/X:** [@Erhnyasar](https://x.com/Erhnyasar)
- **Medium:** [@erhnysr](https://medium.com/@erhnysr)
- **Validator:** [ERHANREPU](https://explorer.republicai.io)

---

<div align="center">

**Built with ❤️ for the Republic AI community**

*If this helped you, please ⭐ star the repo!*

</div>
