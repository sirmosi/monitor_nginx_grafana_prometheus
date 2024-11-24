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

    # CloudLinux LVE Metrics
    # Get all active LVE user metrics (CPU, memory, faults)
    LVE_METRICS=$(ssh "$USER@$SERVER" "lveinfo --by-fault any_faults --period=1d --show-all --json")

    # Parse LVE Metrics
    USERS=$(echo "$LVE_METRICS" | jq -r '.[] | .id') # User IDs
    CPU_LVE=$(echo "$LVE_METRICS" | jq -r '.[] | .acpu') # CPU usage per LVE
    MEM_LVE=$(echo "$LVE_METRICS" | jq -r '.[] | .aPmem') # Memory usage per LVE
    FAULTS=$(echo "$LVE_METRICS" | jq -r '.[] | .faults') # Faults per LVE

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

        # CloudLinux LVE metrics
        echo "# HELP cloudlinux_cpu_usage_per_user CPU usage percentage per LVE."
        echo "# TYPE cloudlinux_cpu_usage_per_user gauge"
        echo "# HELP cloudlinux_memory_usage_per_user Memory usage percentage per LVE."
        echo "# TYPE cloudlinux_memory_usage_per_user gauge"
        echo "# HELP cloudlinux_faults_per_user Faults per LVE."
        echo "# TYPE cloudlinux_faults_per_user gauge"

        for i in $(seq 0 $((${#USERS[@]} - 1))); do
            USER_ID=$(echo "$USERS" | sed -n "$((i+1))p")
            USER_CPU=$(echo "$CPU_LVE" | sed -n "$((i+1))p")
            USER_MEM=$(echo "$MEM_LVE" | sed -n "$((i+1))p")
            USER_FAULTS=$(echo "$FAULTS" | sed -n "$((i+1))p")

            echo "cloudlinux_cpu_usage_per_user{host=\"$SERVER\",user=\"$USER_ID\"} $USER_CPU"
            echo "cloudlinux_memory_usage_per_user{host=\"$SERVER\",user=\"$USER_ID\"} $USER_MEM"
            echo "cloudlinux_faults_per_user{host=\"$SERVER\",user=\"$USER_ID\"} $USER_FAULTS"
        done
    } > "$OUTPUT_DIR/metrics_$SERVER.prom"
}

# Loop through servers and collect metrics
for SERVER in "${SERVERS[@]}"; do
    collect_metrics "$SERVER"
done
