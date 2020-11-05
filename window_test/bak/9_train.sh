#!/bin/bash
# Basil Lin
# Step counter project
# Script to train a 9 {Gait, sensor} models for a window size
# Usage: ./9_train.sh [data_directory] [window_size] [window_stride]
# [data_directory] is top level dir containing cut and normalized data files
# [window_size_start] [window_size_end] are in datum, not seconds!
# creates training_Irregular_[sensor #]_[window_size]_model.h5

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
	echo "Usage: ./9_train.sh [data_directory] [window_size] [window_stride]"
	exit 1
fi

# create directory for data
mkdir models

echo ".........................TESTING WINDOW SIZE OF $2........................."

# train models and get result
echo "training models..."

# train models
for ((sensor=1; sensor<=3; sensor++)); do

	echo "training {Regular, Sensor0$sensor}..."
	python3 ../training/train_model.py $1/cutnorm_$2/training_Regular_"$sensor"_norm.txt $2 $3 ../window_test/models/training_Regular_"$sensor"_"$2"_model.h5

	echo "training {SemiRegular, Sensor0$sensor}..."
	python3 ../training/train_model.py $1/cutnorm_$2/training_SemiRegular_"$sensor"_norm.txt $2 $3 ../window_test/models/training_SemiRegular_"$sensor"_"$2"_model.h5

	echo "training {Irregular, Sensor0$sensor}..."
	python3 ../training/train_model.py $1/cutnorm_$2/training_Irregular_"$sensor"_norm.txt $2 $3 ../window_test/models/training_Irregular_"$sensor"_"$2"_model.h5

done
