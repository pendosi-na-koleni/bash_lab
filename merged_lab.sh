#!/bin/bash
default_path="/home/mafaka/arcpr/prac/"
default_threshold=20
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

#Дополнительно: проверка, что не ноль и не отрицательное.
#if (( $(echo "$threshold <= 0" | bc -l) )); then
#    echo "Threshold must be positive and non-zero."
#    exit 1
#fi

total_size=$(df -B1 "$dir" | awk 'NR==2 {print $2}') # может быть лучше использовать du?
dir_size=$(du -sb "$dir" | awk '{print $1}')
current_usage=$(echo "scale=7; $dir_size * 100 / $total_size" | bc -l) # если будет ошибка с total_size, здесь будет деление на ноль.
#Проверка на деление на ноль (на всякий случай).
#if [[ -z "$total_size" || "$total_size" -eq 0 ]]; then
#    echo "Error: could not determine total disk size."
#    exit 1
#fi

echo "usage: $(printf "%.2f" "$current_usage")%"
if (( $(echo "$current_usage <= $threshold" | bc -l) )); then # лучше заменить на " if [[ $(echo "$threshold > 100" | bc -l) -eq 1 ]]; then ", если вернёт пустую строку.
    echo "No need for archivating"
    exit 0
fi
mkdir -p "backup"
mapfile -t files < <(find "$dir" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | cut -d' ' -f2-)
#Здесь при наличии пробела в пути, строка может отработать некорректно.
#mapfile -d '' -t files < <(find "$dir" -maxdepth 1 -type f -printf '%T@ %p\0' | sort -z -n -k1,1 | cut -z -d' ' -f2-)
if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found to archive."
    exit 0
fi
to_archive=()
archived_size=0
for (( i=0; i<${#files[@]}; i++ )); do
    file="${files[$i]}"
    file_size=$(stat -c%s "$file" 2>/dev/null || du -sb "$file" | awk '{print $1}')
    to_archive+=("$(basename "$file")")
    archived_size=$((archived_size + file_size))
    new_usage=$(echo "scale=7; ($dir_size - $archived_size) * 100 / $total_size" | bc -l)
    if (( $(echo "$new_usage <= $threshold" | bc -l) )); then
        echo "Target usage reached: $(printf "%.2f" "$new_usage")%"
        break
    fi
done
if [[ ${#to_archive[@]} -gt 0 ]]; then
    echo "${#to_archive[@]} files will be archivated"
    tar -zcf "backup/archive.tar.gz" -C "$dir" "${to_archive[@]}" # если tar будет пустой, будет ошибка.
    #if tar -zcf "backup/archive.tar.gz" -C "$dir" "${to_archive[@]}"; then
    #    echo "Archive created successfully"
    # ....
    #else
    #    echo "Error: archiving failed, files were not deleted."
    #fi
    for file in "${to_archive[@]}"; do
        rm -f "$dir/$file"
    done
    echo "archive was created successfully"
else
    echo "No files were selected for archivating."
fi
