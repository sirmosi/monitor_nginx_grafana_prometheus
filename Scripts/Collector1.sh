#!/bin/bash

# List of remote servers
SERVERS=("server2" "server4")
USER="root" # SSH user
OUTPUT_DIR="/root/work/monitor_nginx_grafana_prometheus/textfile-collector"

# Function to collect metrics from a remote server
collect_metrics() {
    SERVER=$1
    TIMESTAMP=$(date +%s)

    # CPU Usage (percentage)
    CPU=$(ssh "$USER@$SERVER" "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - \$8}'")
    
    # Memory Usage (percentage)
    MEM=$(ssh "$USER@$SERVER" "free | grep Mem | awk '{print \$3/\$2 * 100.0}'")
    
    # Disk Usage (percentage) for root
    DISK=$(ssh "$USER@$SERVER" "df / | tail -1 | awk '{print \$5}' | tr -d '%'")

    # CloudLinux LVE Metrics
    LVE_JSON=$(ssh "$USER@$SERVER" "lveinfo --by-fault any_faults --period=1d --show-all --json")

    # Parse LVE Metrics
    LVE_DATA=$(echo "$LVE_JSON" | jq -r '.data[]')

    # Save metrics to a Prometheus-compatible file
    {
        echo "# HELP cpu_usage_percent CPU usage percentage."
        echo "# TYPE cpu_usage_percent gauge"
        echo "cpu_usage_percent{host=\"$SERVER\"} $CPU"
        echo "# HELP memory_usage_percent Memory usage percentage."
        echo "# TYPE memory_usage_percent gauge"
        echo "memory_usage_percent{host=\"$SERVER\"} $MEM"
        echo "# HELP disk_usage_percent Disk usage percentage for root."
        echo "# TYPE disk_usage_percent gauge"
        echo "disk_usage_percent{host=\"$SERVER\"} $DISK"
        echo "# HELP cloudlinux_lve_metrics CloudLinux LVE metrics per user."
        echo "# TYPE cloudlinux_lve_metrics gauge"

        # Loop through each user in LVE data
        echo "$LVE_DATA" | jq -c '.' | while read -r USER_DATA; do
            USER_ID=$(echo "$USER_DATA" | jq -r '.ID')
            CPU_USAGE=$(echo "$USER_DATA" | jq -r '.aCPU')
            MEM_USAGE=$(echo "$USER_DATA" | jq -r '.aPMem')
            VMEM_FAULTS=$(echo "$USER_DATA" | jq -r '.VMemF')
            PMEM_FAULTS=$(echo "$USER_DATA" | jq -r '.PMemF')

            echo "cloudlinux_lve_cpu_usage{host=\"$SERVER\",user=\"$USER_ID\"} $CPU_USAGE"
            echo "cloudlinux_lve_memory_usage{host=\"$SERVER\",user=\"$USER_ID\"} $MEM_USAGE"
            echo "cloudlinux_lve_vmem_faults{host=\"$SERVER\",user=\"$USER_ID\"} $VMEM_FAULTS"
            echo "cloudlinux_lve_pmem_faults{host=\"$SERVER\",user=\"$USER_ID\"} $PMEM_FAULTS"
        done
    } > "$OUTPUT_DIR/metrics_$SERVER.prom"
}

# Loop through servers and collect metrics
for SERVER in "${SERVERS[@]}"; do
    collect_metrics "$SERVER"
done
