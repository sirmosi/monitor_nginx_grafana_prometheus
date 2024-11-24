#!/bin/bash

# List of remote servers
SERVERS=("server2" "server4")
USER="root" # SSH user
OUTPUT_DIR="./textfile-collector"

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

    # CloudLinux LVE Metrics (Any Faults)
    LVE_FAULTS=$(ssh "$USER@$SERVER" "lveinfo --by-fault any_faults --period=1d --show-all --json")

    # Parse LVE Metrics (User IDs and Faults)
    USERS=$(echo "$LVE_FAULTS" | jq -r '.[] | .id') # User IDs
    FAULTS=$(echo "$LVE_FAULTS" | jq -r '.[] | .anyF') # Any faults per LVE

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
        echo "# HELP cloudlinux_any_faults Total faults of all types per LVE."
        echo "# TYPE cloudlinux_any_faults gauge"

        for i in $(seq 0 $(echo "$USERS" | wc -l)); do
            USER_ID=$(echo "$USERS" | sed -n "$((i+1))p")
            USER_FAULTS=$(echo "$FAULTS" | sed -n "$((i+1))p")
            if [[ -n "$USER_ID" && -n "$USER_FAULTS" ]]; then
                echo "cloudlinux_any_faults{host=\"$SERVER\",user=\"$USER_ID\"} $USER_FAULTS"
            fi
        done
    } > "$OUTPUT_DIR/metrics_$SERVER.prom"
}

# Loop through servers and collect metrics
for SERVER in "${SERVERS[@]}"; do
    collect_metrics "$SERVER"
done
