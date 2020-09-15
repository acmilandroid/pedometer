#!/bin/bash
# usage: ./one_cut.sh [directory] [cutsteps_executable] [CUT] [STRIDE] [gait] [sensor #]
# [directory] is top level dir containing all subject files
# combines and all csv files of a single sensor type
# creates sensor0[#]_cut.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 6 ]; then
    echo "Usage: ./one_cut.sh [directory] [cutsteps_executable] [CUT] [STRIDE] [gait] [sensor #]"
    exit 1
fi

num=0

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./$2 $3 $4 $d"/"$5"/Sensor0"$6".csv" $d"/"$5"/steps.txt" >> sensor0$6_cut.txt
    fi
done

echo "$((num)) csv files cut for step windows."