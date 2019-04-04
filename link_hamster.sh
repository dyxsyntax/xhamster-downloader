#!/bin/bash

while true; do
  num=$(shuf -i 1000000-9999999 -n 1)
  if [[ $(mysql -D DATABASENAME -e "SELECT id FROM hamster WHERE id = $num") ]]; then
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
                mysql -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','null','null','null','','$duration','0')"
                echo "No link 720p - 360p"
                break
              fi
              mysql -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','null','null','$link','$tags','$duration','2')"
              echo "Link found"
              echo "360p"
              break
            else
              mysql -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','null','$link','null','$tags','$duration','2')"
              echo "Link found"
              echo "480p"
              break
            fi
          else
            echo "Link found"
            if [[ $duration -gt 600 ]]; then
              mysql -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','$link','null','null','$tags','$duration','1')"
              echo "with right duration"
            elif [[ $duration -gt 1200 ]]; then
              mysql -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','$link','null','null','$tags','$duration','3')"
              echo "to long duration"
            else
              mysql -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$id','$title','$link','null','null','$tags','$duration','3')"
              echo "to short duration"
            fi
          fi
        fi
      done <<< "$json"
    else
      mysql -D DATABASENAME -e "INSERT INTO hamster(id,name,link,link480,link360,tags,duration,downloaded) VALUES ('$num','Empty','404','404','404','','0','0')"
      echo "wget - 404"
    fi
  fi
done
