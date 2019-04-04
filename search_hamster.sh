#!/bin/bash

array=()

while IFS=  read -r -d $'\0'; do
  array+=("$REPLY")
done < <(find . -type d -print0)

for directory in "${array[@]}"; do
  if [ -d "$directory" ]; then
    cd "$directory"
    count=$(ls -1 *.png 2>/dev/null | wc -l)
    if [[ "$directory" =~ [[:digit:]]{7}\ [0-9a-Z\ \-\!\'\_\(\)]*[[:alnum:]]{4,5}$ ]] && [[ $count = 0 ]]; then
      filename=$(pwgen 15 1)
      mv *.mp4 $filename.mp4
      duration=$(ffmpeg -i *.mp4 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//)
      filesize=$(ls -s --block-size=1048576 *.mp4 | cut -d' ' -f1)
      resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 *.mp4)
      until vcs *.mp4 -n9 -H15% -U0 -c3 -o screencap.png; do
        sleep 5
      done
      until 7z a -t7z -mmt=on -mx=1 -l $filename.7z *.*; do
        sleep 5
      done
      until url=$(plowup --cache=shared --printf=%u -a 'USERNAME:PASSWORD' shareonline_biz *.7z); do
        sleep 5
      done
      image_file=$(ls -d -1 "$PWD"/screencap.png)
      until png=$(curl -H 'Authorization: Client-ID YOURIMGUR-CLIENTID' -F "image=@$image_file" https://api.imgur.com/3/image | jq -r '.data.link'); do
        sleep 5
      done
cat <<EOT >> template.txt
[CENTER]
[SPOILER]
[IMG]$png[/IMG]
[/SPOILER]
[B]Infos:[/B]
Länge: $duration
Auflösung: $resolution
Größe: $filesize MB
Parts: 1


[URL="$url"]Share-Online[/URL]
[/CENTER]
EOT
    fi
    cd - > /dev/null
  fi
done

: '
 COMMENT AREA
'
