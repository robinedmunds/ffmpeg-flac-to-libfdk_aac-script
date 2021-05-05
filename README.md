# ffmpeg batch audio encoder

## Steps

threads = CPU thread count

1. take input dir, output dir, threads from user
1. replicate dir structure of input to output dir
1. copy all NONE audio files from input to output dirs
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
