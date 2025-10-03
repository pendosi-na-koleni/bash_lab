#!/bin/bash
l="/home/mafaka/arcpr/prac/"
n=20
l="$1"
n="$2"
if ! bash test.sh "$l" "$n"; then
echo "tests failed."
exit 1
fi
cur_dir=$(du -s "$l" | cut -f1)
home_dir=$(du -s "/home" | cut -f1)
res=$(echo "scale=2; $cur_dir/$home_dir" | bc | cut -d. -f2)
counter=0
files=($(ls -tr "$l"))
to_archivate=()
mkdir -p "backup"
for ((i=0; i<${#files[@]};i++))
{
    if [[ $res -le $n ]]; then
        echo "${#to_archivate[@]} files will be archivated"
        break
    fi
    size=$(du -s "$l${files[$i]}" | cut -f1)
    cur_dir=$((cur_dir-size))
    res=$(echo "scale=2; $cur_dir/$home_dir" | bc | cut -d. -f2)
    to_archivate+=("${files[$i]}")
}
tar -zcf "backup/archive.tar.gz" -C "$l" "${to_archivate[@]}"
echo "archive.tar.gz in backups was succesfuly created"
