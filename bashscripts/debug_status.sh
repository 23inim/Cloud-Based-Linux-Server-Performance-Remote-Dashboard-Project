#!/bin/bash

PIPEIN="status_pipe_out.fifo"

# Ensure the FIFO exists
if [[ ! -p "$PIPEOUT" ]]; then
    mkfifo "$PIPEOUT"
fi

# Read messages line by line from the FIFO
echo "Consumer is waiting for messages..."
while true; do
    read line < "$PIPEIN"
    echo $"$line"
done
