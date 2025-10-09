#!/bin/bash
# tests for ml2.sh script

dir="/home/mafaka/arcpr/prac"
dir_not_exist="/home/mafaka/not_exist"
dir_empty="/home/mafaka/empty"
backup="/home/mafaka/arcpr/prac/backup"

mkdir -p "$dir"
mkdir -p "$dir_empty"
mkdir -p "$backup"
touch "$dir/file1.txt" "$dir/file2.txt" # +created 2 new files


echo "test 1: directory does not exist."
./ml2.sh "$dir_not_exist" 10
echo -e "Test 1 completed\n"

echo "================================="

echo "test 2: threshold is not numeric."
./ml2.sh "$dir" "opps I did it again"
echo -e "Test 2 completed\n"

echo "================================="

echo "test 3: threshold is not in range (0,100)."
./ml2.sh "$dir" 101
echo -e "Test 3 completed\n"

echo "================================="

echo "test 4: directory is empty."
./ml2.sh "$dir_empty" 10
echo -e "Test 4 completed\n"

echo "================================="

echo "test 5: everything is fine."
./trash.sh
./ml2.sh "$dir" 8
echo -e "Test 5 completed\n"

rm -rf "$dir_empty" "$backup"
rm -f "$dir/file1.txt" "$dir/file2.txt"

