#!/bin/bash

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ -z $(pgrep uploader.sh) ]; then
	if [ -z $(pgrep curl) ]; then
		printf '%s \n' "$TIMESTAMP Starting uploader.sh"
		/home/pi/uploader.sh &
		exit
	else
		COUNTER=0
		while [ $COUNTER -le 10 ]; do
			sleep 5
			if [ -z $(pgrep curl) ]; then
				printf '%s \n' "$TIMESTAMP Starting uploader.sh"
				/home/pi/uploader.sh &
				exit
			else
				((COUNTER++))
			fi
		done
		printf '%s \n' "$TIMESTAMP Curl process is running"
		printf '%s \n' $(pgrep curl)
	fi
else
	sytime=$(date +%s)
	sotime=$(date +%s -r share-online.log)
	if [[ ! -f rapidgator.log ]]; then
		if [[ $(( $sytime - $sotime )) -gt "540" ]]; then
			kill $(pgrep uploader.sh)
			printf '%s \n' "$TIMESTAMP killed uploader.sh"
			exit
		else
			printf '%s \n' "$TIMESTAMP uploader.sh already running"
			printf '%s \n' $(pgrep uploader.sh)
			exit
		fi
	else
		rgtime=$(date +%s -r rapidgator.log)
		if [[ $(( $sytime - $rgtime )) -gt "540" ]]; then
			if [[ $(( $sytime - $sotime )) -gt "540" ]]; then
				kill $(pgrep uploader.sh)
				printf '%s \n' "$TIMESTAMP killed uploader.sh"
				exit
			fi
		else
			printf '%s \n' "$TIMESTAMP uploader.sh already running"
			printf '%s \n' $(pgrep uploader.sh)
			exit
		fi
	fi
fi 
