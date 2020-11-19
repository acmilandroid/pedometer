#!/bin/bash
# Basil Lin
# step counter project
# tests all 3 sensors in one gait for RCA and SDA using a model trained for each sensor
# used to produce predicted step files for viewing in STEPCOUNTERVIEW
# Usage: ./predict_steps_3model.sh [gait_directory] [window_size] [window_stride] [training_gait_] [normalization_type]
# [gait_directory] is gait dir containing CSV files
# [training_gait_] is beginning of model name, part before training_[gait]_{[sensor #]_[window_size]_model.h5}
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# creates predicted_steps_sensor01.txt predicted_steps_sensor02.txt predicted_steps_sensor03.txt

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 5 ]; then
	echo "Usage: ./predict_steps_3model.sh [gait_directory] [window_size] [window_stride] [training_gait_] [normalization_type]"
	exit 1
fi

# remove old training data
rm results_all.txt &> /dev/null
rm -r temp_training_data &> /dev/null
rm predicted_steps_sensor* &> /dev/null
mkdir temp_training_data &> /dev/null

echo "$1"

# cut each sensor
echo "Cutting data..."
for sensornum in 1 2 3
do
	./../cut/cutsteps $2 $3 $1"/Sensor0$((sensornum)).csv" $1"/steps.txt" > "temp_training_data/sensor0$((sensornum)).txt"
done

# normalize per axis per sensor
if (($5 == 0)); then
	echo "Normalizing per axis per sensor..."
	# normalize each sensor
	for sensornum in 1 2 3
	do
		python3 ../cut/normalize.py "temp_training_data/sensor0$((sensornum)).txt" "temp_training_data/sensor0$((sensornum))_normalized.txt" 0 $((sensornum)) &> /dev/null
	done
fi

# normalize from -1.5 to 1.5 gravities
if (($5 == 1)); then
	echo "Normalizing from -1.5 to 1.5 gravities..."
	# normalize each sensor
	for sensornum in 1 2 3
	do
		python3 ../cut/normalize.py "temp_training_data/sensor0$((sensornum)).txt" "temp_training_data/sensor0$((sensornum))_normalized.txt" 1 &> /dev/null
	done
fi

# test each sensor and produce predicted steps
for sensornum in 1 2 3
do
	echo "Testing $4"$sensornum"_$2_model.h5"
	python3 test_model.py $4"$sensornum"_$2_model.h5 $2 "temp_training_data/sensor0$((sensornum))_normalized.txt" $1"/steps.txt" 1 >> results_all.txt
	mv predicted_steps.txt predicted_steps_sensor0$((sensornum)).txt
done

cat results_all.txt
rm results_all.txt
rm -r temp_training_data