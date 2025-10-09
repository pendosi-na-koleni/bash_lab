#!/bin/bash

DEFAULT="/home/vboxuser/Desktop/log"
echo "input path to folder (no symlinks!) (type d for default):"
read FOLDER
echo "-> $FOLDER"
while [[ ! -d "$FOLDER" ]]; do
	if [[ "$FOLDER" == "d" ]]; then
		FOLDER=$DEFAULT
		break
	fi
	echo "folder not found. input another path (type d for default)"
	read FOLDER
	echo "-> $FOLDER"
done
SIZE=$(df -B1 $FOLDER | awk '{print $2}' | tail -n1)
#SIZE=$("$SIZE" | awk '{print $2}')
#SIZE=$($SIZE | cut -d ' ' -f 2-)
SIZEF=$(du -sb $FOLDER | awk '{print $1}')
#df -hk /home/vboxuser/Desktop/log
#du -h /home/vboxuser/Desktop/log
#echo "codehere code here code here ahhhhh"
#echo $SIZE
#echo $SIZEF
PERCENTAGE=$(bc -l <<< "scale=7; $SIZEF * 100/ $SIZE")
echo "the folder takes up $PERCENTAGE% of space"
echo "enter the threshold:"
read N
echo "-> $N"
while ! [[ $N =~ ^[0-9]+([.][0-9]+)?$ ]]; do
	echo "$N is not a positive number. input a positive number please."
	read N
	echo "-> $N"
done
mapfile -t FILES < <(ls -tr "$FOLDER")
TOARCHIVE=()
mkdir -p "backup"
if ((  $(echo "$PERCENTAGE > $N" | bc -l) )); then
	echo "Archiving files"
	ARCHIVED=0
	for (( i=0; i<${#FILES[@]}; i++ )); do
		TOARCHIVE+=("$FOLDER/${FILES[$i]}")
		NEWSIZE=$(stat -c%s "$FOLDER/${FILES[$i]}")
		ARCHIVED=$((ARCHIVED + NEWSIZE)) #i think there should be $
		NEWPERCENT=$(bc <<< "scale=15; ($SIZEF - $ARCHIVED) * 100/$SIZE")
		echo "files in toarchive at step $i: ${TOARCHIVE[@]}"
		if (( $(echo "$NEWPERCENT <= $N" | bc -l) )); then
			echo "$NEWPERCENT is within the threshold ($N)"
			break
		fi
	done
	if [ ${#TOARCHIVE[@]} -eq 0 ]; then
		echo "something went wrong. there are no files in the array"
		exit 1
	fi
	tar -zcf "backup/archive.tar.gz" -C "$FOLDER" "${TOARCHIVE[@]}"
	echo "files archived successfully!"
	#tar -tzf backup/archive.tar.gz
fi
echo "end of script"
