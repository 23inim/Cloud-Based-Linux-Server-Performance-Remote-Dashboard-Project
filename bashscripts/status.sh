#!/bin/bash

PIPEOUT="status_pipe_out.fifo"

# Ensure the FIFO exists
if [[ ! -p "$PIPEOUT" ]]; then
    mkfifo "$PIPEOUT"
fi

netInterface='wlp5s0'
drive='nvme1n1'

diskUsage=$(iostat | grep $drive)

previousDiskR=$(echo $diskUsage | awk '{print $6}')
previousDiskW=$(echo $diskUsage | awk '{print $7}')


previous_bytes_rx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $2}')
previous_bytes_tx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $10}')

# Read messages line by line from the FIFO
while true; do
    freeOutput=$(eval "free")
    totalMem=$(echo "$freeOutput" | awk 'NR==2{print $2}')
    usedMem=$(echo "$freeOutput" | awk 'NR==2{print $3}')
    freeMem=$(echo "$freeOutput" | awk 'NR==2{print $4}')
    totalSwap=$(echo "$freeOutput" | awk 'NR==3{print $2}')
    usedSwap=$(echo "$freeOutput" | awk 'NR==3{print $3}')
    freeSwap=$(echo "$freeOutput" | awk 'NR==3{print $4}')

    cpuUsage=$(top -bn1 | awk 'NR==3{print $8}')

    diskUsage=$(iostat -k | grep $drive)

    newDiskR=$(echo $diskUsage | awk '{print $6}')
    newDiskW=$(echo $diskUsage | awk '{print $7}')

    currentDiskR=$((newDiskR - previousDiskR))
    currentDiskW=$((newDiskW - previousDiskW))

    previousDiskR=$newDiskR
    previousDiskW=$newDiskW

    #dis name system specific
    #diskUsage=$(iostat | grep $drive | awk '{print $3, $4}')

    echo $currentDiskR
    echo $currentDiskW

    current_bytes_rx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $2}')
    current_bytes_tx=$(cat '/proc/net/dev' | grep $netInterface | awk '{print $10}')

    rx_diff=$((current_bytes_rx - previous_bytes_rx))
    tx_diff=$((current_bytes_tx - previous_bytes_tx))

    previous_bytes_rx=$current_bytes_rx
    previous_bytes_tx=$current_bytes_tx

    combined="$totalMem $usedMem $freeMem $totalSwap $usedSwap $freeSwap $cpuUsage $currentDiskR $currentDiskW $rx_diff $tx_diff"
    echo $combined

    echo $combined > "$PIPEOUT"
    sleep 1
done
