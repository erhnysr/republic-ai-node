#!/bin/bash
# Republic AI Node - One Command Installer
# Usage: curl -sSL https://raw.githubusercontent.com/erhnysr/republic-ai-node/main/scripts/install.sh | bash

set -e

echo "🚀 Republic AI Node Installer"
echo "=============================="
echo ""

# Detect OS
if grep -qi microsoft /proc/version; then
    OS="WSL"
    echo "✓ Detected: Windows WSL2"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    echo "✓ Detected: Linux VPS"
else
    echo "❌ Unsupported OS"
    exit 1
fi

# Check if running as root (for VPS)
if [[ $EUID -ne 0 ]] && [[ "$OS" == "Linux" ]]; then
   echo "⚠️  Run as root on VPS: sudo bash install.sh"
   exit 1
fi

echo ""
echo "📦 Installing dependencies..."

# Update system
apt update -qq
apt install -y curl git build-essential jq wget ca-certificates gnupg > /dev/null 2>&1

# Install Go
if ! command -v go &> /dev/null; then
    echo "📥 Installing Go 1.21.6..."
    wget -q https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
    rm go1.21.6.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    echo "✓ Go installed"
else
    echo "✓ Go already installed ($(go version))"
fi

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "📥 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh > /dev/null 2>&1
    rm get-docker.sh
    systemctl start docker
    systemctl enable docker
    usermod -aG docker $USER || true
    echo "✓ Docker installed"
else
    echo "✓ Docker already installed ($(docker --version))"
fi

# Install republicd binary
echo "📥 Installing republicd..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/RepublicAI/networks/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -L "https://github.com/RepublicAI/networks/releases/download/${LATEST_VERSION}/republicd-linux-amd64" -o /usr/local/bin/republicd
chmod +x /usr/local/bin/republicd
echo "✓ republicd installed (${LATEST_VERSION})"

# Create directory structure
echo "📁 Setting up directories..."
mkdir -p ~/.republic/config
mkdir -p ~/republic-ai-node/{scripts,monitoring,docs,logs}

echo ""
echo "🎉 Installation complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1️⃣  Initialize validator:"
echo "   republicd init <YOUR_MONIKER> --chain-id raitestnet_77701-1 --home ~/.republic"
echo ""
echo "2️⃣  Download genesis:"
echo "   curl -o ~/.republic/config/genesis.json https://rpc.testnet.republicai.io/genesis"
echo ""
echo "3️⃣  Add peers to ~/.republic/config/config.toml"
echo ""
echo "4️⃣  Create wallet:"
echo "   republicd keys add <KEY_NAME> --home ~/.republic"
echo ""
echo "5️⃣  Setup systemd service (VPS) or start manually"
echo ""
echo "📚 Full documentation: https://github.com/erhnysr/republic-ai-node"
echo "💬 Support: Republic AI Discord"
echo ""
