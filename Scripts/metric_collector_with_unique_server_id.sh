#!/bin/bash

# List of remote servers
SERVERS=("server1" "server2" "server4")
USER="root" # SSH user
OUTPUT_DIR="/root/work/monitor_nginx_grafana_prometheus/textfile-collector"

# Function to collect metrics from a remote server
collect_metrics() {
    SERVER=$1
    TIMESTAMP=$(date +%s)

    # Fetch system metrics (example commands for demonstration; adjust as needed)
    CPU=$(ssh "$USER@$SERVER" "top -bn1 | grep 'Cpu(s)' | awk -F',' '{print 100 - \$4}' | awk '{print \$1}'")
    MEM=$(ssh "$USER@$SERVER" "free | awk '/Mem:/ {printf(\"%.2f\", \$3/\$2 * 100.0)}'")
    DISK=$(ssh "$USER@$SERVER" "df -h / | awk 'NR==2 {gsub(\"%\", \"\", \$5); print \$5}'")

    # Fetch LVE metrics as JSON
    LVE_FAULTS=$(ssh "$USER@$SERVER" "lveinfo --period=1d --show-all --json")
    
    # Ensure LVE_FAULTS is not empty
    if [[ -z "$LVE_FAULTS" ]]; then
        echo "Error: LVE_FAULTS data is empty for $SERVER"
        return 1
    fi

    # Extract data using jq
    USERS=$(echo "$LVE_FAULTS" | jq -r '.data[] | .ID // empty')
    aCPU=$(echo "$LVE_FAULTS" | jq -r '.data[] | .aCPU // 0')
    mCPU=$(echo "$LVE_FAULTS" | jq -r '.data[] | .mCPU // 0')
    lCPU=$(echo "$LVE_FAULTS" | jq -r '.data[] | .lCPU // 0')
    aEP=$(echo "$LVE_FAULTS" | jq -r '.data[] | .aEP // 0')
    mEP=$(echo "$LVE_FAULTS" | jq -r '.data[] | .mEP // 0')
    lEP=$(echo "$LVE_FAULTS" | jq -r '.data[] | .lEP // 0')
    aVMem=$(echo "$LVE_FAULTS" | jq -r '.data[] | .aVMem // 0')
    mVMem=$(echo "$LVE_FAULTS" | jq -r '.data[] | .mVMem // 0')
    lVMem=$(echo "$LVE_FAULTS" | jq -r '.data[] | .lVMem // 0')
    VMemF=$(echo "$LVE_FAULTS" | jq -r '.data[] | .VMemF // 0')
    EPf=$(echo "$LVE_FAULTS" | jq -r '.data[] | .EPf // 0')
    aPMem=$(echo "$LVE_FAULTS" | jq -r '.data[] | .aPMem // 0')
    mPMem=$(echo "$LVE_FAULTS" | jq -r '.data[] | .mPMem // 0')

    # Generate metrics
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

        # LVE Metrics
        echo "# HELP cloudlinux_any_faults Total faults of all types per LVE."
        echo "# TYPE cloudlinux_any_faults gauge"

        # Loop through all users
        for i in $(seq 1 $(echo "$USERS" | wc -l)); do
            USER_ID=$(echo "$USERS" | sed -n "${i}p")
            CPU_AVG=$(echo "$aCPU" | sed -n "${i}p")
            CPU_MAX=$(echo "$mCPU" | sed -n "${i}p")
            CPU_LIMIT=$(echo "$lCPU" | sed -n "${i}p")
            EP_AVG=$(echo "$aEP" | sed -n "${i}p")
            EP_MAX=$(echo "$mEP" | sed -n "${i}p")
            EP_LIMIT=$(echo "$lEP" | sed -n "${i}p")
            VMEM_AVG=$(echo "$aVMem" | sed -n "${i}p")
            VMEM_MAX=$(echo "$mVMem" | sed -n "${i}p")
            VMEM_LIMIT=$(echo "$lVMem" | sed -n "${i}p")
            VMEM_FAULTS=$(echo "$VMemF" | sed -n "${i}p")
            EP_FAULTS=$(echo "$EPf" | sed -n "${i}p")
            PMEM_AVG=$(echo "$aPMem" | sed -n "${i}p")
            PMEM_MAX=$(echo "$mPMem" | sed -n "${i}p")

            # Replace null or empty values with 0
            USER_ID=${USER_ID:-"unknown"}
            CPU_AVG=${CPU_AVG:-0}
            CPU_MAX=${CPU_MAX:-0}
            CPU_LIMIT=${CPU_LIMIT:-0}
            EP_AVG=${EP_AVG:-0}
            EP_MAX=${EP_MAX:-0}
            EP_LIMIT=${EP_LIMIT:-0}
            VMEM_AVG=${VMEM_AVG:-0}
            VMEM_MAX=${VMEM_MAX:-0}
            VMEM_LIMIT=${VMEM_LIMIT:-0}
            VMEM_FAULTS=${VMEM_FAULTS:-0}
            EP_FAULTS=${EP_FAULTS:-0}
            PMEM_AVG=${PMEM_AVG:-0}
            PMEM_MAX=${PMEM_MAX:-0}

            # Output metrics for the user
            if [[ "$USER_ID" != "unknown" ]]; then
                echo "cloudlinux_any_faults{host=\"$SERVER\",user=\"$USER_ID\"} $VMEM_FAULTS"
                echo "cloudlinux_cpu_avg{host=\"$SERVER\",user=\"$USER_ID\"} $CPU_AVG"
                echo "cloudlinux_cpu_max{host=\"$SERVER\",user=\"$USER_ID\"} $CPU_MAX"
                echo "cloudlinux_cpu_limit{host=\"$SERVER\",user=\"$USER_ID\"} $CPU_LIMIT"
                echo "cloudlinux_ep_avg{host=\"$SERVER\",user=\"$USER_ID\"} $EP_AVG"
                echo "cloudlinux_ep_max{host=\"$SERVER\",user=\"$USER_ID\"} $EP_MAX"
                echo "cloudlinux_ep_limit{host=\"$SERVER\",user=\"$USER_ID\"} $EP_LIMIT"
                echo "cloudlinux_vmem_avg{host=\"$SERVER\",user=\"$USER_ID\"} $VMEM_AVG"
                echo "cloudlinux_vmem_max{host=\"$SERVER\",user=\"$USER_ID\"} $VMEM_MAX"
                echo "cloudlinux_vmem_limit{host=\"$SERVER\",user=\"$USER_ID\"} $VMEM_LIMIT"
                echo "cloudlinux_ep_faults{host=\"$SERVER\",user=\"$USER_ID\"} $EP_FAULTS"
                echo "cloudlinux_pmem_avg{host=\"$SERVER\",user=\"$USER_ID\"} $PMEM_AVG"
                echo "cloudlinux_pmem_max{host=\"$SERVER\",user=\"$USER_ID\"} $PMEM_MAX"
            fi
        done
    } > "$OUTPUT_DIR/metrics_$SERVER.prom"
}

for SERVER_NAME in "${!SERVERS[@]}"; do
    collect_metrics "$SERVER_NAME" "${SERVERS[$SERVER_NAME]}"
done
