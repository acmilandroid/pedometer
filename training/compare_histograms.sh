#!/bin/bash
# Basil Lin
# Step counter project
# Tests all 9 {sensor, gait} pairs and creates original and predicted histogram distribution for each pair
# Usage: ./compare_histograms.sh [data/cutnorm_windowsize] [models/models_windowsize] [PedometerData] [fold_num] [window_size]
# [PedometerData] is top level dir containing all subject files
# [models/models_windowsize] is top level dir containing trained models
# [normalization_type 0|1] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# models in directory must be named ALL_{Gait}_{sensor #}_model.h5
# creates histogram/ dir containing histograms of each pair

echo "Bash version ${BASH_VERSION}"

# verify correct number of command line arguments
if [ "$#" -ne 5 ]; then
	echo "Usage: ./compare_histograms.sh [data/cutnorm_windowsize] [models/models_windowsize] [PedometerData] [fold_num] [window_size]"
	exit 1
fi

# remove old training data
rm -r temp_histogram_testing_data_"$5"
rm -r histograms_"$5" &> /dev/null
mkdir temp_histogram_testing_data_"$5"

num=0

# loop through each subject to test
for d in $3*; do
	if [ -d "$d" ]; then
		echo "$d"
		((num++))
		for (( sensor=1; sensor<=3; sensor++ )); do
			echo "Testing $2/trainingfold"$4"_Regular_"$sensor"_"$5"_model.h5"
			python3 ../training/test_model.py $2/trainingfold"$4"_Regular_"$sensor"_"$5"_model.h5 $5 $1/"$num"_Regular_"$sensor"_norm.txt $d/Regular/steps.txt 0 temp_histogram_testing_data_"$5"/ALL_Regular_"$sensor"_"$5"_debug.csv &> /dev/null
			echo "Testing $2/trainingfold"$4"_SemiRegular_"$sensor"_"$5"_model.h5"
			python3 ../training/test_model.py $2/trainingfold"$4"_SemiRegular_"$sensor"_"$5"_model.h5 $5 $1/"$num"_SemiRegular_"$sensor"_norm.txt $d/SemiRegular/steps.txt 0 temp_histogram_testing_data_"$5"/ALL_SemiRegular_"$sensor"_"$5"_debug.csv &> /dev/null
			echo "Testing $2/trainingfold"$4"_Irregular_"$sensor"_"$5"_model.h5"
			python3 ../training/test_model.py $2/trainingfold"$4"_Irregular_"$sensor"_"$5"_model.h5 $5 $1/"$num"_Irregular_"$sensor"_norm.txt $d/Irregular/steps.txt 0 temp_histogram_testing_data_"$5"/ALL_Irregular_"$sensor"_"$5"_debug.csv &> /dev/null
		done
	fi
done

# create histograms of each
echo "Generating histograms..."
mkdir histograms_"$5"
for ((sensor=1; sensor<=3; sensor++)) do
	python3 generate_histogram_debug.py temp_histogram_testing_data_"$5"/ALL_Regular_"$sensor"_"$5"_debug.csv histograms_"$5"/ALL_Regular_"$sensor"_"$5"_comparison.png &> /dev/null
	python3 generate_histogram_debug.py temp_histogram_testing_data_"$5"/ALL_SemiRegular_"$sensor"_"$5"_debug.csv histograms_"$5"/ALL_SemiRegular_"$sensor"_"$5"_comparison.png &> /dev/null
	python3 generate_histogram_debug.py temp_histogram_testing_data_"$5"/ALL_Irregular_"$sensor"_"$5"_debug.csv histograms_"$5"/ALL_Irregular_"$sensor"_"$5"_comparison.png &> /dev/null
done

# remove old stuff
echo "Removing temp data..."
rm -r temp_histogram_testing_data_"$5" &> /dev/null

echo "$((num)) subjects tested."