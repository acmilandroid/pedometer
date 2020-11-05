#!/bin/bash
# Basil Lin
# Step counter project
# Script to train a 9 {Gait, sensor} models for a window size given a fold
# Usage: ./kfold_train.sh [data_directory] [window_size] [window_stride] [fold_num]
# [data_directory] is top level dir containing cut and normalized data files
# [window_size_start] [window_size_end] are in datum, not seconds!
# creates training_Irregular_[sensor #]_[window_size]_model.h5

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 4 ]; then
	echo "Usage: ./kfold_train.sh [data_directory] [window_size] [window_stride] [fold_num]"
	exit 1
fi

# create directory for data
mkdir models_"$2" $> /dev/null

echo ".........................TRAINING FOLD $5........................."

# train models
for ((sensor=1; sensor<=3; sensor++)); do

	echo "training {Regular, Sensor0$sensor}..."
	python3 ../training/train_model.py $1/cutnorm_$2/trainingfold$4_Regular_"$sensor"_norm.txt $2 $3 ../window_test/models_$2/trainingfold$4_Regular_"$sensor"_"$2"_model.h5

	echo "training {SemiRegular, Sensor0$sensor}..."
	python3 ../training/train_model.py $1/cutnorm_$2/trainingfold$4_SemiRegular_"$sensor"_norm.txt $2 $3 ../window_test/models_$2/trainingfold$4_SemiRegular_"$sensor"_"$2"_model.h5

	echo "training {Irregular, Sensor0$sensor}..."
	python3 ../training/train_model.py $1/cutnorm_$2/trainingfold$4_Irregular_"$sensor"_norm.txt $2 $3 ../window_test/models_$2/trainingfold$4_Irregular_"$sensor"_"$2"_model.h5

done
