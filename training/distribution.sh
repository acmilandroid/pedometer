#!/bin/bash
# Basil Lin
# Step counter project
# Tests a given {sensor, gait} pair and prints individual window counts, sum, and output steps to csv file
# Usage: ./distribution.sh [directory] [window_size] [window_stride] [input_model.h5] [normalization_type] [gait] [sensor #] [output_file.csv]
# [directory] is top level dir containing all subject files
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 8 ]; then
    echo "Usage: ./distribution.sh [directory] [window_size] [window_stride] [input_model.h5] [normalization_type] [gait] [sensor #] [output_file.csv]"
    exit 1
fi

if [[ "$6" != "Regular" && "$6" != "Irregular" && "$6" != "SemiRegular" ]]; then
    echo "Gait type error, exiting"
    exit 1
else

num=0

# remove old training data
echo "Removing old data..."
rm debug.csv &> /dev/null
rm -r temp_training_data &> /dev/null
mkdir temp_training_data &> /dev/null

# loop through all subdirectories
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"

        # remove old temporary training data
        echo "Removing old training data..."
        rm -r temp_training_data/* &> /dev/null
        
        # cut gait and sensor
        ./../cut/cutsteps $2 $3 $d"/$6/Sensor0$7.csv" $d"/$6/steps.txt" > "temp_training_data/$6_$7_cut.txt"
        mv $6_$7_cut.txt temp_training_data/

        # normalize per axis per sensor
        if (($5 == 0)); then
            echo "Normalizing per axis per sensor"
            python3 ../cut/normalize.py "temp_training_data/$6_$7_cut.txt" "temp_training_data/$6_$7_norm.txt" 0 $7 > /dev/null
        fi

        # normalize from -1.5 to 1.5 gravities
        if (($5 == 1)); then
            echo "Normalizing from -1.5 to 1.5 gravities"
            python3 ../cut/normalize.py "temp_training_data/$6_$7_cut.txt" "temp_training_data/$6_$7_norm.txt" 1 > /dev/null
        fi

        # test each sensor
        echo "Testing"
        python3 test_model.py $4 $2 "temp_training_data/$6_$7_norm.txt" $d"/$6/steps.txt" 0 1 > /dev/null
        ((num++))
    fi
done

rm -r temp_training_data

echo "$((num)) subjects tested."