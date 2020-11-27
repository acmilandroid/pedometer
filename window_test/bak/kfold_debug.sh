#!/bin/bash
# Basil Lin
# Step counter project
# Tests every {gait, sensor} pair CSV file for RCA and SDA using corresponding trained model
# Tests multiple folds of data
# Usage: ./kfold_test.sh [data/cutnorm_windowsize] [models/models_windowsize/] [PedometerData] [window_size] [output_file.csv]
# [data/cutnorm_windowsize] is top level dir containing cut and normalized data files for a specific window size
# [data/cutnorm_windowsize] CANNOT CONTAIN TRAILING / ON DIR!!!
# [models/models_windowsize] is top level dir containing trained models for a specific window size
# [PedometerData] is top level dir containing all subject files (raw data)
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 6 ]; then
	echo "Usage: ./kfold_test.sh [data/cutnorm_windowsize] [models/models_windowsize] [PedometerData] [num_folds] [window_size] [output_file.csv]"
	exit 1
fi

# remove old training data
rm -r temp_kfold_test_data_"$5"
mkdir temp_kfold_test_data_"$5"

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
				echo "Testing $2/trainingfold"$fold"_Regular_"$sensor"_"$5"_model.h5"
				python3 ../training/test_model.py $2/trainingfold"$fold"_Regular_"$sensor"_"$5"_model.h5 $5 $1/"$num"_Regular_"$sensor"_norm.txt $d/Regular/steps.txt 0 >> temp_kfold_test_data_"$5"/test_results_$fold.txt
				echo "Testing $2/trainingfold"$fold"_SemiRegular_"$sensor"_"$5"_model.h5"
				python3 ../training/test_model.py $2/trainingfold"$fold"_SemiRegular_"$sensor"_"$5"_model.h5 $5 $1/"$num"_SemiRegular_"$sensor"_norm.txt $d/SemiRegular/steps.txt 0 >> temp_kfold_test_data_"$5"/test_results_$fold.txt
				echo "Testing $2/trainingfold"$fold"_Irregular_"$sensor"_"$5"_model.h5"
				python3 ../training/test_model.py $2/trainingfold"$fold"_Irregular_"$sensor"_"$5"_model.h5 $5 $1/"$num"_Irregular_"$sensor"_norm.txt $d/Irregular/steps.txt 0 >> temp_kfold_test_data_"$5"/test_results_$fold.txt
			done
		fi
	done

	# grab important result data and make temp file
	pcregrep -M "Predicted steps:.*\nActual steps:.*\nDifference in steps:.*\nTP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRCA:.*\nSDA:.*" temp_kfold_test_data_"$5"/test_results_$fold.txt | sed 's/^.*: //' > temp_kfold_test_data_"$5"/important_results_$fold.txt

done

# write data to csv file
echo "Test fold number,Subject,Gait,Sensor,Predicted,Actual,Difference,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $6
for (( fold=1; fold<=$4; fold++ )); do

	line=0

	for (( subject = 0; subject < $num; subject++ )) do

		((print = subject + 1 ))
		echo "Subject $print"
		
		for (( sensornum = 0; sensornum < 3; sensornum++ )) do

			# get line index
			((line = 90 * $subject + 30 * $sensornum))

			# regular sensor data
			echo -n "$fold," >> $6
			((print = subject + 1 ))
			echo -n "$print," >> $6
			echo -n "regular," >> $6
			((print = sensornum + 1 ))
			echo -n "$print," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6

			# semiregular sensor data
			echo -n "$fold," >> $6
			((print = subject + 1 ))
			echo -n "$print," >> $6
			echo -n "semiregular," >> $6
			((print = sensornum + 1 ))
			echo -n "$print," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6

			# irregular sensor data
			echo -n "$fold," >> $6
			((print = subject + 1 ))
			echo -n "$print," >> $6
			echo -n "irregular," >> $6
			((print = sensornum + 1 ))
			echo -n "$print," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6
			truncate -s -1 $6
			echo -n "," >> $6
			((line++))
			sed "${line}q;d" temp_kfold_test_data_"$5"/important_results_$fold.txt >> $6

		done
	done
done

rm -r temp_kfold_test_data_"$5"

echo "$((num)) subjects tested."