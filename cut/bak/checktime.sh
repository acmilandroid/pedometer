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
if [ "$#" -ne 1 ]; then
	echo "Usage: ./checktime.sh [PedometerData]"
	exit 1
fi

num=0

# loop through all subdirectories
for d in $1*; do
	if [ -d "$d" ]; then
		echo "$d"

		s1time=$(head -4 $d/Regular/Sensor01.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		s2time=$(head -4 $d/Regular/Sensor02.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		s3time=$(head -4 $d/Regular/Sensor03.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		echo "s1time: $s1time"
		echo "s2time: $s2time"
		echo "s3time: $s3time"
		if (($s1time > $s2time && $s2time > $s3time)); then
			echo "bad fail shit"
		fi

		s1time=$(head -4 $d/SemiRegular/Sensor01.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		s2time=$(head -4 $d/SemiRegular/Sensor02.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		s3time=$(head -4 $d/SemiRegular/Sensor03.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		echo "s1time: $s1time"
		echo "s2time: $s2time"
		echo "s3time: $s3time"
		if (($s1time > $s2time && $s2time > $s3time)); then
			echo "bad fail shit"
		fi

		s1time=$(head -4 $d/Irregular/Sensor01.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		s2time=$(head -4 $d/Irregular/Sensor02.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		s3time=$(head -4 $d/Irregular/Sensor03.csv | tail -1 | head -c 33 | tail -c 16 | head -c 12)
		echo "s1time: $s1time"
		echo "s2time: $s2time"
		echo "s3time: $s3time"
		if (($s1time > $s2time && $s2time > $s3time)); then
			echo "bad fail shit"
		fi		

	fi
done
