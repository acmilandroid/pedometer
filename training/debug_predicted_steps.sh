#!/bin/bash
# Basil Lin
# Step counter project
# Tests all 9 {sensor, gait} pairs and prints individual window counts, sum, and output steps to csv file
# Usage: ./debug_predicted_steps.sh [directory] [window_size] [window_stride] [input_model.h5] [normalization_type] [output_histogram.png]
# [directory] is top level dir containing all subject files
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 5 ]; then
    echo "Usage: ./debug_predicted_steps.sh [directory] [window_size] [window_stride] [input_model.h5] [normalization_type]"
    exit 1
fi

if [[ "$6" != "Regular" && "$6" != "Irregular" && "$6" != "SemiRegular" ]]; then
    echo "Gait type error, exiting"
    exit 1
fi

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
        for ((sensor=1; sensor<=3; sensor++)) do
            ./../cut/cutsteps $2 $3 $d"/Regular/Sensor0$sensor.csv" $d"/Regular/steps.txt" > "temp_training_data/Regular_"$sensor"_cut.txt"
            ./../cut/cutsteps $2 $3 $d"/SemiRegular/Sensor0$sensor.csv" $d"/SemiRegular/steps.txt" > "temp_training_data/SemiRegular_"$sensor"_cut.txt"
            ./../cut/cutsteps $2 $3 $d"/Irregular/Sensor0$sensor.csv" $d"/Irregular/steps.txt" > "temp_training_data/Irregular_"$sensor"_cut.txt"
        done

        # normalize per axis per sensor
        if (($5 == 0)); then
            echo "Normalizing per axis per sensor..."
            for ((sensor=1; sensor<=3; sensor++)) do
                python3 ../cut/normalize.py "temp_training_data/Regular_"$sensor"_cut.txt" "temp_training_data/Regular_"$sensor"_norm.txt" 0 $sensor > /dev/null
                python3 ../cut/normalize.py "temp_training_data/SemiRegular_"$sensor"_cut.txt" "temp_training_data/SemiRegular_"$sensor"_norm.txt" 0 $sensor > /dev/null
                python3 ../cut/normalize.py "temp_training_data/Irregular_"$sensor"_cut.txt" "temp_training_data/Irregular_"$sensor"_norm.txt" 0 $sensor > /dev/null
            done
        fi

        # normalize from -1.5 to 1.5 gravities
        if (($5 == 1)); then
            echo "Normalizing from -1.5 to 1.5 gravities..."
            for ((sensor=1; sensor<=3; sensor++)) do
                python3 ../cut/normalize.py "temp_training_data/Regular_"$sensor"_cut.txt" "temp_training_data/Regular_"$sensor"_norm.txt" 1 > /dev/null
                python3 ../cut/normalize.py "temp_training_data/SemiRegular_"$sensor"_cut.txt" "temp_training_data/SemiRegular_"$sensor"_norm.txt" 1 > /dev/null
                python3 ../cut/normalize.py "temp_training_data/Irregular_"$sensor"_cut.txt" "temp_training_data/Irregular_"$sensor"_norm.txt" 1 > /dev/null
            done
        fi

        # test each sensor
        echo "Testing..."
        for ((sensor=1; sensor<=3; sensor++)) do
            python3 test_model.py $4 $2 "temp_training_data/Regular_"$sensor"_norm.txt" $d"/Regular/steps.txt" 0 1 > /dev/null
            python3 test_model.py $4 $2 "temp_training_data/SemiRegular_"$sensor"_norm.txt" $d"/SemiRegular/steps.txt" 0 1 > /dev/null
            python3 test_model.py $4 $2 "temp_training_data/Irregular_"$sensor"_norm.txt" $d"/Irregular/steps.txt" 0 1 > /dev/null
        done
        ((num++))
    fi
done

# create histograms of each
echo "Generating histograms..."
for ((sensor=1; sensor<=3; sensor++)) do    
    python3 generate_histogram.py "Regular_"$sensor"_norm.txt" "Regular_"$sensor"_norm_debug.csv" 
    python3 generate_histogram.py "SemiRegular_"$sensor"_norm.txt" "SemiRegular_"$sensor"_norm_debug.csv" 
    python3 generate_histogram.py "Irregular_"$sensor"_norm.txt" "Irregular_"$sensor"_norm_debug.csv" 
done

# remove old stuff
echo "Removing temp data..."
for ((sensor=1; sensor<=3; sensor++)) do
    rm "Regular_"$sensor"_norm.txt"
    rm "SemiRegular_"$sensor"_norm.txt"
    rm "Irregular_"$sensor"_norm.txt"
done

rm -r temp_training_data

echo "$((num)) subjects tested."