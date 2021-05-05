#!/usr/bin/env bash

declare -i threads=16
declare -a flac_array
declare -a buckets

input_dir=/home/robin/netshare/aac/eac
output_dir=/home/robin/netshare/aac/delete-me

# echo "Batch ffmpeg flac to FDK aac converter"
# echo -e "Enter input directory full path: \c"
# read input_dir
# echo -e "Enter output directory full path: \c"
# read output_dir
# echo -e "Enter thread count: \c"
# echo -e "Enter thread count: \c
# read threads

function flac_processor {
  # takes thread array
  # loops over files and processes them

  infile="${sliced[0]:2}"
  outfile="${sliced[0]:2:-5}"

  docker run --rm --volume $input_dir:$(pwd)/input \
    --volume $output_dir:$(pwd)/output --workdir $(pwd) \
    jrottenberg/ffmpeg:alpine \
    -i "./input/$infile" \
    -c:a libfdk_aac -vbr 4 \
    -metadata comment="FFmpeg libfdk_aac VBR4" \
    "./output/$outfile.m4a"


  # for file in "${sliced[@]}"; do
  #   echo "$file"
  # done

  # echo ""
  # echo "- files for thread ${#sliced[@]}"
  # echo ""
}

function replicate_dirs {
  cd $input_dir
  find . -type d -exec mkdir -p $output_dir/{} \;
}

function copy_other_files {
  cd $input_dir
  find . -type f ! -iname "*.flac" -exec cp --parents {} $output_dir \;
}

function flac_files_to_array {
  cd $input_dir
  readarray -d "" flac_array < <( find . -type f -iname "*.flac" -print0 )
}

function slice_flac_array {
  local -i flac_count=${#flac_array[@]}
  local -i division=$(( $flac_count / $threads ))
  local -i start=0
  local -i length=$division
  local -a sliced

  echo "flac_count: $flac_count"

  for (( idx=0; $idx < $threads-1; idx++ )); do
    sliced=("${flac_array[@]:$start:$length}")
    flac_processor sliced
    start+=$length
  done

  sliced=("${flac_array[@]:$start}")
  flac_processor sliced
}

replicate_dirs
copy_other_files
flac_files_to_array
slice_flac_array
