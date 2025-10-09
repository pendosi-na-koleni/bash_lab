#!/bin/bash

echo "----------------------------------------------------------------------"
echo "test one"
printf "d\n20\n" | ./project.sh

echo "----------------------------------------------------------------------"
echo "test two"
printf "d\n0.0005\n" | ./project.sh

echo "----------------------------------------------------------------------"
echo "test three"
printf "d\nfive\n5\n" | ./project.sh

echo "----------------------------------------------------------------------"
echo "test four"
printf "d\n-7\n7\n" | ./project.sh

echo "----------------------------------------------------------------------"
echo "test five"
printf "/not a real path\n/home/vboxuser/Desktop/notes\n5\n" | ./project.sh

echo "----------------------------------------------------------------------"
echo "test six"
printf "fake fake hahahha!\nd\n0.0005\n" | ./project.sh
