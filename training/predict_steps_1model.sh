#!/bin/bash
# Basil Lin
# step counter project
# tests all 3 sensors in one gait for RCA and SDA using a single trained input model [input_model.h5]
# used to produce predicted step files for viewing in STEPCOUNTERVIEW
# Usage: ./predict_steps_1model.sh [gait_directory] [window_size] [window_stride] [input_model.h5] [normalization_type]
# [gait_directory] is gait dir containing CSV files
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# creates predicted_steps_sensor01.txt predicted_steps_sensor02.txt predicted_steps_sensor03.txt

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 5 ]; then
	echo "Usage: ./predict_steps_1model.sh [gait_directory] [window_size] [window_stride] [input_model.h5] [normalization_type]"
	exit 1
fi

# remove old training data
echo "Removing old data..."
rm results_all.txt &> /dev/null
rm -r temp_training_data &> /dev/null
rm predicted_steps_sensor* &> /dev/null
mkdir temp_training_data &> /dev/null

echo "$1"

# remove old temporary training data
echo "Removing old training data..."
rm -r temp_training_data/* &> /dev/null

# cut each sensor
for sensornum in 1 2 3
do
	echo "Cutting Sensor0$((sensornum)).csv"
	./../cut/cutsteps $2 $3 $1"/Sensor0$((sensornum)).csv" $1"/steps.txt" > "temp_training_data/sensor0$((sensornum)).txt"
done

# normalize per axis per sensor
if (($5 == 0)); then
	echo "Normalizing per axis per sensor"
	# normalize each sensor
	for sensornum in 1 2 3
	do
		echo "Normalizing Sensor0$((sensornum))"
		python3 ../cut/normalize.py "temp_training_data/sensor0$((sensornum)).txt" "temp_training_data/sensor0$((sensornum))_normalized.txt" 0 $((sensornum)) > /dev/null
	done
fi

# normalize from -1.5 to 1.5 gravities
if (($5 == 1)); then
	echo "Normalizing from -1.5 to 1.5 gravities"
	# normalize each sensor
	for sensornum in 1 2 3
	do
		echo "Normalizing Sensor0$((sensornum))"
		python3 ../cut/normalize.py "temp_training_data/sensor0$((sensornum)).txt" "temp_training_data/sensor0$((sensornum))_normalized.txt" 1 > /dev/null
	done
fi

# test each sensor and produce predicted steps
for sensornum in 1 2 3
do
	echo "Testing Sensor0$((sensornum))"
	python3 test_model.py $4 $2 "temp_training_data/sensor0$((sensornum))_normalized.txt" $1"/steps.txt" 1 >> results_all.txt
	mv predicted_steps.txt predicted_steps_sensor0$((sensornum)).txt
done

cat results_all.txt
rm results_all.txt &> /dev/null
rm -r temp_training_data &> /dev/null