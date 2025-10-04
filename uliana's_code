#!/bin/bash
echo "Введите путь до папки: "
read path_to_log
amount_of_log=$(du -sk "$path_to_log" | awk '{print $1}')
amount_full_way=$(df -k "$path_to_log" | awk 'NR==2 {print $2}')
percent_log=$(echo "scale=2; ($amount_of_log / $amount_full_way) * 100" | bc)
echo "Введите процент занятости: "
read percent_N
if (( $(echo "$percent_log < $percent_N" | bc -l) )); then
  echo "Сколько старых файлов архивировать:"
  read old_files_M
  mkdir -p "$HOME/backup"
  archive="$HOME/backup/archive_$(date +%Y%m%d_%H%M%S).tar.gz"
  tar -czvf "$archive" -C "$path_to_log" $(find "$path_to_log" -type f | sort | head -n "$old_files_M")
fi
