# ⚡ ErhNode

**Decentralized AI Infrastructure Engineer**  
Validator Node Operator • GPU Compute • LLM Inference  

---

## 🚀 Overview

ErhNode builds and operates **production-grade decentralized AI infrastructure** across multiple ecosystems.

Focused on:

- Validator operations  
- GPU inference pipelines  
- Automation & self-healing systems  
- Real-world workload optimization  

---

## 🧠 Active Ecosystems

- Republic AI (Validator + Compute Node)
- Shelby (Early Access Contributor)
- Nous Hermes (Dev Contributor)

---

## ⚙️ Infrastructure Stack

- VPS Validator Node (Cosmos-based)
- WSL2 GPU Compute Environment
- Cloudflare Tunnel (externally managed)
- Python-based inference + job execution
- Bash automation & watchdog systems

---

## 📊 Performance

- 94.6% success rate  
- 725,000+ completed jobs  
- Top validator (Top #4 range)  
- 24/7 stable uptime  

---

## ⚙️ Pro Setup

Production-ready monitoring system for hybrid environments (VPS + WSL).

Includes:

- VPS validator watchdog  
- WSL full-auto monitoring  
- GPU health checks  
- Telegram alert system  

👉 Full setup guide:  
`docs/PRO_SETUP.md`

---

## 🔍 Monitoring Design

### VPS
- Monitors `republicd`
- Detects block stall
- Detects validator issues (jailed / catching_up)
- Auto-restart with cooldown protection

### WSL
- Monitors `full-auto.sh`
- Monitors GPU availability
- Auto-restart for compute process only

### Explicitly NOT managed
- cloudflared  
- http server  

These are intentionally excluded to prevent instability and restart loops.

---

## 🔔 Alert System

Telegram-based alerting:

- Critical → GPU missing, node down  
- Warning → process restart  

No alert spam (state-based notifications).

---

## 🧩 Philosophy

- Minimal interference  
- Maximum stability  
- Real-world reliability over theory  

---

## ⚡ Notes

This setup is designed for:

- Long-running workloads  
- High success-rate execution  
- Stable endpoint exposure  
- Autonomous recovery  

---

## 🧠 Operator

**ErhNode**

Decentralized AI Infrastructure Builder  
Focused on reliability, performance, and production-ready systems.
