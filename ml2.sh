#!/bin/bash
default_path="/home/mafaka/arcpr/prac/"
default_threshold=14
dir="${1:-$default_path}"
threshold="${2:-$default_threshold}"
if [[ ! -d "$dir" ]]; then
    echo "directory '$dir' doesnt exist"
    exit 1
fi
if ! [[ "$threshold" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "threshold must be positive"
    exit 1
fi
if (( $(echo "$threshold > 100" | bc -l) )); then
    echo "threshold cant be over 100%"
    exit 1
fi
total_size=$(du -s "/home" | cut -f1)
dir_size=$(du -s "$dir" | cut -f1) 
current_usage=$(echo "scale=7; $dir_size * 100 / $total_size" | bc -l)
echo "usage: $(echo "scale=2; $current_usage/1" | bc)%"
if (( $(echo "$current_usage <= $threshold" | bc -l) )); then
    echo "No need for archivating"
    exit 0
fi
mkdir -p "backup"
mapfile -t files < <(find "$dir" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | cut -d' ' -f2-)
if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found to archive."
    exit 0
fi
to_archive=()
archived_size=0
for (( i=0; i<${#files[@]}; i++ )); do
    file="${files[$i]}"
    file_size=$(du -s "$file" | cut -f1)
    to_archive+=("$(basename "$file")")
    archived_size=$((archived_size + file_size))
    new_usage=$(echo "scale=7; ($dir_size - $archived_size) * 100 / $total_size" | bc -l)
    if (( $(echo "$new_usage <= $threshold" | bc -l) )); then
        echo "Target usage reached: $(echo "scale=2; $new_usage/1" | bc)%"
        break
    fi
done

if [[ ${#to_archive[@]} -gt 0 ]]; then
    echo "${#to_archive[@]} files will be archivated"
    tar -zcf "backup/archive.tar.gz" -C "$dir" "${to_archive[@]}"
    for file in "${to_archive[@]}"; do
        rm -f "$dir/$file"
    done
    echo "archive was created successfully"
else
    echo "No files were selected for archivating."
fi
