#!/bin/bash
DEFAULT_FOLDER="$HOME/log"   
DEFAULT_THRESHOLD=20       

echo -n "Введите путь к папке (или d для значения по умолчанию): "
read FOLDER
if [[ "$FOLDER" == "d" ]]; then
    FOLDER="$DEFAULT_FOLDER"
fi

while [[ ! -d "$FOLDER" ]]; do
    echo "Папка '$FOLDER' не найдена. Введите корректный путь (или d для $DEFAULT_FOLDER):"
    read FOLDER
    if [[ "$FOLDER" == "d" ]]; then
        FOLDER="$DEFAULT_FOLDER"
    fi
done

disk_size=$(df -B1 "$FOLDER" | awk 'NR==2 {print $2}')
folder_size=$(du -s -B1 "$FOLDER" | cut -f1)
usage=$(bc -l <<< "scale=2; $folder_size * 100 / $disk_size")
echo "Папка занимает ${usage}% пространства."

echo -n "Введите порог использования (%) от 0 до 100: "
read THRESHOLD
while ! [[ "$THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]] || (( $(bc <<< "$THRESHOLD < 0") )) || (( $(bc <<< "$THRESHOLD > 100") )); do
    echo "Некорректное значение порога. Введите число от 0 до 100:"
    read THRESHOLD
done

if (( $(bc <<< "$usage > $THRESHOLD") )); then
    echo "Превышение порога: начнем архивацию старых файлов."
    mapfile -t FILES < <(ls -tr "$FOLDER" | grep -v '/$')
    TOARCHIVE=()
    current_size=$folder_size

    for file in "${FILES[@]}"; do
        [[ ${#TOARCHIVE[@]} -gt 0 ]] && echo "К добавлению: ${file}"
        file_size=$(du -s -B1 "$FOLDER/$file" | cut -f1)
        new_size=$((current_size - file_size))
        new_usage=$(bc -l <<< "scale=2; $new_size * 100 / $disk_size")
        TOARCHIVE+=("$file")
        current_size=$new_size
        if (( $(bc <<< "$new_usage <= $THRESHOLD") )); then
            echo "Достигнут порог: новый процент = ${new_usage}%, порог = ${THRESHOLD}%."
            break
        fi
    done

    if [[ ${#TOARCHIVE[@]} -eq 0 ]]; then
        echo "Ошибка: не найдено файлов для архивации."
        exit 1
    fi

    mkdir -p backup
    tar -czf "backup/archive.tar.gz" -C "$FOLDER" "${TOARCHIVE[@]}"
    echo "Старые файлы успешно заархивированы в backup/archive.tar.gz."
else
    echo "Порог не превышен. Архивация не требуется."
fi
