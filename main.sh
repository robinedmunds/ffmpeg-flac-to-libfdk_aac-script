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
  declare -a array
  declare -i bucket_idx=0

  cd $input_dir
  readarray -d "" array < <( find . -type f -iname "*.flac" -print0 )

  for idx in ${!array[@]}; do
    # echo ${array[idx]}
    # echo $bucket_idx

    thread_buckets[$bucket_idx]+="${array[$idx]}"

    if (( $bucket_idx < $threads-1 )); then
      (( bucket_idx++ ))
    else bucket_idx=0
    fi
  done

  # zeroeth_bucket=${thread_buckets[0]}
  # # echo ${!zeroeth_bucket[@]}
  # for elem in "${zeroeth_bucket[@]}"; do
  #   echo $elem
  # done
}

# replicate_dirs
# copy_other_files
flac_files_to_array
