#!/bin/bash
# Basil Lin
# Step counter project
# Script to test models for RCA and SDA
# Usage: ./rca_sda_test.sh [data_directory] [model_directory] [window_size] [window_stride]
# [data_directory] is top level dir containing all cut and normalized subject data files for testing
# [model_directory] is top level dir containing trained models to test
# requires cut and normalized individual subject files

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 4 ]; then
	echo "Usage: ./rca_sda_test.sh [data_directory] [window_size] [window_stride]"
	exit 1
fi

# create result CSV file
echo "Window size,Gait,Sensor #,Training predicted steps,Training actual steps,Training difference,Training RCA,Training SDA,Testing predicted steps,Testing actual steps,Testing difference,Testing RCA,Testing SDA" > ../window_test/ALL_ALL_ALL_rca_sda.csv

# train models and get result
echo "testing models..."
cd ../training/

num=0

# train models
for ((sensor=1; sensor<=3; sensor++)); do

	echo "training {Regular, Sensor0$sensor}..."

	python3 train_model.py ../data/cutnorm/cutnorm_$2/training_Regular_"$sensor"_cutnorm.txt $2 $3 ../window_test/models/training_Regular_"$sensor"_"$2"_model.h5 > ../data/cutnorm/cutnorm_$2/training_Regular_"$sensor"_"$2"_results.txt
	pcregrep -M "Training predicted steps:.*\nTraining actual steps:.*\nTraining difference in steps:.*\nTraining RCA:.*\nTesting predicted steps:.*\nTesting actual steps:.*\nTesting difference in steps:.*\nTesting RCA:.*" ../data/cutnorm/cutnorm_$2/training_Regular_"$sensor"_"$2"_results.txt | sed 's/^.*: //' > ../data/cutnorm/cutnorm_$2/training_Regular_"$sensor"_"$2"_important.txt
	echo -n "$2," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	echo -n "Regular," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	echo -n "$sensor," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	for ((line=1; line<=8; line++)); do
		sed "${line}q;d" ../data/cutnorm/cutnorm_$2/training_Regular_"$sensor"_"$2"_important.txt >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
		truncate -s -1 ../window_test/ALL_ALL_ALL_training_results_$2.csv
		echo -n "," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	done
	echo "" >> ../window_test/ALL_ALL_ALL_training_results_$2.csv

	echo "training {SemiRegular, Sensor0$sensor}..."

	python3 train_model.py ../data/cutnorm/cutnorm_$2/training_SemiRegular_"$sensor"_cutnorm.txt $2 $3 ../window_test/models/training_SemiRegular_"$sensor"_"$2"_model.h5 > ../data/cutnorm/cutnorm_$2/training_SemiRegular_"$sensor"_"$2"_results.txt
	pcregrep -M "Training predicted steps:.*\nTraining actual steps:.*\nTraining difference in steps:.*\nTraining RCA:.*\nTesting predicted steps:.*\nTesting actual steps:.*\nTesting difference in steps:.*\nTesting RCA:.*" ../data/cutnorm/cutnorm_$2/training_SemiRegular_"$sensor"_"$2"_results.txt | sed 's/^.*: //' > ../data/cutnorm/cutnorm_$2/training_SemiRegular_"$sensor"_"$2"_important.txt
	echo -n "$2," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	echo -n "SemiRegular," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	echo -n "$sensor," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	for ((line=1; line<=8; line++)); do
		sed "${line}q;d" ../data/cutnorm/cutnorm_$2/training_SemiRegular_"$sensor"_"$2"_important.txt >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
		truncate -s -1 ../window_test/ALL_ALL_ALL_training_results_$2.csv
		echo -n "," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	done
	echo "" >> ../window_test/ALL_ALL_ALL_training_results_$2.csv

	echo "training {Irregular, Sensor0$sensor}..."

	python3 train_model.py ../data/cutnorm/cutnorm_$2/training_Irregular_"$sensor"_cutnorm.txt $2 $3 ../window_test/models/training_Irregular_"$sensor"_"$2"_model.h5 > ../data/cutnorm/cutnorm_$2/training_Irregular_"$sensor"_"$2"_results.txt
	pcregrep -M "Training predicted steps:.*\nTraining actual steps:.*\nTraining difference in steps:.*\nTraining RCA:.*\nTesting predicted steps:.*\nTesting actual steps:.*\nTesting difference in steps:.*\nTesting RCA:.*" ../data/cutnorm/cutnorm_$2/training_Irregular_"$sensor"_"$2"_results.txt | sed 's/^.*: //' > ../data/cutnorm/cutnorm_$2/training_Irregular_"$sensor"_"$2"_important.txt
	echo -n "$2," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	echo -n "Irregular," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	echo -n "$sensor," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	for ((line=1; line<=8; line++)); do
		sed "${line}q;d" ../data/cutnorm/cutnorm_$2/training_Irregular_"$sensor"_"$2"_important.txt >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
		truncate -s -1 ../window_test/ALL_ALL_ALL_training_results_$2.csv
		echo -n "," >> ../window_test/ALL_ALL_ALL_training_results_$2.csv
	done
	echo "" >> ../window_test/ALL_ALL_ALL_training_results_$2.csv

done
