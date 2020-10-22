#!/bin/bash
# Basil Lin
# Step counter project
# Tests all 9 {sensor, gait} pairs and creates original and predicted histogram distribution for each pair
# Usage: ./compare_histograms.sh [directory] [window_size] [window_stride] [model_directory] [normalization_type]
# [directory] is top level dir containing all subject files
# [model_directory] is top level dir containing trained models
# [normalization_type 0|1] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# models in directory must be named ALL_{Gait}_{sensor #}_model.h5
# creates histogram/ dir containing histograms of each pair

echo "Bash version ${BASH_VERSION}"

# verify correct number of command line arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: ./compare_histograms.sh [directory] [window_size] [window_stride] [model_directory] [normalization_type]"
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

# loop through all subdirectories
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        
        # cut gait and sensor
        for ((sensor=1; sensor<=3; sensor++)) do
            ./../cut/cutsteps $2 $3 $d"/Regular/Sensor0$sensor.csv" $d"/Regular/steps.txt" > "temp_training_data/"$num"_Regular_"$sensor"_cut.txt"
            ./../cut/cutsteps $2 $3 $d"/SemiRegular/Sensor0$sensor.csv" $d"/SemiRegular/steps.txt" > "temp_training_data/"$num"_SemiRegular_"$sensor"_cut.txt"
            ./../cut/cutsteps $2 $3 $d"/Irregular/Sensor0$sensor.csv" $d"/Irregular/steps.txt" > "temp_training_data/"$num"_Irregular_"$sensor"_cut.txt"
        done

        # normalize per axis per sensor
        if (($5 == 0)); then
            echo "Normalizing per axis per sensor..."
            for ((sensor=1; sensor<=3; sensor++)) do
                python3 ../cut/normalize.py "temp_training_data/"$num"_Regular_"$sensor"_cut.txt" "temp_training_data/"$num"_Regular_"$sensor"_norm.txt" 0 $sensor > /dev/null
                python3 ../cut/normalize.py "temp_training_data/"$num"_SemiRegular_"$sensor"_cut.txt" "temp_training_data/"$num"_SemiRegular_"$sensor"_norm.txt" 0 $sensor > /dev/null
                python3 ../cut/normalize.py "temp_training_data/"$num"_Irregular_"$sensor"_cut.txt" "temp_training_data/"$num"_Irregular_"$sensor"_norm.txt" 0 $sensor > /dev/null
            done
        fi

        # normalize from -1.5 to 1.5 gravities
        if (($5 == 1)); then
            echo "Normalizing from -1.5 to 1.5 gravities..."
            for ((sensor=1; sensor<=3; sensor++)) do
                python3 ../cut/normalize.py "temp_training_data/"$num"_Regular_"$sensor"_cut.txt" "temp_training_data/"$num"_Regular_"$sensor"_norm.txt" 1 > /dev/null
                python3 ../cut/normalize.py "temp_training_data/"$num"_SemiRegular_"$sensor"_cut.txt" "temp_training_data/"$num"_SemiRegular_"$sensor"_norm.txt" 1 > /dev/null
                python3 ../cut/normalize.py "temp_training_data/"$num"_Irregular_"$sensor"_cut.txt" "temp_training_data/"$num"_Irregular_"$sensor"_norm.txt" 1 > /dev/null
            done
        fi

        # test models
        echo "Testing..."
        for ((sensor=1; sensor<=3; sensor++)) do
            python3 test_model.py $4"/ALL_Regular_"$sensor"_model.h5" $2 "temp_training_data/"$num"_Regular_"$sensor"_norm.txt" $d"/Regular/steps.txt" 0 "temp_training_data/ALL_Regular_"$sensor"_debug.csv" > /dev/null
            python3 test_model.py $4"/ALL_SemiRegular_"$sensor"_model.h5" $2 "temp_training_data/"$num"_SemiRegular_"$sensor"_norm.txt" $d"/SemiRegular/steps.txt" 0 "temp_training_data/ALL_SemiRegular_"$sensor"_debug.csv" > /dev/null
            python3 test_model.py $4"/ALL_Irregular_"$sensor"_model.h5" $2 "temp_training_data/"$num"_Irregular_"$sensor"_norm.txt" $d"/Irregular/steps.txt" 0 "temp_training_data/ALL_Irregular_"$sensor"_debug.csv" > /dev/null
        done

    fi
done

# create histograms of each
echo "Generating histograms..."
mkdir histograms
for ((sensor=1; sensor<=3; sensor++)) do
    python3 generate_histogram_debug.py "temp_training_data/ALL_Regular_"$sensor"_debug.csv" "histograms/ALL_Regular_"$sensor"_comparison.png" > /dev/null
    python3 generate_histogram_debug.py "temp_training_data/ALL_SemiRegular_"$sensor"_debug.csv" "histograms/ALL_SemiRegular_"$sensor"_comparison.png" > /dev/null
    python3 generate_histogram_debug.py "temp_training_data/ALL_Irregular_"$sensor"_debug.csv" "histograms/ALL_Irregular_"$sensor"_comparison.png" > /dev/null
done

# remove old stuff
echo "Removing temp data..."
rm -r temp_training_data &> /dev/null

echo "$((num)) subjects tested."