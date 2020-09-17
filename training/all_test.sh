#!/bin/bash
# Usage: ./all_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]
# tests every CSV file for RCA and SDA using a trained input model [input_model.h5]
# [directory] is top level dir containing all subject files
# creates results_all.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 5 ]; then
    echo "Usage: ./all_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]"
    exit 1
fi

num=0

echo "Making temp_training_data directory..."
rm -r temp_training_data
mkdir temp_training_data

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        rm -r temp_training_data/*
        ((num++))

        # cut sensor files in each directory
        ./$2 $3 $4 $d"/Regular/Sensor01.csv" $d"/Regular/steps.txt" >> temp_training_data/sensor01_regular.txt
        ./$2 $3 $4 $d"/Regular/Sensor02.csv" $d"/Regular/steps.txt" >> temp_training_data/sensor02_regular.txt
        ./$2 $3 $4 $d"/Regular/Sensor02.csv" $d"/Regular/steps.txt" >> temp_training_data/sensor03_regular.txt
        ./$2 $3 $4 $d"/Irregular/Sensor01.csv" $d"/Irregular/steps.txt" >> temp_training_data/sensor01_irregular.txt
        ./$2 $3 $4 $d"/Irregular/Sensor02.csv" $d"/Irregular/steps.txt" >> temp_training_data/sensor02_irregular.txt
        ./$2 $3 $4 $d"/Irregular/Sensor03.csv" $d"/Irregular/steps.txt" >> temp_training_data/sensor03_irregular.txt
        ./$2 $3 $4 $d"/SemiRegular/Sensor01.csv" $d"/SemiRegular/steps.txt" >> temp_training_data/sensor01_semiregular.txt
        ./$2 $3 $4 $d"/SemiRegular/Sensor02.csv" $d"/SemiRegular/steps.txt" >> temp_training_data/sensor02_semiregular.txt
        ./$2 $3 $4 $d"/SemiRegular/Sensor03.csv" $d"/SemiRegular/steps.txt" >> temp_training_data/sensor03_semiregular.txt

        # train sensor files in each directory
        python3 test_model.py $5 $3 temp_training_data/sensor01_regular.txt $d"/Regular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor02_regular.txt $d"/Regular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor03_regular.txt $d"/Regular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor01_irregular.txt $d"/Irregular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor02_irregular.txt $d"/Irregular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor03_irregular.txt $d"/Irregular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor01_semiregular.txt $d"/SemiRegular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor02_semiregular.txt $d"/SemiRegular/steps.txt" >> results_all.txt
        python3 test_model.py $5 $3 temp_training_data/sensor03_semiregular.txt $d"/SemiRegular/steps.txt" >> results_all.txt
    fi
done

echo "$((num)) directories tested."