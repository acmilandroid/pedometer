#!/bin/bash
#usage: ./train_kfold.sh [K] [input_file.txt]
#takes input file of all data, creates K number of K_fold data
#trains each K_fold data

echo "Bash version ${BASH_VERSION}"

#check input args
if [ "$#" -ne 2 ]; then
    echo "Usage: ./train_kfold.sh [K] [input_file.txt]"
    exit 1
fi

#check if previous kfold files exist and remove them
if ls kfold_split* 1> /dev/null 2>&1; then
    echo "Removing previous files"
    rm kfold_split*
fi

#create kfold data
echo "Creating K folds..."
python3 kfoldize_data.py $1 $2 > temp_kfold_data/kfold_log.txt

#train each fold
((num=0))
for train_file in ./kfold_split_data*; do
    echo "Training $train_file..."
    python3 train_model.py $train_file >> temp_kfold_data/kfold_log.txt
    mv model.h5 temp_kfold_data/model_$num.h5
    ((num++))
    echo "Done."
done

#test each fold
((num=0))
for test_file in ./kfold_split_test*; do
    echo "Testing $test_file..."
    python3 test_model.py $test_file temp_kfold_data/model_$num.h5 >> temp_kfold_data/kfold_log.txt
    ((num++))
    echo "Done."
done

echo "Removing temporary files..."
rm kfold_split*
echo "Done."

grep "Testing run count accuracy" temp_kfold_data/kfold_log.txt

