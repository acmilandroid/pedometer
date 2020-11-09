#!/bin/bash
# Basil Lin
# Step counter project
# Tests every {gait, sensor} pair CSV file for RCA and SDA using corresponding trained model
# Tests multiple folds of data
# Usage: ./kfold_test.sh [data/cutnorm_windowsize] [models/models_windowsize] [PedometerData] [output_file.csv]
# [data/cutnorm_windowsize] is top level dir containing cut and normalized data files for a specific window size
# [models/models_windowsize] is top level dir containing trained models for a specific window size
# [PedometerData] is top level dir containing all subject files (raw data)
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 5 ]; then
	echo "Usage: ./kfold_test.sh [data/cutnorm_windowsize] [models/models_windowsize] [PedometerData] [num_folds] [output_file.csv]"
	exit 1
fi

# remove old training data
rm -r temp_kfold_test_data
mkdir temp_kfold_test_data

window_size=$(echo $1 | tail -c 3)

# loop through all folds to test
for (( fold=1; fold<=$4; fold++ )); do

	echo "Testing fold number $fold..."
	num=0

	# loop through each subject to test
	for d in $3*; do
		if [ -d "$d" ]; then
			echo "$d"
			((num++))
			# test models (some subjects will be withheld test group results, depending on fold)
			for (( sensor=1; sensor<=3; sensor++ )); do
				echo "Testing $2/trainingfold"$fold"_Regular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2/trainingfold"$fold"_Regular_"$sensor"_"$window_size"_model.h5 $window_size $1/"$num"_Regular_"$sensor"_norm.txt $d/Regular/steps.txt 0 >> temp_kfold_test_data/test_results_$fold.txt
				echo "Testing $2/trainingfold"$fold"_SemiRegular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2/trainingfold"$fold"_SemiRegular_"$sensor"_"$window_size"_model.h5 $window_size $1/"$num"_SemiRegular_"$sensor"_norm.txt $d/SemiRegular/steps.txt 0 >> temp_kfold_test_data/test_results_$fold.txt
				echo "Testing $2/trainingfold"$fold"_Irregular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2/trainingfold"$fold"_Irregular_"$sensor"_"$window_size"_model.h5 $window_size $1/"$num"_Irregular_"$sensor"_norm.txt $d/Irregular/steps.txt 0 >> temp_kfold_test_data/test_results_$fold.txt
			done
		fi
	done

	# grab important result data and make temp file
	pcregrep -M "Predicted steps:.*\nActual steps:.*\nDifference in steps:.*\nTP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRCA:.*\nSDA:.*" temp_kfold_test_data/test_results_$fold.txt | sed 's/^.*: //' > temp_kfold_test_data/important_results_$fold.txt

done

# write data to csv file
echo "Test fold number,Subject,Gait,Sensor,Predicted,Actual,Difference,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $5
for (( fold=1; fold<=$4; fold++ )); do

	line=0

	for (( subject = 0; subject < $num; subject++ )) do

		((print = subject + 1 ))
		echo "Subject $print"
		
		for (( sensornum = 0; sensornum < 3; sensornum++ )) do

			# get line index
			((line = 90 * $subject + 30 * $sensornum))

			# regular sensor data
			echo -n "$fold," >> $5
			((print = subject + 1 ))
			echo -n "$print," >> $5
			echo -n "regular," >> $5
			((print = sensornum + 1 ))
			echo -n "$print," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5

			# semiregular sensor data
			echo -n "$fold," >> $5
			((print = subject + 1 ))
			echo -n "$print," >> $5
			echo -n "semiregular," >> $5
			((print = sensornum + 1 ))
			echo -n "$print," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5

			# irregular sensor data
			echo -n "$fold," >> $5
			((print = subject + 1 ))
			echo -n "$print," >> $5
			echo -n "irregular," >> $5
			((print = sensornum + 1 ))
			echo -n "$print," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5
			truncate -s -1 $5
			echo -n "," >> $5
			((line++))
			sed "${line}q;d" temp_kfold_test_data/important_results_$fold.txt >> $5

		done
	done
done

rm -r temp_kfold_test_data

echo "$((num)) subjects tested."