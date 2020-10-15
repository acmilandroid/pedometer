#!/bin/bash
# Basil Lin
# Step counter project
# Cuts, balances, and normalizes all sensor data per gait per sensor #
# Usage: per_gait_per_sensor_cutnormbal.sh [directory] [CUT] [STRIDE]
# [directory] is top level dir containing all subject files
# requires cutstep.c to be compiled as cutsteps in same directory
# creates ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_bal.txt ALL_[gait]_[sensor#]_norm.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "Usage: per_gait_per_sensor_cutnormbal.sh [directory] [CUT] [STRIDE]"
    exit 1
fi

num=0

echo "removing everything_cut.txt..."
rm everything_cut.txt &> /dev/null

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./cutsteps $2 $3 $d"/Irregular/Sensor01.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Irregular/Sensor02.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Irregular/Sensor03.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Regular/Sensor01.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Regular/Sensor02.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Regular/Sensor03.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/SemiRegular/Sensor01.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/SemiRegular/Sensor02.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/SemiRegular/Sensor03.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
    fi
done

echo "$((num)) csv files cut for step windows."