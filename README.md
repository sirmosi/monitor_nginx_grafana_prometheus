# Monitoring Project

![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=flat&logo=docker)
![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-orange?style=flat&logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-Dashboard-blue?style=flat&logo=grafana)
![Linux](https://img.shields.io/badge/Linux-Shell_Script-green?style=flat&logo=linux)

This project sets up a robust monitoring system using **Prometheus** and **Grafana** for visualizing and analyzing server and application metrics. Additionally, it includes a custom **SSH-based data collection script** for remote servers. The entire setup is Dockerized for simplicity and portability.

---

## 📜 **Features**
1. **Docker Compose**: Centralized deployment of Grafana, Prometheus, Node Exporter, and cAdvisor using a `docker-compose.yml` file.
2. **Custom Metrics Collection**: A script that collects server metrics via SSH and integrates them into Prometheus using the Node Exporter's textfile collector.
3. **NGINX Reverse Proxy**: Two configurations for secure access:
   - Grafana Dashboard
   - Prometheus Metrics Endpoint
4. **Customizable and Extensible**: Modular design for adding new metrics or extending configurations.

---

## 📂 **Directory Structure**
```plaintext
.
├── docker-compose.yml            # Docker Compose configuration file
├── ssh-metrics-collector.sh      # Custom script for collecting metrics via SSH
├── nginx/
│   ├── grafana.conf              # NGINX config for Grafana
│   ├── prometheus.conf           # NGINX config for Prometheus
└── textfile-collector/           # Directory for Prometheus-compatible metrics files
    ├── metrics_server2.prom
    └── metrics_server4.prom
