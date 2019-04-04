#!/bin/bash

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

cd /media/usb0/hamster
ycounter=$(pgrep youtube-dl | wc -l)
hcounter=$(pgrep load_hamster.sh | wc -l)
lcounter=$(mysql -D DATABASENAME -h 0 -s -e "SELECT count(*) FROM hamster WHERE downloaded = 1")

if [ ! -z  $lcounter ]; then
	if [[ $ycounter = 0 ]]; then
		if [[ $hcounter = 0 ]]; then
			./load_hamster.sh &
			printf '%s \n' "$TIMESTAMP Starting hamster"
			exit
		else
			printf '%s \n' "$TIMESTAMP Found load_hamster running"
		fi
	else
		printf '%s \n' "$TIMESTAMP Found youtube-dl running"
		exit
	fi
else
	printf '%s \n' "$TIMESTAMP No Mysql rows"
	exit
fi
