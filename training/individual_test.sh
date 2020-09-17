#!/bin/bash
# Usage: ./individual_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]
# [directory] is top level dir containing all subject files
# if [gait] is not Regular, Irregular, or SemiRegular, it will combine all gaits
# combines and all csv files of a single sensor type
# creates sensor0[#]_cut.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 6 ]; then
    echo "Usage: ./individual_test.sh [directory] [cutsteps_executable] [window_size] [window_stride] [input_model.h5]"
    exit 1
fi

num=0

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        rm -rf temp_training_data
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
        python3 test_model.py $5 $3 "temp_training_data/sensor01_regular.txt" $d"/Regular/steps.txt"
    fi
done

echo "$((num)) csv files cut for step windows."