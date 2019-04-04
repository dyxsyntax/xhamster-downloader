#!/bin/bash
while true; do
  num=$(shuf -i 1000000-9999999 -n 1)
  if [[ $(mysql --login-path=local DATABASENAME <<< "SELECT id FROM hamster WHERE id = $num") ]]; then
    echo "Found ID already"
  else
    if [[ $(wget -qO- www.xhamster.com/videos/$num) ]]; then
      json=$(wget -qO- www.xhamster.com/videos/$num)
      regex="window\.initials\ \=\ ([[:print:]]*);"
      while read -r f; do
        if [[ $f =~ $regex ]]; then
          duration=$(echo ${BASH_REMATCH[1]} | jq -r '.videoModel.duration')
          link=$(echo ${BASH_REMATCH[1]} | jq -r '.videoModel.pageURL')
          resolution=$(echo ${BASH_REMATCH[1]} | jq -r '.videoModel.sources.download."720p".link')
          title=$(echo ${BASH_REMATCH[1]} | jq -r '.videoModel.title' | tr -dc '[:alnum:][:blank:]\n\r')
          id=$num
          tags=$(echo ${BASH_REMATCH[1]} | jq '.videoModel.categories[].name')
          tags=$(echo $tags | tr '" "' '","' | tr -dc '[:alnum:][:blank:]\,\n\r')
          ## Download Status explanation
          # State 0: Nothing to see here/ No Link or Download found
          # State 1: Video found with right duration and link
          # State 2: Video found with link <720p Version
          # State 3: Video found with link but without right duration
          # State 4: Video got downloaded
          # State 5: Video got uploaded
          ## End of Status explanation
          if [[ $resolution = "null" ]]; then
            resolution=$(echo ${BASH_REMATCH[1]} | jq -r '.videoModel.sources.download."480p".link')
            if [[ $resolution = "null" ]]; then
              resolution=$(echo ${BASH_REMATCH[1]} | jq -r '.videoModel.sources.download."360p".link')
              if [[ $resolution = "null" ]]; then
                mysql --login-path=local -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','null','null','null','','$duration','0')"
                echo "No link 720p - 360p"
                break
              fi
              mysql --login-path=local -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','null','null','$link','$tags','$duration','2')"
              echo "Link found"
              echo "360p"
              break
            else
              mysql --login-path=local -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','null','$link','null','$tags','$duration','2')"
              echo "Link found"
              echo "480p"
              break
            fi
          else
            echo "Link found"
            if [[ $duration -gt 1200 ]]; then
              mysql --login-path=local -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','$link','null','null','$tags','$duration','3')"
              echo "to long duration"
            elif [[ $duration -gt 600 ]]; then
            mysql --login-path=local -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','$link','null','null','$tags','$duration','1')"
            echo "$id $title"
            directory=$(echo "$id $title")
            mkdir "$id $title"
            cd "$id $title"
            until youtube-dl "www.xhamster.com/videos/$num"; do
              sleep 5
            done
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
            until png=$(curl -H 'Authorization: Client-ID b2ec345b1277f4e' -F "image=@$image_file" https://api.imgur.com/3/image | jq -r '.data.link'); do
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
            cd - > /dev/null
            mysql --login-path=local -D DATABASENAME -e "UPDATE hamster SET downloaded = 5 WHERE id = $id"
            else
              mysql --login-path=local -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','$link','null','null','$tags','$duration','3')"
              echo "to short duration"
            fi
          fi
        fi
      done <<< "$json"
    else
      mysql --login-path=local -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$num','Empty','404','404','404','','0','0')"
      echo "wget - 404"
    fi
  fi
done
