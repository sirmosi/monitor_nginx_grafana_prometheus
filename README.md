# Monitoring Project

![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=flat&logo=docker)
![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-orange?style=flat&logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-Dashboard-blue?style=flat&logo=grafana)
![Linux](https://img.shields.io/badge/Linux-Shell_Script-green?style=flat&logo=linux)

This project sets up a monitoring system using **Prometheus**, **Grafana**, and **Node Exporter** for visualizing server and application metrics. Additionally, custom SSH scripts are included to collect metrics from remote servers and feed them into Prometheus.

---

## 📜 **Features**
1. **Docker Compose**: Deploy Prometheus, Grafana, and Node Exporter with a single command.
2. **Custom Metrics Collection**: Scripts to collect metrics from remote servers using SSH.
3. **NGINX Reverse Proxy**: Configurations for secure access to Grafana and Prometheus.
4. **Textfile Collector**: Prometheus-compatible `.prom` files for custom metrics.

---

## 📂 **Directory Structure**
```plaintext
├── docker-compose.yml           # Docker Compose configuration file
├── grafana/                     # Grafana configuration directory
│   ├── dashboards/              # Imported Grafana dashboards
│   ├── data/                    # Grafana data (persistent volume)
│   └── provisioning/            # Grafana provisioning directory
│       ├── dashboards/          # Dashboard provisioning configs
│       │   ├── dashboard-1.json # Example dashboard JSON
│       │   └── dashboard.yml    # Dashboard configuration
│       └── datasources/         # Datasource configuration
│           └── prometheus.yml   # Prometheus as a data source
├── nginx/                       # NGINX configuration directory
│   ├── grafana.conf             # NGINX config for Grafana
│   └── prometheus.conf          # NGINX config for Prometheus
├── prometheus/                  # Prometheus configuration directory
│   ├── data/                    # Prometheus data (persistent volume)
│   └── prometheus.yml           # Prometheus scrape configurations
├── README.md                    # Project documentation
├── Scripts/                     # Custom scripts for metric collection
│   ├── Collector1.sh            # Generic metric collector
│   ├── Collector.sh             # Generic metric collector
│   └── NodeExporter.sh          # Generic metric collector
└── textfile-collector/          # Directory for Prometheus-compatible metrics

