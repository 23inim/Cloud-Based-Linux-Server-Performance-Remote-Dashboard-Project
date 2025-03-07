#!/bin/bash
# consumer
PIPENAME="stress-ng-pipe-fifo"
if [[ ! -p ${PIPENAME} ]]
then
	mkfifo ${PIPENAME}
fi

while true
do
	if read line <${PIPENAME}
	then
		eval $"stress-ng $line"
	fi
done

#example input command: printf "%s\n"  "--matrix 1 -t 20s" > stress-ng-pipe-fifo
