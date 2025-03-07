#!/bin/bash
# producer
PIPENAME="stress-ng-pipe-fifo"
if [[ ! -p ${PIPENAME} ]]
then
	mkfifo ${PIPENAME}
fi


printf "--matrix 1 -t 20s" > "${PIPENAME}"
