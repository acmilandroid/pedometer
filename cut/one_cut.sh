#!/bin/bash
# usage: ./one_cut.sh [directory] [cutsteps_executable] [window_size] [window_stride] [gait] [sensor #]
# [directory] is top level dir containing all subject files
# if [gait] is not Regular, Irregular, or SemiRegular, it will combine all gaits
# combines and all csv files of a single sensor type
# creates sensor0[#]_cut.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 6 ]; then
    echo "Usage: ./one_cut.sh [directory] [cutsteps_executable] [window_size] [window_stride] [gait] [sensor #]"
    exit 1
fi

num=0

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        if [[ "$5" != "Regular" && "$5" != "Irregular" && "$5" != "SemiRegular" ]]; then
            ./$2 $3 $4 $d"/Regular/Sensor0"$6".csv" $d"/Regular/steps.txt" >> sensor0$6_cut.txt
            ./$2 $3 $4 $d"/Irregular/Sensor0"$6".csv" $d"/Irregular/steps.txt" >> sensor0$6_cut.txt
            ./$2 $3 $4 $d"/SemiRegular/Sensor0"$6".csv" $d"/SemiRegular/steps.txt" >> sensor0$6_cut.txt
        else
            ./$2 $3 $4 $d"/"$5"/Sensor0"$6".csv" $d"/"$5"/steps.txt" >> sensor0$6_cut.txt
        fi
    fi
done

echo "$((num)) csv files cut for step windows."