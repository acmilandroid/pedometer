#!/bin/bash
# Basil Lin
# Step counter project
# Makes 9 {sensor, gait} pair original and predicted histogram distribution for each pair
# Usage: ./9_histogram.sh [histogram_directory] [window_size]
# creates histograms_[window_size] dir containing histograms of each pair

echo "Bash version ${BASH_VERSION}"

# verify correct number of command line arguments
if [ "$#" -ne 2 ]; then
	echo "Usage: ./compare_histograms.sh [histogram_directory] [window_size]"
	exit 1
fi

echo "Generating histograms..."
rm -r histograms_"$2"
mkdir histograms_"$2"
for ((sensor=1; sensor<=3; sensor++)) do
	python3 generate_histogram_debug.py $1/ALL_Regular_"$sensor"_"$2"_debug.csv histograms_"$2"/ALL_Regular_"$sensor"_"$2"_comparison.eps
	python3 generate_histogram_debug.py $1/ALL_SemiRegular_"$sensor"_"$2"_debug.csv histograms_"$2"/ALL_SemiRegular_"$sensor"_"$2"_comparison.eps
	python3 generate_histogram_debug.py $1/ALL_Irregular_"$sensor"_"$2"_debug.csv histograms_"$2"/ALL_Irregular_"$sensor"_"$2"_comparison.eps
done