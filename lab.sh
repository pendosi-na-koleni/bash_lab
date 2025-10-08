#!/bin/bash
path="/home/mafaka/arcpr/prac/"
perc=20
l="${1-:$path}" # добавила $ к пути (было просто path).
n="${2-:$perc}" # здесь тоже +$
#if no input after executing choosing params by default
#start test.sh
if ! bash test.sh "$l" "$n"; then
echo "tests failed."
exit 1
fi
cur_dir=$(du -s "$l" | cut -f1)
home_dir=$(du -s "/home" | cut -f1)
res=$(echo "scale=2; $cur_dir/$home_dir" | bc | cut -d. -f2) # можно добавить проверку, что число <= 1, или работать через bc: res=$(echo "scale=0; $cur_dir*100/$home_dir" | bc) ?
files=($(ls -tr "$l")) # если в именах файлов будут спецсимволы - конструкция может сломаться. mapfile -t files < <(ls -tr -- "$l") ?
to_archivate=()
mkdir -p "backup"
for ((i=0; i<${#files[@]};i++))
{
    if [[ $res -le $n ]]; then
        echo "${#to_archivate[@]} old files will be archivated"
        break
    fi
    size=$(du -s "$l${files[$i]}" | cut -f1)
    cur_dir=$((cur_dir-size))
    res=$(echo "scale=2; $cur_dir/$home_dir" | bc | cut -d. -f2)
    to_archivate+=("${files[$i]}")
}
tar -zcf "backup/archive.tar.gz" -C "$l" "${to_archivate[@]}"
echo "archive.tar.gz in backups was succesfuly created" # опечатка "succesfully" 2 l.
