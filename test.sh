#!/bin/bash
#add test if amount of params >2
echo "starting tests"
path="$1"
if ! [[ -d "$path" ]]; then
echo "dir $path doesnt exist"
exit 1
fi
n="$2"
if ! [[ "$n" =~ ^[0-9]+$ ]]; then
echo "Error: percent must be integer"
exit 1
fi
if [[ "$n" -lt 1 || "$n" -gt 100 ]]; then
echo "Error: percent must be >=1 and <= 100"
exit 1
fi
echo "all tests passed"
