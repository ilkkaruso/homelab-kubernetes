# Homelab Kubernetes Cluster

[![Kubernetes](https://img.shields.io/badge/kubernetes-v1.28-blue?logo=kubernetes)](https://kubernetes.io/)
[![K3s](https://img.shields.io/badge/K3s-lightweight-green?logo=kubernetes)](https://k3s.io/)
[![Monitoring](https://img.shields.io/badge/monitoring-prometheus%20%2B%20grafana-orange?logo=prometheus)](https://prometheus.io/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen.svg)](https://github.com/ilkkaruso/homelab-kubernetes/commits/main)

> 🚀 Production-grade Kubernetes homelab running on bare metal, showcasing DevOps best practices, GitOps workflows, and real-world cloud-native applications.

<p align="center">
  <a href="#-overview">Overview</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-applications">Applications</a> •
  <a href="#-monitoring">Monitoring</a> •
  <a href="#-roadmap">Roadmap</a> •
  <a href="#-skills-demonstrated">Skills</a>
</p>

---

## 🎯 Overview

This homelab demonstrates enterprise-grade Kubernetes deployment on bare metal infrastructure. Built from scratch to learn cloud-native technologies, container orchestration, and DevOps practices aligned with industry Kubernetes Operator Development roles.

**Deployed Applications:** Jellyfin media server with remote access, comprehensive monitoring stack

---

## 🏗️ Architecture

### Hardware Infrastructure

| Node | Role | CPU | RAM | IP Address | Workloads |
|------|------|-----|-----|------------|-----------|
| **k3s-master** | Control Plane + Worker | Intel i5-8400T (6c) | 16GB | 192.168.1.50 | Control plane, monitoring |
| **k3s-worker1** | Worker | Intel i5-8400T (6c) | 8GB | 192.168.1.51 | Jellyfin, media storage |

### Software Stack
```
┌─────────────────────────────────────────────────────────┐
│                    Internet / Users                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─→ Cloudflare Tunnel (secure remote access)
                     │   └─→ No Port Forwarding Required
                     │
                     ├─→ MetalLB Load Balancer (192.168.1.200-210)
                     │   └─→ Nginx Ingress Controller (192.168.1.200)
                     │       ├─→ TLS Termination (Cert-Manager)
                     │       ├─→ jellyfin.homelab.local
                     │       ├─→ grafana.homelab.local
                     │       └─→ prometheus.homelab.local
                     │
┌────────────────────┴────────────────────────────────────┐
│              Kubernetes Cluster (K3s)                   │
├─────────────────────────────────────────────────────────┤
│  Namespaces:                                            │
│  • jellyfin      → Media Server (Worker Node)           │
│  • monitoring    → Prometheus + Grafana                 │
│  • cloudflare    → Tunnel Connector                     │
│  • ingress-nginx → HTTP/HTTPS Routing                   │
│  • metallb       → Load Balancing (L2)                  │
│  • cert-manager  → Automated TLS Certificates           │
└─────────────────────────────────────────────────────────┘
```

### Network Configuration

- **Router:** 192.168.1.1
- **Static IP Range:** 192.168.1.50-99 (infrastructure)
- **MetalLB Pool:** 192.168.1.200-210
- **Ingress Controller IP:** 192.168.1.200
- **Upload Bandwidth:** 51 Mbps (supports 4-6 concurrent 1080p streams)

---

## 📊 Current Status

| Component | Version | Status | Access |
|-----------|---------|--------|--------|
| **K3s** | v1.28+ | ![Status](https://img.shields.io/badge/status-running-success) | 2 nodes |
| **MetalLB** | v0.14.8 | ![Status](https://img.shields.io/badge/status-deployed-success) | L2 mode |
| **Nginx Ingress** | v1.11.1 | ![Status](https://img.shields.io/badge/status-deployed-success) | Port 80/443 |
| **Cert-Manager** | v1.15.3 | ![Status](https://img.shields.io/badge/status-deployed-success) | Self-signed |
| **Prometheus** | v2.x | ![Status](https://img.shields.io/badge/status-running-success) | Local network |
| **Grafana** | v11.x | ![Status](https://img.shields.io/badge/status-running-success) | Local network |
| **Jellyfin** | Latest | ![Status](https://img.shields.io/badge/status-running-success) | Remote + Local |
| **Cloudflare Tunnel** | Latest | ![Status](https://img.shields.io/badge/status-connected-success) | Active |

---

## 🚀 Applications

### 📺 Jellyfin Media Server

Self-hosted media streaming platform with hardware transcoding capabilities.

**Features:**
- 🎬 100GB+ media library (TV shows, movies)
- 🌐 Secure remote access via Cloudflare Tunnel
- 🔒 Zero port forwarding (encrypted tunnel)
- 👥 Multi-user support with access controls
- 📊 Real-time monitoring with Prometheus
- 💾 Persistent storage with local-path provisioner

**Technical Details:**
- **Deployment:** Kubernetes Deployment with PersistentVolumeClaims
- **Storage:** 10Gi config + 100Gi media
- **Node Placement:** Pinned to worker node (nodeSelector)
- **Capacity:** Supports 4-6 concurrent 1080p streams
- **Access:**
  - Remote: Via Cloudflare Tunnel (secure)
  - Local: local.homelab. etc 

**Monitoring:**
- CPU/Memory usage tracked via Prometheus
- Custom Grafana dashboard for stream analytics
- Alert rules for downtime and high resource usage

---

## 📈 Monitoring & Observability

### Prometheus + Grafana Stack

Comprehensive metrics collection and visualization for cluster health.

**Components:**
- **Prometheus** - Time-series metrics database (7 days retention, 20Gi storage)
- **Grafana** - Visualization dashboards (10Gi persistent storage)
- **Alertmanager** - Alert routing and notifications
- **Node Exporter** - Host-level metrics (both nodes)
- **Kube State Metrics** - Kubernetes object metrics

**Dashboards:**
- 📊 Cluster Overview (CPU, Memory, Network)
- 🖥️ Node Metrics (per-node resource usage)
- 🎬 Jellyfin Application Metrics
- 📦 Namespace Resource Usage
- 🌐 Ingress Controller Traffic

**Metrics Collected:**
- Container CPU/Memory usage
- Network I/O per pod
- Disk usage per PVC
- HTTP request rates (Ingress)
- Pod restart counts
- Node resource utilization

---

## 🔧 Infrastructure Components

### Load Balancing - MetalLB

Bare metal load balancer providing external IPs to Kubernetes services.

- **Mode:** Layer 2 (ARP)
- **IP Pool:** 192.168.1.200-210
- **Allocated:** 192.168.1.200 (Ingress Controller)
- **Available:** 9 IPs for future services

### Ingress & Routing - Nginx Ingress Controller

HTTP/HTTPS traffic routing with TLS termination.

- **Single IP:** 192.168.1.200 serves all applications
- **Hostname-based routing:** Multiple domains → same IP
- **TLS:** Automated via cert-manager
- **WebSocket support:** Enabled for real-time apps

### Certificate Management - Cert-Manager

Automated TLS certificate provisioning and renewal.

- **ClusterIssuer:** selfsigned-issuer (for homelab)
- **Auto-renewal:** 30 days before expiry
- **Integration:** Automatic Ingress certificate creation
- **Future:** Let's Encrypt support (when exposed publicly)

### Remote Access - Cloudflare Tunnel

Zero Trust network access without port forwarding.

- **cloudflared** connector in Kubernetes
- **Encrypted tunnel** to Cloudflare edge
- **No firewall changes** required
- **DDoS protection** included
- **DNS automatic** via Cloudflare

---

## 📁 Repository Structure
```
homelab-kubernetes/
├── applications/          # Application deployments
│   ├── jellyfin/         # Media server manifests
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── storage.yaml
│   │   └── namespace.yaml
│   └── cloudflare/       # Tunnel connector
│       ├── deployment.yaml
│       └── namespace.yaml
├── infrastructure/        # Core infrastructure (future)
│   ├── metallb/
│   ├── ingress/
│   └── cert-manager/
├── monitoring/           # Observability stack
│   ├── prometheus/
│   │   ├── ingress.yaml
│   │   └── values.yaml
│   └── grafana/
│       └── ingress.yaml
├── scripts/              # Automation scripts
│   ├── sanitize-yaml.sh
│   └── pre-commit-check.sh
├── docs/                 # Documentation
│   ├── architecture.md
│   ├── setup-guide.md
│   └── screenshots/
├── .gitignore           # Secrets protection
├── README.md            # This file
└── LICENSE              # MIT License
```

---

## 🎓 Skills Demonstrated

### Kubernetes Administration
- ✅ Cluster deployment and configuration (K3s)
- ✅ Multi-node cluster management
- ✅ Resource management (Deployments, Services, Ingress)
- ✅ Persistent storage with PVCs
- ✅ Node placement strategies (nodeSelector)
- ✅ Namespace organization and isolation
- ✅ ConfigMaps and Secrets management

### Networking
- ✅ MetalLB load balancer configuration
- ✅ Ingress controller setup and routing
- ✅ DNS configuration and hostname routing
- ✅ TLS/SSL certificate management
- ✅ Cloudflare Tunnel integration
- ✅ Network troubleshooting and debugging

### Monitoring & Observability
- ✅ Prometheus metrics collection
- ✅ Grafana dashboard creation
- ✅ PromQL query writing
- ✅ Alert rule configuration
- ✅ Helm chart deployment and management
- ✅ Service monitoring best practices

### DevOps Practices
- ✅ Infrastructure as Code (IaC)
- ✅ Version control with Git
- ✅ Documentation and diagramming
- ✅ Security best practices (secrets management)
- ✅ GitOps workflow (in progress)
- ✅ Automated testing (pre-commit checks)

### Security
- ✅ TLS encryption
- ✅ Secret management (Kubernetes Secrets)
- ✅ Zero Trust networking (Cloudflare Tunnel)
- ✅ Access control (RBAC - planned)
- ✅ Network policies (planned)

---

## 🎯 Roadmap

### ✅ Phase 1: Foundation (Complete)
- [x] K3s cluster deployment (2 nodes)
- [x] MetalLB load balancer
- [x] Nginx Ingress with TLS
- [x] Cert-manager for certificates
- [x] Jellyfin media server
- [x] Cloudflare Tunnel for remote access
- [x] Prometheus + Grafana monitoring
- [x] GitHub repository with documentation

### 🚧 Phase 2: GitOps & CI/CD (In Progress)
- [ ] ArgoCD deployment for GitOps
- [ ] GitHub Actions CI/CD pipelines
- [ ] Automated YAML validation
- [ ] Automated testing workflows
- [ ] Infrastructure as Code with Crossplane
- [ ] Helm chart repository

### 📅 Phase 3: Security & RBAC
- [ ] RBAC policies implementation
- [ ] Network Policies for namespace isolation
- [ ] Pod Security Standards enforcement
- [ ] OPA Gatekeeper for policy management
- [ ] Secrets encryption at rest
- [ ] Automated security scanning

### 🔮 Phase 4: Advanced Features
- [ ] Custom Kubernetes Operator (Go)
- [ ] Multi-cluster setup (staging/prod)
- [ ] Distributed storage (Longhorn)
- [ ] Service mesh (Istio or Linkerd)
- [ ] AI/ML workloads with GPU node
- [ ] Chaos engineering (Chaos Mesh)

---

## 📚 Documentation

- 📖 [Architecture Overview](docs/architecture.md) - Detailed system design
- 🛠️ [Setup Guide](docs/setup-guide.md) - Step-by-step installation
- 🔧 [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
---

## 📊 Cluster Metrics

- **Total CPU Cores:** 12 (6 per node)
- **Total Memory:** 24GB (16GB + 8GB)
- **Storage Capacity:** 100GB+ for media
- **Network Bandwidth:** 51 Mbps upload / 27 Mbps download
- **Concurrent Streams:** 4-6 users at 1080p
- **Uptime:** 99%+ (tracked via Prometheus)
- **Pod Count:** 25+ across 7 namespaces

---

## 🤝 Learning Journey

This homelab is a continuous learning project focused on:

- **Kubernetes Administration** - Cluster operations and troubleshooting
- **Cloud-Native Technologies** - Containers, orchestration, microservices
- **DevOps Practices** - GitOps, CI/CD, automation
- **Infrastructure as Code** - Declarative infrastructure management
- **Monitoring & Observability** - Metrics, logs, distributed tracing
- **Security** - RBAC, network policies, zero trust

**Timeline:**
- **Started:** December 2024
- **Status:** Active Development
- **Goal:** Kubernetes Operator Development role readiness

---

## 💡 Why This Project?

Built to develop real-world skills for **Kubernetes Operator Development** roles:

1. ✅ **Hands-on Kubernetes experience** beyond tutorials
2. ✅ **Production-grade practices** (monitoring, security, GitOps)
3. ✅ **Real applications** with actual functionality
4. ✅ **Problem-solving** through troubleshooting and debugging
5. ✅ **Portfolio showcase** with documented architecture
6. ✅ **Foundation** for learning operator development (Go)

---

## 🚀 Getting Started

Want to build something similar? Check out the [Setup Guide](docs/setup-guide.md).

**Prerequisites:**
- 2+ computers/VMs
- Ubuntu Server 24.04 LTS
- Basic Linux and networking knowledge
- Willingness to learn and debug!

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Anthropic Claude** - AI pair programming assistance
- **K3s** - Lightweight Kubernetes distribution
- **Prometheus Community** - Excellent Helm charts
- **Cloudflare** - Free tunnel service for homelabs

---

<p align="center">
  <strong>Built with ❤️ for learning Kubernetes and cloud-native technologies</strong>
</p>

<p align="center">
  <a href="https://linkedin.com/in/YOUR_LINKEDIN">LinkedIn</a> •
  <a href="https://github.com/ilkkaruso">GitHub</a>
</p>
 
