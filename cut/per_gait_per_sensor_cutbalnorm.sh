#!/bin/bash
# Basil Lin
# Step counter project
# Cuts, balances, and normalizes all sensor data per gait per sensor #
# Usage: per_gait_per_sensor_cutnormbal.sh [directory] [CUT] [STRIDE]
# [directory] is top level dir containing all subject files
# requires cutstep.c to be compiled as cutsteps in same directory
# creates ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_bal.txt ALL_[gait]_[sensor#]_norm.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "Usage: per_gait_per_sensor_cutnormbal.sh [directory] [CUT] [STRIDE]"
    exit 1
fi

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"

        # cut data
        ./sensorXcut.sh $d $2 $3 Regular 1
        ./sensorXcut.sh $d $2 $3 Regular 2
        ./sensorXcut.sh $d $2 $3 Regular 3
        ./sensorXcut.sh $d $2 $3 SemiRegular 1
        ./sensorXcut.sh $d $2 $3 SemiRegular 2
        ./sensorXcut.sh $d $2 $3 SemiRegular 3
        ./sensorXcut.sh $d $2 $3 Irregular 1
        ./sensorXcut.sh $d $2 $3 Irregular 2
        ./sensorXcut.sh $d $2 $3 Irregular 3

        # balance data
        python3 balance_data.py ALL_Regular_1_cut.txt ALL_Regular_1_bal.txt 
        python3 balance_data.py ALL_Regular_2_cut.txt ALL_Regular_2_bal.txt 
        python3 balance_data.py ALL_Regular_3_cut.txt ALL_Regular_3_bal.txt 
        python3 balance_data.py ALL_SemiRegular_1_cut.txt ALL_SemiRegular_1_bal.txt 
        python3 balance_data.py ALL_SemiRegular_2_cut.txt ALL_SemiRegular_2_bal.txt 
        python3 balance_data.py ALL_SemiRegular_3_cut.txt ALL_SemiRegular_3_bal.txt 
        python3 balance_data.py ALL_Irregular_1_cut.txt ALL_Irregular_1_bal.txt 
        python3 balance_data.py ALL_Irregular_2_cut.txt ALL_Irregular_2_bal.txt 
        python3 balance_data.py ALL_Irregular_3_cut.txt ALL_Irregular_3_bal.txt

        # normalize data
        python3 normalize.py ALL_Regular_1_bal.txt ALL_Regular_1_norm.txt 
        python3 normalize.py ALL_Regular_2_bal.txt ALL_Regular_2_norm.txt 
        python3 normalize.py ALL_Regular_3_bal.txt ALL_Regular_3_norm.txt 
        python3 normalize.py ALL_SemiRegular_1_bal.txt ALL_SemiRegular_1_norm.txt 
        python3 normalize.py ALL_SemiRegular_2_bal.txt ALL_SemiRegular_2_norm.txt 
        python3 normalize.py ALL_SemiRegular_3_bal.txt ALL_SemiRegular_3_norm.txt 
        python3 normalize.py ALL_Irregular_1_bal.txt ALL_Irregular_1_norm.txt 
        python3 normalize.py ALL_Irregular_2_bal.txt ALL_Irregular_2_norm.txt 
        python3 normalize.py ALL_Irregular_3_bal.txt ALL_Irregular_3_norm.txt

    fi
done

echo "Done cutting, balancing, and normalizing data. Use ALL_[gait]_[sensor#]_norm.txt for testing."