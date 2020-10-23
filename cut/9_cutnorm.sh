#!/bin/bash
# Basil Lin
# Step counter project
# Cuts and normalizes all sensor data per gait per sensor #
# Usage: per_gait_per_sensor_cutnormcut.sh [directory] [window_size] [window_stride]
# [directory] is top level dir containing all subject files
# requires cutsteps.c to be compiled as cutsteps in same directory
# creates ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_cutnorm.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "Usage: per_gait_per_sensor_cutnormcut.sh [directory] [window_size] [window_stride]"
    exit 1
fi

# clean old data
echo "removing old data..."
rm *_cut.txt &> /dev/null
rm *_cutnorm.txt &> /dev/null

# cut data
echo "cutting data..."
num=0
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        for ((sensor=1; sensor<=3; sensor++)); do
            ./cutsteps $2 $3 $d"/Regular/Sensor0"$sensor".csv" $d"/Regular/steps.txt" >> "ALL_Regular_"$sensor"_cut.txt"
            ./cutsteps $2 $3 $d"/SemiRegular/Sensor0"$sensor".csv" $d"/SemiRegular/steps.txt" >> "ALL_SemiRegular_"$sensor"_cut.txt"
            ./cutsteps $2 $3 $d"/Irregular/Sensor0"$sensor".csv" $d"/Irregular/steps.txt" >> "ALL_Irregular_"$sensor"_cut.txt"
        done
    fi
done

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

echo "Done cutting and normalizing data. Use ALL_[gait]_[sensor#]_cutnorm.txt for testing."