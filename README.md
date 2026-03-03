<div align="center">

# 🤖 Republic AI — Validator Node Setup

**Complete guide for running a Republic AI validator node on WSL2/Ubuntu with GPU compute support**

[![Republic AI](https://img.shields.io/badge/Republic_AI-Testnet-6366f1?style=for-the-badge&logo=ethereum&logoColor=white)](https://republicai.io)
[![Status](https://img.shields.io/badge/Status-Active_Validator-success?style=for-the-badge)](https://github.com/erhnysr/republic-ai-node)
[![GPU](https://img.shields.io/badge/GPU-RTX_4050_CUDA_11.8-76b900?style=for-the-badge&logo=nvidia&logoColor=white)](https://github.com/erhnysr/republic-ai-node)
[![OS](https://img.shields.io/badge/WSL2-Ubuntu_24.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://github.com/erhnysr/republic-ai-node)

</div>

---

## 📊 My Validator Stats

| Property | Value |
|----------|-------|
| **Validator Address** | raivaloper1xnjkyyggaz54288vtrsle9wjwqz5tz4lttk8ka |
| **Chain ID** | raitestnet_77701-1 |
| **Voting Power** | 6,469 RAI |
| **GPU** | NVIDIA RTX 4050 Laptop — 6GB VRAM |
| **Inference Speed** | ~8s per job (GPU) |
| **Status** | Active & Synced |

---

## 📋 Prerequisites

- Ubuntu 22.04+ or WSL2 (Ubuntu 24.04)
- NVIDIA GPU with CUDA 11.8+
- Docker with GPU support (nvidia-container-toolkit)
- 16GB+ RAM, 500GB+ SSD
- Go 1.22.3+

---

## 🚀 Quick Start

### 1. Install Dependencies

    sudo apt update && sudo apt install -y build-essential git jq curl wget patchelf

### 2. Install Go 1.22.3

    cd $HOME && wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
    source $HOME/.bash_profile

### 3. Install Cosmovisor

    go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

### 4. Install Republic AI Binary

    VERSION="v0.1.0"
    mkdir -p $HOME/.republicd/cosmovisor/genesis/bin
    curl -L "https://media.githubusercontent.com/media/RepublicAI/networks/main/testnet/releases/${VERSION}/republicd-linux-amd64" -o republicd
    chmod +x republicd
    patchelf --set-interpreter /opt/glibc-2.39/lib/ld-linux-x86-64.so.2 republicd
    patchelf --set-rpath /opt/glibc-2.39/lib republicd
    mv republicd $HOME/.republicd/cosmovisor/genesis/bin/
    sudo ln -sf $HOME/.republicd/cosmovisor/genesis/bin/republicd /usr/local/bin/republicd

### 5. Initialize Node

    republicd init YOUR_MONIKER --chain-id raitestnet_77701-1 --home $HOME/.republicd
    curl -s https://raw.githubusercontent.com/RepublicAI/networks/main/testnet/genesis.json > $HOME/.republicd/config/genesis.json

---

## 🖥️ GPU Compute Setup

### Verify GPU

    nvidia-smi
    docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

### Build Inference Image

    git clone https://github.com/RepublicAI/devtools.git
    cd devtools/containers/llm-inference
    docker build -t republic-llm-inference:latest .

### Run a Compute Job

    JOB_ID=34
    mkdir -p /var/lib/republic/jobs/$JOB_ID
    docker run --rm --gpus all -v /var/lib/republic/jobs/$JOB_ID:/output republic-llm-inference:latest

---

## 🔧 Useful Commands

    # Check sync status
    republicd status --node tcp://localhost:43657 | jq ".sync_info"

    # View logs
    sudo journalctl -u republicd -f --no-hostname -o cat

    # Check pending jobs
    republicd query computevalidation list-job --node tcp://localhost:43657 --output json

---

## ⚡ Performance

| Metric | Value |
|--------|-------|
| Block sync speed | ~5,000 blocks/min |
| GPU inference time | ~15 seconds |
| Node uptime | 99.9% |
| CUDA version | 11.8 |

---

## 🔗 Resources

- [Republic AI Official Docs](https://docs.republicai.io)
- [Republic AI Networks Repo](https://github.com/RepublicAI/networks)
- [Republic AI Discord](https://discord.gg/republicai)

---

<div align="center">

*Built with love by [@Erhnysr](https://github.com/erhnysr) — Running on WSL2 + RTX 4050*

</div>
