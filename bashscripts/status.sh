#!/bin/bash

PIPEOUT="status_pipe_out.fifo"

# Ensure the FIFO exists
if [[ ! -p "$PIPEOUT" ]]; then
    mkfifo "$PIPEOUT"
fi

netInterface='wlp4s0'
drive='nvme0'

previous_bytes_rx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $2}')
previous_bytes_tx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $10}')

# Read messages line by line from the FIFO
while true; do
    freeOutput=$(eval "free")
    totalMem=$(echo "$freeOutput" | awk 'NR==2{print $2}')
    usedMem=$(echo "$freeOutput" | awk 'NR==2{print $3}')
    freeMem=$(echo "$freeOutput" | awk 'NR==2{print $4}')
    totalSwap=$(echo "$freeOutput" | awk 'NR==2{print $2}')
    usedSwap=$(echo "$freeOutput" | awk 'NR==2{print $3}')
    freeSwap=$(echo "$freeOutput" | awk 'NR==2{print $4}')

    cpuUsage=$(top -bn1 | awk 'NR==3{print $8}')

    #dis name system specific
    diskUsage=$(iostat | grep drive | awk '{print $3 $4}')

    current_bytes_rx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $2}')
    current_bytes_tx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $10}')

    rx_diff=$((current_bytes_rx - previous_bytes_rx))
    tx_diff=$((current_bytes_tx - previous_bytes_tx))

    previous_bytes_rx=$current_bytes_rx
    previous_bytes_tx=$current_bytes_tx

    combined="$totalMem $usedMem $freeMem $totalSwap $usedSwap $freeSwap $cpuUsage $diskUsage $rx_diff $tx_diff"
    #echo $combined

    echo $combined > "$PIPEOUT"
    sleep 1
done
