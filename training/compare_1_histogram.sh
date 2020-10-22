#!/bin/bash
# Basil Lin
# Step counter project
# Tests a single given {sensor, gait} pair and create original and predicted histogram distribution
# Usage: ./compare_1_histogram.sh [directory] [window_size] [window_stride] [model.h5] [normalization_type]
# [directory] is top level dir containing all subject files
# [model.h5] is the trained model to use for predictions
# [normalization_type 0|1] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# models in directory must be named ALL_{Gait}_{sensor #}_model.h5
# creates histogram/ dir containing histogram

echo "Bash version ${BASH_VERSION}"

# verify correct number of command line arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: ./compare_1_histogram.sh [directory] [window_size] [window_stride] [model.h5] [normalization_type]"
    exit 1
fi

# check normalization argument
if (($5 != 0 && $5 != 1)); then
    echo "[normalization_type 0|1] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities"
    exit 1
fi

num=0

# remove old training data
echo "Removing old data..."
rm debug.csv &> /dev/null
rm -r temp_training_data &> /dev/null
rm -r histograms &> /dev/null
mkdir temp_training_data &> /dev/null

STR=$4

# find gait type using input model name
SUB='Regular'
if [[ "$STR" == *"$SUB"* ]]; then
    echo "Regular gait"
    gait='Regular'
fi
SUB='SemiRegular'
if [[ "$STR" == *"$SUB"* ]]; then
    echo "SemiRegular gait"
    gait='SemiRegular'
fi
SUB='Irregular'
if [[ "$STR" == *"$SUB"* ]]; then
    echo "Irregular gait"
    gait='Irregular'
fi

# find sensor type using input model name
SUB='_1'
if [[ "$STR" == *"$SUB"* ]]; then
    echo "Sensor 1"
    sensor=1
fi
SUB='_2'
if [[ "$STR" == *"$SUB"* ]]; then
    echo "Sensor 2"
    sensor=2
fi
SUB='_3'
if [[ "$STR" == *"$SUB"* ]]; then
    echo "Sensor 3"
    sensor=3
fi

# loop through all subdirectories
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        
        # cut gait and sensor
        ./../cut/cutsteps $2 $3 $d"/$gait/Sensor0$sensor.csv" $d"/$gait/steps.txt" > "temp_training_data/"$num"_"$gait"_"$sensor"_cut.txt"

        # normalize per axis per sensor
        if (($5 == 0)); then
            echo "Normalizing per axis per sensor..."
            python3 ../cut/normalize.py "temp_training_data/"$num"_"$gait"_"$sensor"_cut.txt" "temp_training_data/"$num"_"$gait"_"$sensor"_norm.txt" 0 $sensor > /dev/null
        fi

        # normalize from -1.5 to 1.5 gravities
        if (($5 == 1)); then
            echo "Normalizing from -1.5 to 1.5 gravities..."
            python3 ../cut/normalize.py "temp_training_data/"$num"_"$gait"_"$sensor"_cut.txt" "temp_training_data/"$num"_"$gait"_"$sensor"_norm.txt" 1 > /dev/null
        fi

        # test models
        echo "Testing..."
        python3 test_model.py $4 $2 "temp_training_data/"$num"_"$gait"_"$sensor"_norm.txt" $d"/$gait/steps.txt" 0 "temp_training_data/ALL_"$gait"_"$sensor"_debug.csv" > /dev/null

    fi
done

# create histogram
echo "Generating histogram..."
mkdir histograms
python3 generate_histogram_debug.py "temp_training_data/ALL_"$gait"_"$sensor"_debug.csv" "histograms/ALL_"$gait"_"$sensor"_comparison.png" > /dev/null

# remove old stuff
echo "Removing temp data..."
rm -r temp_training_data &> /dev/null

echo "$((num)) subjects tested."