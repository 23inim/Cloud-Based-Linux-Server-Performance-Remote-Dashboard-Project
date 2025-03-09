#!/bin/bash

PIPEIN="sng_pipe_in.fifo"
PIPEOUT="sng_pipe_out.fifo"

# Ensure the FIFO exists
if [[ ! -p "$PIPEIN" ]]; then
    mkfifo "$PIPEIN"
fi

# Ensure the FIFO exists
if [[ ! -p "$PIPEOUT" ]]; then
    mkfifo "$PIPEOUT"
fi

# Read messages line by line from the FIFO
echo "Consumer is waiting for messages..."
while true; do
    read line < "$PIPEIN"
        echo $(eval "stress-ng $line") > "$PIPEOUT"
done
