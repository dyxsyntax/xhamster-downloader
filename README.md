# xhamster-downloader
Scripts entire made of bash scripts and basic unix tools, to: 

  1. download a random clip in the highest available quality 
  2. dont to duplicates by storing the origin filename inside mysql db 
  3. screencap the whole thing 
  4. upload screencap to imgur
  5. upload the shit to filehoster of your choice 
  6. generate a bb-code encoded basic forum post

## The different Scripts on their own

### link_hamster.sh
  1. Generate random ID between 1000000-9999999
  2. Compare random ID with IDs in MySQL-DB          / back to 1. if ID if exists in DB
  3. Load JSON from xhamster for META-Data
  3.1 If link is invalid (404) store link as invalid in DB
  4. Fetch: duration, link, resolution, title, tags
  4.1 If no 720p link available look for 480p
  4.2 If no 480p link available look for 360p
  4.3 If no 360p link available set ID as invalid
  5. If >720p link available check for duration
  5.1 If duration is >600s store link as valid
  5.2 If duration >1200s or <600 store link as valid but not prio download

### search_hamster.sh
  1. Just crawls already downloaded files in executed folder
  1.1 Folderstructure must be like 'executed folder'/'mp4 file folder'
  2. Randomize filename of every \*.mp4 
  3. Screencap via [**vcs**](http://p.outlyer.net/vcs)
  4. Zip via [**7zip**](https://wiki.ubuntuusers.de/7z/)
  5. Upload \*.mp4 via [**plowup**](https://github.com/mcrapet/plowshare)
  6. Upload screencap to imgur
  7. Generate BB-Code encoded forum post and store it in folder
  
### auto_hamster.sh
  1. Combines link_ and search_hamster.sh by complete link_hamster task and continues at step 2 in search_hamster

### hamster_starter.sh
  1. Check if *youtube-dl* process is running       / quit if so
  2. Check if *load_hamster.sh* process is running  / quit if so
  3. Check if rows in MySQL-DB                      / quit if so
  4. If 1-3 = false start *load_hamster.sh*
