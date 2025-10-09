#!/bin/bash

archive="/home/maria/backup/2.tar.gz" #path to archive
file="/home/maria/backup/1" #path to folder with files
file2="/home/maria/filesNOT" #path to folder with not enough files
file3="/home/maria/filesNOT/drrfrgrgr" #path to successful archivating
file4="/home/maria/backup/4"
backup="/home/maria/backup" #path to backup

#test case 1
echo "Test 1 - can't find file directory or input is not a directory"
echo "================================="
printf "%s\n" "home" "/home/maria/backup123" "$file4" "1" "1" "$backup" | ./lab.sh
echo "================================="
echo -e "Test 1 completed\n"

#test case 2
echo "Test 2,3 - wrong threshold or N"
echo "Test 2 - threshold will be 150, then word, then 5"
echo "Test 3 - N will be 100 (100+5=150>100), then 3"
echo "================================="
printf "%s\n" "$file" "150" "hello" "5" "100" "3" "$backup" | ./lab.sh
echo "================================="
echo -e "Tests 2 and 3 completed\n"

#test case 4
echo "Test 4 - not enough files to archivate to reach maximum usage"
echo "================================="
printf "%s\n" "$file2" "0" "0" "$backup" | ./lab.sh
echo "================================="
echo -e "Test 4 completed\n"

#test case 5
echo "Test 5 - successful archivating"
echo "================================="
printf "%s\n" "$file3" "0.01" "0.01" "$backup" | ./lab.sh
echo "================================="
echo -e "Test 5 completed\n"


