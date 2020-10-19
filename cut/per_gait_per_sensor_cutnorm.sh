#!/bin/bash
# Basil Lin
# Step counter project
# Cuts, cutances, and normalizes all sensor data per gait per sensor #
# Usage: per_gait_per_sensor_cutnormcut.sh [directory] [window_size] [window_stride]
# [directory] is top level dir containing all subject files
# requires cutstep.c to be compiled as cutsteps in same directory
# creates ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_cutnorm.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "Usage: per_gait_per_sensor_cutnormcut.sh [directory] [window_size] [window_stride]"
    exit 1
fi

# cut data
echo "cutting data..."
./sensorXcut.sh $1 $2 $3 Regular 1 &> /dev/null
./sensorXcut.sh $1 $2 $3 Regular 2 &> /dev/null
./sensorXcut.sh $1 $2 $3 Regular 3 &> /dev/null
./sensorXcut.sh $1 $2 $3 SemiRegular 1 &> /dev/null
./sensorXcut.sh $1 $2 $3 SemiRegular 2 &> /dev/null
./sensorXcut.sh $1 $2 $3 SemiRegular 3 &> /dev/null
./sensorXcut.sh $1 $2 $3 Irregular 1 &> /dev/null
./sensorXcut.sh $1 $2 $3 Irregular 2 &> /dev/null
./sensorXcut.sh $1 $2 $3 Irregular 3 &> /dev/null

# normalize data
echo "normalizing data..."
python3 normalize.py ALL_Regular_1_cut.txt ALL_Regular_1_cutnorm.txt 0 1 &> /dev/null
python3 normalize.py ALL_Regular_2_cut.txt ALL_Regular_2_cutnorm.txt 0 2 &> /dev/null
python3 normalize.py ALL_Regular_3_cut.txt ALL_Regular_3_cutnorm.txt 0 3 &> /dev/null
python3 normalize.py ALL_SemiRegular_1_cut.txt ALL_SemiRegular_1_cutnorm.txt 0 1 &> /dev/null
python3 normalize.py ALL_SemiRegular_2_cut.txt ALL_SemiRegular_2_cutnorm.txt 0 2 &> /dev/null
python3 normalize.py ALL_SemiRegular_3_cut.txt ALL_SemiRegular_3_cutnorm.txt 0 3 &> /dev/null
python3 normalize.py ALL_Irregular_1_cut.txt ALL_Irregular_1_cutnorm.txt 0 1 &> /dev/null
python3 normalize.py ALL_Irregular_2_cut.txt ALL_Irregular_2_cutnorm.txt 0 2 &> /dev/null
python3 normalize.py ALL_Irregular_3_cut.txt ALL_Irregular_3_cutnorm.txt 0 3 &> /dev/null


echo "Done cutting, cutancing, and normalizing data. Use ALL_[gait]_[sensor#]_cutnorm.txt for testing."