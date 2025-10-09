#!/bin/bash

echo "Enter the path to your log directory"
while true; do
	read dir
	if [ ! -d "$dir" ]; then
		echo "This directory doesn't exist, try again"
	else
		break
	fi
done

get_usage()
{
	local dir=$1
	local total_size=$(df --output=size "$dir" | tail -n 1)
	local dir_size=$(sudo du -s "$dir" | awk '{print $1}')

	percentage=$(printf "%.2f" "$(echo "scale=10; $dir_size / $total_size * 100" | bc)")
	echo "$percentage"
}
echo "Current usage is $(get_usage "$dir")%"

#check >0
echo "Enter the threshold for the directory usage in percentage"
while true; do
	read threshold
	if ! [[ "$threshold" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
		echo "This is not a number, try again"
	elif ! [ "$(echo "$threshold <= 100.00" | bc -l)" -eq 1 ]; then
		echo "Threshold can't be over 100%, try again"
	else
		break
	fi
done

echo "Enter the percentage by which the size can exceed the threshold"
while true; do
	read N
	if ! [[ "$N" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
		echo "This is not a number, try again"
	else
		max_usage=$(printf "%.2f" "$(echo "scale=10; $threshold + $N" | bc)")
		max_allowed_N=$(printf "%.2f" "$(echo "scale=10; 100 - $threshold + 0.01" | bc)")
		if ! [ "$(echo "$max_usage <= 100.00" | bc -l)" -eq 1 ]; then
			echo "Maximum usage can't be over 100%, try to enter percentage less than $max_allowed_N"
		else
			break
		fi
	fi
done

if [ "$(echo "$(get_usage "$dir") > $max_usage" | bc -l)" = "1" ]; then
	echo "Usage exceeded the threshold too much. Enter the path to backup directory"
	read backup
	archive="$backup/archive.tar.gz"
else
	echo "Usage doesn't exceed the maximum percentage. Exiting..."
	sleep 3
	exit
fi

if [ ! -f "$archive" ]; then
	tar -cf "${backup}/archive.tar" --files-from /dev/null
fi

while true; do
	current_used=$(get_usage "$dir")
	echo -ne "Archiving... Current space usage is $current_used% \r"
	if [ "$(echo "$(get_usage "$dir") <= $max_usage" | bc -l)" = "1" ]; then
		break
	fi

	oldest=$(find "$dir" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | head -1 | cut -d' ' -f2-)

	if [ ! -f "$oldest" ]; then
		echo "No files left to archivate,"
		exit
	else
		basename_oldest=$(basename "$oldest")
		tar -rf "${backup}/archive.tar" -C "$(dirname "$oldest")" "$basename_oldest" > /dev/null 2>&1
		rm "$oldest"
	fi
done
gzip -f "${backup}/archive.tar"
echo
echo "Archiving process ended successfully!"

