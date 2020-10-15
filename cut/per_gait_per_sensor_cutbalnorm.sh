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

# cut data
echo "cutting data..."
./sensorXcut.sh $d $2 $3 Regular 1 &> /dev/null
./sensorXcut.sh $d $2 $3 Regular 2 &> /dev/null
./sensorXcut.sh $d $2 $3 Regular 3 &> /dev/null
./sensorXcut.sh $d $2 $3 SemiRegular 1 &> /dev/null
./sensorXcut.sh $d $2 $3 SemiRegular 2 &> /dev/null
./sensorXcut.sh $d $2 $3 SemiRegular 3 &> /dev/null
./sensorXcut.sh $d $2 $3 Irregular 1 &> /dev/null
./sensorXcut.sh $d $2 $3 Irregular 2 &> /dev/null
./sensorXcut.sh $d $2 $3 Irregular 3 &> /dev/null

# balance data
echo "balancing data..."
python3 balance_data.py ALL_Regular_1_cut.txt ALL_Regular_1_bal.txt &> /dev/null
python3 balance_data.py ALL_Regular_2_cut.txt ALL_Regular_2_bal.txt &> /dev/null
python3 balance_data.py ALL_Regular_3_cut.txt ALL_Regular_3_bal.txt &> /dev/null
python3 balance_data.py ALL_SemiRegular_1_cut.txt ALL_SemiRegular_1_bal.txt &> /dev/null
python3 balance_data.py ALL_SemiRegular_2_cut.txt ALL_SemiRegular_2_bal.txt &> /dev/null
python3 balance_data.py ALL_SemiRegular_3_cut.txt ALL_SemiRegular_3_bal.txt &> /dev/null
python3 balance_data.py ALL_Irregular_1_cut.txt ALL_Irregular_1_bal.txt &> /dev/null
python3 balance_data.py ALL_Irregular_2_cut.txt ALL_Irregular_2_bal.txt &> /dev/null
python3 balance_data.py ALL_Irregular_3_cut.txt ALL_Irregular_3_bal.tx &> /dev/null

# normalize data
echo "normalizing data..."
python3 normalize.py ALL_Regular_1_bal.txt ALL_Regular_1_norm.txt 0 1 &> /dev/null
python3 normalize.py ALL_Regular_2_bal.txt ALL_Regular_2_norm.txt 0 2 &> /dev/null
python3 normalize.py ALL_Regular_3_bal.txt ALL_Regular_3_norm.txt 0 3 &> /dev/null
python3 normalize.py ALL_SemiRegular_1_bal.txt ALL_SemiRegular_1_norm.txt 0 1 &> /dev/null
python3 normalize.py ALL_SemiRegular_2_bal.txt ALL_SemiRegular_2_norm.txt 0 2 &> /dev/null
python3 normalize.py ALL_SemiRegular_3_bal.txt ALL_SemiRegular_3_norm.txt 0 3 &> /dev/null
python3 normalize.py ALL_Irregular_1_bal.txt ALL_Irregular_1_norm.txt 0 1 &> /dev/null
python3 normalize.py ALL_Irregular_2_bal.txt ALL_Irregular_2_norm.txt 0 2 &> /dev/null
python3 normalize.py ALL_Irregular_3_bal.txt ALL_Irregular_3_norm.txt 0 3 &> /dev/null


echo "Done cutting, balancing, and normalizing data. Use ALL_[gait]_[sensor#]_norm.txt for testing."