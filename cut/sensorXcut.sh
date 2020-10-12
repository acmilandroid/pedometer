#!/bin/bash
# Basil Lin
# step counter project
# combines and all csv files of a single sensor type
# usage: ./sensorXcut.sh [directory] [window_size] [window_stride] [gait] [sensor #]
# [directory] is top level dir containing all subject files
# if [gait] is not Regular, Irregular, or SemiRegular, it will combine all gaits
# requires cutsteps.c to be compiled as executable cutsteps
# creates sensor0[#]_cut.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 5 ]; then
    echo "Usage: ./sensorXcut.sh [directory] [window_size] [window_stride] [gait] [sensor #]"
    exit 1
fi

rm sensor0* &> /dev/null

if [[ "$4" != "Regular" && "$4" != "Irregular" && "$4" != "SemiRegular" ]]; then
    echo "No gait, cutting sensor $5 only"
else
    echo "cutting gait $4, sensor $5"
fi

num=0

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        if [[ "$4" != "Regular" && "$4" != "Irregular" && "$4" != "SemiRegular" ]]; then
            ./cutsteps $2 $3 $d"/Regular/Sensor0"$5".csv" $d"/Regular/steps.txt" >> sensor0$5_cut.txt
            ./cutsteps $2 $3 $d"/Irregular/Sensor0"$5".csv" $d"/Irregular/steps.txt" >> sensor0$5_cut.txt
            ./cutsteps $2 $3 $d"/SemiRegular/Sensor0"$5".csv" $d"/SemiRegular/steps.txt" >> sensor0$5_cut.txt
        else
            ./cutsteps $2 $3 $d"/"$4"/Sensor0"$5".csv" $d"/"$4"/steps.txt" >> sensor0$5_$4_cut.txt
        fi
    fi
done

echo "$((num)) csv files cut for step windows."