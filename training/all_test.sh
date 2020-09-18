#!/bin/bash
# Usage: ./all_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]
# tests every CSV file for RCA and SDA using a trained input model [input_model.h5]
# [directory] is top level dir containing all subject files
# creates results_all.txt

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 5 ]; then
    echo "Usage: ./all_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]"
    exit 1
fi

num=0

echo "Making temp_training_data directory..."
rm -r temp_training_data
mkdir temp_training_data

# loop through all subdirectories
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"

        # remove old temporary training data
        echo "Removing old training data..."
        rm -r temp_training_data/*

        # loop through all sensors
        for sensornum in 1 2 3
        do
            echo "Cutting Sensor0$((sensornum)).csv"
            # cut sensor files in each directory
            ./$2 $3 $4 $d"/Regular/Sensor0$((sensornum)).csv" $d"/Regular/steps.txt" >> "temp_training_data/sensor0$((sensornum))_regular.txt"
            ./$2 $3 $4 $d"/Irregular/Sensor0$((sensornum)).csv" $d"/Irregular/steps.txt" >> "temp_training_data/sensor0$((sensornum))_irregular.txt"
            ./$2 $3 $4 $d"/SemiRegular/Sensor0$((sensornum)).csv" $d"/SemiRegular/steps.txt" >> "temp_training_data/sensor0$((sensornum))_semiregular.txt"
        done

        for sensornum in 1 2 3
        do
            echo "Testing Sensor0$((sensornum))"
            # test sensor files in each directory
            python3 test_model.py $5 $3 "temp_training_data/sensor0$((sensornum))_regular.txt" $d"/Regular/steps.txt" 0 >> results_all.txt
            python3 test_model.py $5 $3 "temp_training_data/sensor0"$((sensornum))"_irregular.txt" $d"/Irregular/steps.txt" 0 >> results_all.txt
            python3 test_model.py $5 $3 "temp_training_data/sensor0"$((sensornum))"_semiregular.txt" $d"/SemiRegular/steps.txt" 0  >> results_all.txt
            ((num++))
        done
    fi
done

echo "$((num)) directories tested."