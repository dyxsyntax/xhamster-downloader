#!/bin/bash
# Put files in folder into an array
filelist=(/media/usb0/*.rar)

# Uploaded share-online part
if [ -s 'share-online.log' ]; then
	count_i=$(grep -o 'http\:\/\/[[:alnum:]]*' 'share-online.log' | wc -l)
	printf '\n' >> share-online.log
else
	count_i=0
fi
for (( i=$count_i; i<${#filelist[@]}; i++ )); do
	# Start upload
	printf '%s \n' "${filelist[i]}" >> share-online.log
	plowup --cache=shared --printf=%u -a 'USERNAME:PASSWORD' shareonline_biz ${filelist[i]} >> share-online.log
	while [ $? -ne 0 ]; do !!; done
	printf '\n' >> share-online.log
done

if [ -s 'share-online.log' ]; then
	> so_finished.log
	while IFS= read -r line; do
		if [[ $line =~ (^\/[[:alnum:]\/]*.part[0]*1.rar) ]]; then
			echo "--------------------------------" >> so_finished.log
			echo $line >> so_finished.log
		elif [[ $line =~ (http\:\/\/www.[[:alnum:]\-]*.biz\/dl\/[[:alnum:]]*) ]]; then
			echo $line >> so_finished.log
		fi
	done < share-online.log
fi

## Comment out Rapidgator Part

: <<'END'

# Uploaded rapidgator part
if [ -s 'rapidgator.log' ]; then
	count_i=$(grep -o 'http\:\/\/[[:alnum:]]*' 'rapidgator.log' | wc -l)
	printf '\n' >> rapidgator.log
else
	count_i=0
fi
for (( i=$count_i; i<${#filelist[@]}; i++ )); do
	# Start upload
	printf '%s \n' "${filelist[i]}" >> rapidgator.log
	plowup --cache=shared --printf=%u -a 'USERNAME:PASSWORD' rapidgator ${filelist[i]} >> rapidgator.log
	while [ $? -ne 0 ]; do !!; done
	printf '\n' >> rapidgator.log
done

if [ -s 'rapidgator.log' ]; then
	> rg_finished.log
	while IFS= read -r line; do
		if [[ $line =~ (http\:\/\/[[:alnum:]\-].*part[0]*1.rar.html) ]]; then
			echo "--------------------------------" >> rg_finished.log
			echo $line >> rg_finished.log
		elif [[ $line =~ (http\:\/\/[[:alnum:]\-].*rar.html) ]]; then
			echo $line >> rg_finished.log
		fi
	done < rapidgator.log
fi

END
