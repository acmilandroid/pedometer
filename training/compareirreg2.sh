#!/bin/bash
# Basil Lin
# Step counter project
# Tests all 9 {sensor, gait} pairs and prints individual window counts, sum, and output steps to csv file
# Usage: ./compare_histograms.sh [directory] [window_size] [window_stride] [input_model.h5] [normalization_type] [output_histogram.png]
# [directory] is top level dir containing all subject files
# [model_directory] is top level dir containing trained models
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# models in directory must be named ALL_{gait}_{sensor #}_model.h5
# creates [output_file.csv]

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 5 ]; then
    echo "Usage: ./comapare_histograms.sh [directory] [window_size] [window_stride] [model_directory] [normalization_type]"
    exit 1
fi

num=0

# loop through all subdirectories
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        
        ./../cut/cutsteps $2 $3 $d"/Irregular/Sensor02.csv" $d"/Irregular/steps.txt" > "temp_training_data/"$num"_Irregular_2_cut.txt"

        # normalize per axis per sensor
        if (($5 == 0)); then
            python3 ../cut/normalize.py "temp_training_data/"$num"_Irregular_2_cut.txt" "temp_training_data/"$num"_Irregular_2_norm.txt" 0 2 > /dev/null
        fi

        # normalize from -1.5 to 1.5 gravities
        if (($5 == 1)); then
            python3 ../cut/normalize.py "temp_training_data/"$num"_Irregular_2_cut.txt" "temp_training_data/"$num"_Irregular_2_norm.txt" 1 > /dev/null
        fi

        # test each sensor
        echo "Testing..."
        python3 test_model.py $4"/ALL_Irregular_2_model.h5" $2 "temp_training_data/"$num"_Irregular_2_norm.txt" $d"/Irregular/steps.txt" 0 "temp_training_data/ALL_Irregular_2_debug.csv" > /dev/null

    fi
done

# create histograms of each
echo "Generating histograms..."
python3 generate_histogram.py "temp_training_data/ALL_Irregular_2_debug.csv" "histograms/ALL_Irregular_2_comparison.png" > /dev/null

echo "$((num)) subjects tested."