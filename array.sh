#!/usr/bin/env bash

declare -a arr=("zero 0" "one 1" "two 2" "three 3")
declare -a ARR=("${arr[@]}")

for v in "${arr[@]}"; do
  echo "$v"
done

echo ""

for v in "${ARR[@]}"; do
  echo "$v"
done
