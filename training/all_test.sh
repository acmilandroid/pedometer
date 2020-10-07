#!/bin/bash
# Basil Lin
# step counter project
# tests every CSV file for RCA and SDA using a trained input model [input_model.h5]
# Usage: ./all_test.sh [directory] [window_size] [window_stride] [input_model.h5]
# [directory] is top level dir containing all subject files
# cutsteps executable must be compiled in ../cut/cutsteps
# creates results_all.txt

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 4 ]; then
    echo "Usage: ./all_test.sh [directory] [window_size] [window_stride] [input_model.h5]"
    exit 1
fi

num=0

# remove old training data
echo "Making temp_training_data directory..."
mkdir temp_training_data

# loop through all subdirectories
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"

        # remove old temporary training data
        echo "Removing old training data..."
        rm -r temp_training_data/*

        # cut each sensor
        for sensornum in 1 2 3
        do
            echo "Cutting Sensor0$((sensornum)).csv"
            # cut sensor files in each directory
            ./../cut/cutsteps $2 $3 $d"/Regular/Sensor0$((sensornum)).csv" $d"/Regular/steps.txt" >> "temp_training_data/sensor0$((sensornum))_regular.txt"
            ./../cut/cutsteps $2 $3 $d"/Irregular/Sensor0$((sensornum)).csv" $d"/Irregular/steps.txt" >> "temp_training_data/sensor0$((sensornum))_irregular.txt"
            ./../cut/cutsteps $2 $3 $d"/SemiRegular/Sensor0$((sensornum)).csv" $d"/SemiRegular/steps.txt" >> "temp_training_data/sensor0$((sensornum))_semiregular.txt"
        done

        # normalize each sensor
        for sensornum in 1 2 3
        do
            echo "Normalizing Sensor0$((sensornum))"
            # cut sensor files in each directory
            python3 ../cut/normalize.py "temp_training_data/sensor0$((sensornum))_regular.txt" 0 $((sensornum)) > /dev/null
            mv data_normalized_sensor0$((sensornum)).txt temp_training_data/sensor0$((sensornum))_regular_normalized.txt
            python3 ../cut/normalize.py "temp_training_data/sensor0$((sensornum))_irregular.txt" 0 $((sensornum)) > /dev/null
            mv data_normalized_sensor0$((sensornum)).txt temp_training_data/sensor0$((sensornum))_irregular_normalized.txt
            python3 ../cut/normalize.py "temp_training_data/sensor0$((sensornum))_semiregular.txt" 0 $((sensornum)) > /dev/null
            mv data_normalized_sensor0$((sensornum)).txt temp_training_data/sensor0$((sensornum))_semiregular_normalized.txt
        done

        # test each sensor
        for sensornum in 1 2 3
        do
            echo "Testing Sensor0$((sensornum))"
            # test sensor files in each directory
            python3 test_model.py $4 $2 "temp_training_data/sensor0$((sensornum))_regular_normalized.txt" $d"/Regular/steps.txt" 0 >> results_all.txt
            python3 test_model.py $4 $2 "temp_training_data/sensor0"$((sensornum))"_irregular_normalized.txt" $d"/Irregular/steps.txt" 0 >> results_all.txt
            python3 test_model.py $4 $2 "temp_training_data/sensor0"$((sensornum))"_semiregular_normalized.txt" $d"/SemiRegular/steps.txt" 0  >> results_all.txt
        done
        ((num++))
    fi
done

# grab important result data and make temp file
pcregrep -M "TP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRun count accuracy:.*\nStep detection accuracy F1 Score:.*" results_all.txt | sed 's/^.*: //' > important_results.txt

# write data to csv file
line=0
echo "Subject,Gait,Sensor,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > results.csv

for (( i = 0; i < $num; i++ )) do

    ((print = i + 1 ))
    echo "Subject $print"
    
    for (( j = 0; j < 3; j++ )) do

        # get line index
        ((line = 63 * $i + 21 * $j))

        # regular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> results.csv
        echo -n "regular," >> results.csv
        ((print = j + 1 ))
        echo -n "$print," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv

        # irregular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> results.csv
        echo -n "irregular," >> results.csv
        ((print = j + 1 ))
        echo -n "$print," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv

        # semiregular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> results.csv
        echo -n "semiregular," >> results.csv
        ((print = j + 1 ))
        echo -n "$print," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv

    done
done

rm important_results.txt
rm results_all.txt
rm -r temp_training_data

echo "$((num)) subjects tested."