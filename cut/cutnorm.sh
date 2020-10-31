#!/bin/bash
# Basil Lin
# Step counter project
# Cuts and normalizes each csv file in [directory] for testing
# Usage: ./cutnorm.sh [directory] [window_size] [normalization_type]
# [directory] is top level dir containing all subject files
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# creates testing_data_cutnorm_[window_size] directory containing cut and normalized files

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 3 ]; then
	echo "Usage: ./cutnorm.sh [directory] [window_size] [normalization_type]"
	exit 1
fi

num=0

# remove old training data
echo "Removing old data..."
rm -r testing_data_cutnorm_$2
mkdir testing_data_cutnorm_$2

# loop through all subdirectories
for d in $1*; do
	if [ -d "$d" ]; then
		echo "$d"
		((num++))

		# cut gait and sensor
		for ((sensor=1; sensor<=3; sensor++)) do
			echo "Cutting Sensor0$sensor..."
			./../cut/cutsteps $2 1 $d"/Regular/Sensor0$sensor.csv" $d"/Regular/steps.txt" > "testing_data_cutnorm_$2/"$num"_Regular_"$sensor"_cut.txt"
			./../cut/cutsteps $2 1 $d"/SemiRegular/Sensor0$sensor.csv" $d"/SemiRegular/steps.txt" > "testing_data_cutnorm_$2/"$num"_SemiRegular_"$sensor"_cut.txt"
			./../cut/cutsteps $2 1 $d"/Irregular/Sensor0$sensor.csv" $d"/Irregular/steps.txt" > "testing_data_cutnorm_$2/"$num"_Irregular_"$sensor"_cut.txt"
		done

		# normalize per axis per sensor
		if (($3 == 0)); then
			echo "Normalizing per axis per sensor..."
			for ((sensor=1; sensor<=3; sensor++)) do
				echo "Normalizing Sensor0$sensor..."
				python3 ../cut/normalize.py "testing_data_cutnorm_$2/"$num"_Regular_"$sensor"_cut.txt" "testing_data_cutnorm_$2/"$num"_Regular_"$sensor"_cutnorm.txt" 0 $sensor
				python3 ../cut/normalize.py "testing_data_cutnorm_$2/"$num"_SemiRegular_"$sensor"_cut.txt" "testing_data_cutnorm_$2/"$num"_SemiRegular_"$sensor"_cutnorm.txt" 0 $sensor
				python3 ../cut/normalize.py "testing_data_cutnorm_$2/"$num"_Irregular_"$sensor"_cut.txt" "testing_data_cutnorm_$2/"$num"_Irregular_"$sensor"_cutnorm.txt" 0 $sensor
			done
		fi

		# normalize from -1.5 to 1.5 gravities
		if (($3 == 1)); then
			echo "Normalizing from -1.5 to 1.5 gravities..."
			for ((sensor=1; sensor<=3; sensor++)) do
				echo "Normalizing Sensor0$sensor..."
				python3 ../cut/normalize.py "testing_data_cutnorm_$2/"$num"_Regular_"$sensor"_cut.txt" "testing_data_cutnorm_$2/"$num"_Regular_"$sensor"_cutnorm.txt" 1
				python3 ../cut/normalize.py "testing_data_cutnorm_$2/"$num"_SemiRegular_"$sensor"_cut.txt" "testing_data_cutnorm_$2/"$num"_SemiRegular_"$sensor"_cutnorm.txt" 1
				python3 ../cut/normalize.py "testing_data_cutnorm_$2/"$num"_Irregular_"$sensor"_cut.txt" "testing_data_cutnorm_$2/"$num"_Irregular_"$sensor"_cutnorm.txt" 1
			done
		fi

	fi
done

echo "$((num)) subjects cut and normalized."