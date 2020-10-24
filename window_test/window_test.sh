#!/bin/bash
# Basil Lin
# Step counter project
# Script to test window sizes for best RCA/SDA
# Usage: ./window_test.sh [directory] [window_size_start] [window_size_end] [window_stride]
# [directory] is top level dir containing all subject files
# [window_size_start] [window_size_end] are in datum, not seconds!
# creates ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_cut.txt ALL_[gait]_[sensor#]_cutnorm.txt

# increment window size by 1 second during test
INCREMENT=15

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 4 ]; then
    echo "Usage: ./window_test.sh [directory] [window_size_start] [window_size_end] [window_stride]"
    exit 1
fi

# remove old data
echo "removing old data..."
rm -r temp_training_data &> /dev/null
rm ALL* &> /dev/null

# create directory for data
mkdir temp_training_data

# compile cutsteps.c
cd ../cut/
make clean &> /dev/null
make &> /dev/null

# loop through iterations of windows
for ((windowsize=$2; windowsize<=$3; windowsize+=$INCREMENT)); do

    echo ".........................TESTING WINDOW SIZE OF $windowsize........................."
    cd ../window_test/
    rm -r temp_training_data/* &> /dev/null

    # create data
    echo "cutting and normalizing data..."
    cd ../cut/
    ./9_cutnorm.sh $1 $windowsize $4 &> /dev/null
    mv *_cut.txt ../window_test/temp_training_data/
    mv *_cutnorm.txt ../window_test/temp_training_data/

    # train models
    echo "training models..."
    cd ../training/
    for ((sensor=1; sensor<=3; sensor++)); do
        echo "training Sensor0$sensor..."
        python3 train_model.py ../window_test/temp_training_data/ALL_Regular_"$sensor"_cutnorm.txt $windowsize $4 ../window_test/temp_training_data/ALL_Regular_"$sensor"_model.h5
        python3 train_model.py ../window_test/temp_training_data/ALL_SemiRegular_"$sensor"_cutnorm.txt $windowsize $4 ../window_test/temp_training_data/ALL_SemiRegular_"$sensor"_model.h5
        python3 train_model.py ../window_test/temp_training_data/ALL_Irregular_"$sensor"_cutnorm.txt $windowsize $4 ../window_test/temp_training_data/ALL_Irregular_"$sensor"_model.h5
    done

    # test all data
    echo "testing all models..."
    ./9_test.sh $1 $windowsize $4 ../window_test/temp_training_data/ 0 ../window_test/ALL_ALL_ALL_9GaitSensor_results_windowsize"$windowsize".csv

done

# cleanup
# echo "cleaning up temp files..."
# cd ../window_test/
# rm -r temp_training_data &> /dev/null