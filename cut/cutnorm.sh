#!/bin/bash
# Basil Lin
# Step counter project
# Cuts and normalizes each csv file in [PedometerData] for testing
# Usage: ./cutnorm.sh [PedometerData] [window_size] [window_stride] [normalization_type]
# [PedometerData] is top level dir containing all subject files
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in cutsteps
# creates cutnorm_[window_size] directory containing cut and normalized files
# cut files are [subject#]_[gait]_[sensor#]_cut.txt
# cut then normalized files are [subject#]_[gait]_[sensor#]_norm.txt

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 4 ]; then
	echo "Usage: ./cutnorm.sh [PedometerData] [window_size] [window_stride] [normalization_type]"
	exit 1
fi

num=0

# remove old training data
echo "Removing old data..."
rm -r cutnorm_$2
mkdir cutnorm_$2

# loop through all subdirectories
for d in $1*; do
	if [ -d "$d" ]; then
		echo "$d"
		((num++))

		# cut gait and sensor
		echo "Cutting data..."
		for ((sensor=1; sensor<=3; sensor++)) do
			./cutsteps $2 $3 $d"/Regular/Sensor0$sensor.csv" $d"/Regular/steps.txt" > "cutnorm_$2/"$num"_Regular_"$sensor"_cut.txt"
			./cutsteps $2 $3 $d"/SemiRegular/Sensor0$sensor.csv" $d"/SemiRegular/steps.txt" > "cutnorm_$2/"$num"_SemiRegular_"$sensor"_cut.txt"
			./cutsteps $2 $3 $d"/Irregular/Sensor0$sensor.csv" $d"/Irregular/steps.txt" > "cutnorm_$2/"$num"_Irregular_"$sensor"_cut.txt"
		done

		# normalize per axis per sensor
		if (($4 == 0)); then
			echo "Normalizing per axis per sensor..."
			for ((sensor=1; sensor<=3; sensor++)) do
				python3 normalize.py "cutnorm_$2/"$num"_Regular_"$sensor"_cut.txt" "cutnorm_$2/"$num"_Regular_"$sensor"_norm.txt" 0 $sensor
				python3 normalize.py "cutnorm_$2/"$num"_SemiRegular_"$sensor"_cut.txt" "cutnorm_$2/"$num"_SemiRegular_"$sensor"_norm.txt" 0 $sensor
				python3 normalize.py "cutnorm_$2/"$num"_Irregular_"$sensor"_cut.txt" "cutnorm_$2/"$num"_Irregular_"$sensor"_norm.txt" 0 $sensor
			done
		fi

		# normalize from -1.5 to 1.5 gravities
		if (($4 == 1)); then
			echo "Normalizing from -1.5 to 1.5 gravities..."
			for ((sensor=1; sensor<=3; sensor++)) do
				python3 normalize.py "cutnorm_$2/"$num"_Regular_"$sensor"_cut.txt" "cutnorm_$2/"$num"_Regular_"$sensor"_norm.txt" 1
				python3 normalize.py "cutnorm_$2/"$num"_SemiRegular_"$sensor"_cut.txt" "cutnorm_$2/"$num"_SemiRegular_"$sensor"_norm.txt" 1
				python3 normalize.py "cutnorm_$2/"$num"_Irregular_"$sensor"_cut.txt" "cutnorm_$2/"$num"_Irregular_"$sensor"_norm.txt" 1
			done
		fi

	fi
done

echo "$((num)) subjects cut and normalized."