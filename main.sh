#!/usr/bin/env bash

input_dir=/home/robin/netshare/aac/eac
output_dir=/home/robin/netshare/aac/delete-me
declare -i threads=4
declare -a thread_buckets

# echo "Batch ffmpeg flac to FDK aac converter"
# echo -e "Enter input directory full path: \c"
# read input_dir
# echo -e "Enter output directory full path: \c"
# read output_dir
# echo -e "Enter thread count: \c"
# echo -e "Enter thread count: \c
# read threads

function replicate_dirs () {
  cd $input_dir
  find . -type d -exec mkdir -p $output_dir/{} \;
}

function copy_other_files () {
  cd $input_dir
  find . -type f ! -iname "*.flac" -exec cp --parents {} $output_dir \;
}

function flac_files_to_array () {
  local -a array
  local -i bucket_idx=0

  cd $input_dir
  readarray -d "" array < <( find . -type f -iname "*.flac" -print0 )

  for elem in "${array[@]}"; do
    echo "($bucket_idx) $elem"

    bucket=${thread_buckets[$bucket_idx]}
    bucket+=("$elem")
    thread_buckets[$bucket_idx]=$bucket

    if (( $bucket_idx < $threads-1 )); then
      (( bucket_idx++ ))
    else bucket_idx=0
    fi
  done

  # select_idx=0
  # bucket=${thread_buckets[$select_idx]}
  # for elem in "${bucket[@]}"; do
  #   echo "($select_idx) $elem"
  # done
}

# replicate_dirs
# copy_other_files
flac_files_to_array
