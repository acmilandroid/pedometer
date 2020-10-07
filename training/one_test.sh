#!/bin/bash
# Basil Lin
# step counter project
# tests all 3 sensors in one gait for RCA and SDA using a trained input model [input_model.h5]
# Usage: ./one_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]
# [directory] is gait dir containing CSV files
# creates predicted_steps_sensor01.txt predicted_steps_sensor02.txt predicted_steps_sensor03.txt

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 5 ]; then
    echo "Usage: ./one_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]"
    exit 1
fi

# remove old training data
echo "Removing old data..."
rm results_all.txt
rm -rf temp_training_data
rm predicted_steps_sensor*
mkdir temp_training_data

echo "$1"

# remove old temporary training data
echo "Removing old training data..."
rm -r temp_training_data/*

# cut each sensor
for sensornum in 1 2 3
do
    echo "Cutting Sensor0$((sensornum)).csv"
    ./$2 $3 $4 $1"/Sensor0$((sensornum)).csv" $1"/steps.txt" >> "temp_training_data/sensor0$((sensornum)).txt"
done

# test each sensor
for sensornum in 1 2 3
do
    echo "Testing Sensor0$((sensornum))"
    python3 test_model.py $5 $3 "temp_training_data/sensor0$((sensornum)).txt" $1"/steps.txt" 1 >> results_all.txt
    mv predicted_steps.txt predicted_steps_sensor0$((sensornum)).txt
done