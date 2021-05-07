#!/usr/bin/env bash

declare -i threads=4
declare -a flac_array

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
      jrottenberg/ffmpeg:alpine \
      -i "./input/$infile" \
      -c:a libfdk_aac -vbr 4 \
      -metadata comment="FFmpeg libfdk_aac VBR4" \
      "./output/$outfile.m4a"
  done
}

echo "Batch ffmpeg flac to FDK aac converter"
echo ""
echo -e "Enter input directory full path: \c"
read input_dir
echo -e "Enter output directory full path: \c"
read output_dir
echo -e "Enter thread count: \c"
echo -e "Enter thread count: \c"
read threads

replicate_dirs
copy_other_files
flac_files_to_array
slice_flac_array
