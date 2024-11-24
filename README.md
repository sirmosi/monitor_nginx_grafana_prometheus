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
```

## 🚀 **Getting Started**
Prerequisites

    Docker and Docker Compose installed.
    SSH access to the servers you want to monitor.
    NGINX installed for reverse proxy.

Deployment

    Clone the repository:
```
git clone <repository-url>
cd <repository-directory>
```
Start the monitoring stack:

```
docker-compose up -d
```
Verify services:

    Grafana: http://grafana.example.com
    Prometheus: http://prometheus.example.com

## 📊 **Grafana Dashboards**
Adding Prometheus Data Source

    Open Grafana: http://grafana.example.com
    Add Prometheus as a data source:
        URL: http://prometheus:9090

Import Dashboards

    Go to Dashboards → Import.
    Upload the JSON files from grafana/provisioning/dashboards/.

## 🔧 **NGINX Configuration**
Grafana Configuration (nginx/grafana.conf)
```
server {
    listen 80;
    server_name grafana.example.com;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
Prometheus Configuration (nginx/prometheus.conf)
```
server {
    listen 80;
    server_name prometheus.example.com;
    location / {
        proxy_pass http://localhost:9090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 📂 **Custom Metrics Collection**
SSH Script (Scripts/Collector.sh)

This script collects metrics from remote servers via SSH and saves them in Prometheus-compatible .prom files.
Usage

    Edit the SERVERS variable in the script to include your servers.
    Schedule the script to run periodically via cron:
```
    crontab -e
    * * * * * /path/to/Scripts/Collector.sh
```
Example Script
```
#!/bin/bash
SERVERS=("server2" "server4")
USER="ssh-user"
OUTPUT_DIR="./textfile-collector"

collect_metrics() {
    SERVER=$1
    CPU=$(ssh "$USER@$SERVER" "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - \$8}'")
    cat <<EOF > "$OUTPUT_DIR/metrics_$SERVER.prom"
# HELP cpu_usage_percent CPU usage percentage.
# TYPE cpu_usage_percent gauge
cpu_usage_percent{host="$SERVER"} $CPU
EOF
}

for SERVER in "${SERVERS[@]}"; do
    collect_metrics "$SERVER"
done
```
## 💡 **How You Can Help**

We welcome suggestions, improvements, and contributions to make this project even better! Here are some ideas:

    Enhance the SSH script to collect more metrics (e.g., memory, disk, network usage).
    Optimize NGINX configurations for better performance and security.
    Create additional Grafana dashboards for specific use cases.

## 📞 Contact Information

If you have any questions, suggestions, or want to collaborate, feel free to reach out:

 ##   📧 Email: mo.sharbaf@gmail.com
 ##   📱 Phone: +989153033209
 ##   🔗 LinkedIn: Mostafa Sharbaf Golkhatmi
