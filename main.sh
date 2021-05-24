#!/usr/bin/env bash

declare -i threads=4
declare -a flac_array
declare -i quality=4

function replicate_dirs {
  cd $input_dir
  find . -type d -exec mkdir -p $output_dir/{} \;
}

function copy_other_files {
  cd $input_dir
  find . -type f ! -iname "*.flac" -exec cp --parents {} $output_dir \;
}

function process_album_art {
  cd $input_dir
  readarray -d "" art_array < <( \
    find . -type f -regextype egrep -iregex ".*folder\.(jpg|jpeg|png)$" -print0 )

  for full_path in "${art_array[@]}"; do
    dest="$output_dir/${full_path:2:-4}"
    convert -geometry 1000 "$full_path" "$dest.jpg"
  done
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

  for (( idx=0; $idx < $threads; idx++ )); do
    sliced=("${flac_array[@]:$start:$length}")
    if (( $idx == $threads-1 )); then
      sliced=("${flac_array[@]:$start}")
    fi
    start+=$length
    coproc flac_processor sliced
  done
}

function flac_processor {
  # takes thread array
  # loops over files and processes them

  for file in "${sliced[@]}"; do
    infile="${file[0]:2}"
    outfile="${file[0]:2:-5}"

    docker run --rm --volume $input_dir:$(pwd)/input \
      --volume $output_dir:$(pwd)/output --workdir $(pwd) \
      jrottenberg/ffmpeg:4.1-alpine \
      -i "./input/$infile" \
      -c:a libfdk_aac -vbr $quality \
      -metadata comment="jrottenberg/ffmpeg:4.1-alpine libfdk_aac vbr$quality" \
      "./output/$outfile.m4a"
  done
}

echo "Batch ffmpeg flac to FDK aac converter"
echo ""
echo -e -n "Enter input directory full path: "
read input_dir
echo -e -n "Enter output directory full path: "
read output_dir
echo -e -n "Enter thread count: "
read threads
echo -e -n "Enter audio quality (1-5): "
read quality

replicate_dirs
# copy_other_files
process_album_art
flac_files_to_array
slice_flac_array
