# 🚀 Republic AI Node Setup

Complete setup guide for running a Republic AI validator node with GPU mining capabilities.

![Republic AI](https://img.shields.io/badge/Republic-AI-purple)
![Status](https://img.shields.io/badge/Status-Active-success)
![GPU](https://img.shields.io/badge/GPU-RTX%204050-green)

## 📊 My Node Stats
- **Validator Address:** `raivaloper1xnjkyyggaz54288vtrsle9wjwqz5tz4lttk8ka`
- **Voting Power:** 4,003 RAI
- **Status:** Active ✅
- **GPU:** NVIDIA RTX 4050 8GB
- **Uptime:** 99.9%

## 🎯 Features
- ✅ Automated validator node setup
- ✅ GPU mining integration
- ✅ Real-time monitoring dashboard
- ✅ Auto job execution
- ✅ Performance tracking

## 📋 Prerequisites
- Ubuntu 22.04+ (WSL2 supported)
- NVIDIA GPU with CUDA 11.8+
- Docker with GPU support
- 16GB+ RAM
- 500GB+ SSD

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/republic-ai-node.git
cd republic-ai-node
```

### 2. Setup Validator
```bash
chmod +x scripts/auto_compute.sh
./scripts/auto_compute.sh
```

### 3. Monitor Node
Open `index.html` in your browser to see real-time stats.

## 📁 Project Structure
```
republic-ai-node/
├── index.html          # Monitoring dashboard
├── scripts/
│   └── auto_compute.sh # Automated compute script
├── docs/
│   └── setup.md        # Detailed setup guide
└── README.md
```

## 🔧 Configuration

### Key Setup
```bash
republicd keys add wallet --keyring-backend test
```

### Job Sidecar
```bash
republicd tx computevalidation job-sidecar \
  --from wallet \
  --chain-id raitestnet_77701-1 \
  --node tcp://localhost:43657
```

## 📈 Performance
- Block processing: ~5 seconds
- GPU inference: ~8 seconds
- Job throughput: 10+ jobs/day

## 🤝 Contributing
Contributions welcome! Feel free to open issues or PRs.

## 📝 License
MIT License

## 🔗 Links
- [Official Docs](https://docs.republicai.io)
- [Explorer](https://explorer.republicai.io)
- [Discord](https://discord.gg/republicai)

---
Made with ❤️ by Erhan

## 🐳 Docker Deployment
```bash
docker-compose up -d
```

## 📊 GPU Monitoring
```bash
python3 monitoring/gpu_tracker.py
```

## 🔄 CI/CD
GitHub Actions automatically tests all commits.

