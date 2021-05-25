# ffmpeg batch audio encoder

## What the script does

1. replicates input directory structure to output location
1. finds album art, converts to 1000px jpeg
1. finds all .flac files, converts them to aac m4a using **ephemeral ffmpeg docker containers**
1. script attempts to **utilise all cpu cores using coprocess**

## Dependencies

1. docker (to make use of ffmpeg with libfdk_aac pre-compiled)
1. ImageMagick (cover art compression)

## Usage

1. organise your flac music into desired directory structure as this will be replicated
1. name album art folder.png or folder.jpg and place in respective directories
1. run script and follow prompts

---

## Development

1. take input dir, output dir, cpu threads from user
1. replicate dir structure of input to output dir
1. ~~copy all NONE audio files from input to output dirs~~
1. find all .flac files and add them to array with full paths
1. divide .flac array by threads
1. spawn n subprocess loops which invoke processing of each .flac in parallel

## Issues

1. Can't use --detach on `docker run` cmd as loops runs to end spawning too many containers
1. Can't make nice output because docker containers must be attached due to above

## Links

https://www.gnu.org/software/bash/manual/bash.html#Looping-Constructs

https://www.cyberciti.biz/faq/find-command-exclude-ignore-files/

https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash/54561526#54561526

https://copyconstruct.medium.com/bash-coprocess-2092a93ad912

https://trac.ffmpeg.org/wiki/Encode/AAC

https://imagemagick.org/script/command-line-processing.php
