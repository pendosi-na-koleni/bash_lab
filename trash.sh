#!/bin/bash
#removing prev files in prac/ n making 100 files new$i.txt with random sizes
rm prac/*
path="/home/mafaka/arcpr/prac/"
l="${1:-$path}"
for ((i = 0; i < 100; i++))
{
var=$((RANDOM % 27000))
res=$(head -n $var data.txt)
echo $res > "/home/mafaka/arcpr/prac/new$i.txt"
}
l="/home/mafaka/arcpr/prac/"
cur_dir=$(du -s "$l" | cut -f1)
home_dir=$(du -s "/home" | cut -f1)
res=$(echo "scale=2; $cur_dir/$home_dir" | bc | cut -d. -f2)
#getting percent
echo result: $res


