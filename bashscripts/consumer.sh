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
		printf "$line"
	fi
done
