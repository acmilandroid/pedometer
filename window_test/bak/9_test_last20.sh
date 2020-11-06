#!/bin/bash
# Basil Lin
# Step counter project
# Test last 20% of subjects for results on models trained on first 80% of subjects
# Tests multiple window sizes
# Usage: ./9_test.sh [data] [model_directory] [PedometerData] [output_file.csv]
# [data] is top level dir containing cut and normalized data files
# [model_directory] is top level dir containing trained models
# [PedometerData] is top level dir containing all subject files (raw data)
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

# THIS FILE IS DEPRECRATED AND HAS BUGS AT CSV FILE PROCESSING STAGE

WINDOW_START=15			# start size of window in datum
WINDOW_END=30			# end size of window in datum
WINDOW_INCREMENT=15		# increment of window in datum
FOLD_START=2			# testing fold starting subject #
FOLD_END=2				# testing fold ending subject #

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 4 ]; then
	echo "Usage: ./9_test.sh [data] [model_directory] [PedometerData] [output_file.csv]"
	exit 1
fi

# remove old training data
rm -r temp_data
mkdir temp_data

# loop through all window sizes to test
for (( window_size=$WINDOW_START; window_size<=$WINDOW_END; window_size+=$WINDOW_INCREMENT )); do

	echo "Testing window size of $window_size..."

	# loop through each subject in last 20% to test
	for ((subject=$FOLD_START; subject<=$FOLD_END; subject++)); do
		# create P0xx directory name
		if (($subject < 10)); then
			d="$3/P00$subject"
		else
			d="$3/P0$subject"
		fi
		# test models (25-30 will be withheld test group results)
		for (( sensor=1; sensor<=3; sensor++ )); do
			echo "Testing $2/models_$window_size/trainingfold5_Regular_"$sensor"_"$window_size"_model.h5"
			python3 ../training/test_model.py $2/models_$window_size/trainingfold5_Regular_"$sensor"_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$subject"_Regular_"$sensor"_norm.txt $d/Regular/steps.txt 0 >> temp_data/test_results_$window_size.txt
			echo "Testing $2/models_$window_size/trainingfold5_SemiRegular_"$sensor"_"$window_size"_model.h5"
			python3 ../training/test_model.py $2/models_$window_size/trainingfold5_SemiRegular_"$sensor"_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$subject"_SemiRegular_"$sensor"_norm.txt $d/SemiRegular/steps.txt 0 >> temp_data/test_results_$window_size.txt
			echo "Testing $2/models_$window_size/trainingfold5_Irregular_"$sensor"_"$window_size"_model.h5"
			python3 ../training/test_model.py $2/models_$window_size/trainingfold5_Irregular_"$sensor"_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$subject"_Irregular_"$sensor"_norm.txt $d/Irregular/steps.txt 0 >> temp_data/test_results_$window_size.txt
		done
	done

	# grab important result data and make temp file
	pcregrep -M "Predicted steps:.*\nActual steps:.*\nDifference in steps:.*\nTP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRCA:.*\nSDA:.*" temp_data/test_results_$window_size.txt | sed 's/^.*: //' > temp_data/important_results_$window_size.txt

done

# write data to csv file
echo "Window size,Subject,Gait,Sensor,Predicted,Actual,Difference,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $4
for (( window_size=$WINDOW_START; window_size<=$WINDOW_END; window_size+=$WINDOW_INCREMENT )); do

	line=0

	for (( subject = $FOLD_START; subject < $subject; subject++ )) do

		((print = subject + 1 ))
		echo "Subject $print"
		
		for (( sensornum = 0; sensornum < 3; sensornum++ )) do

			# get line index
			((line = 90 * $subject + 30 * $sensornum))

			# regular sensor data
			echo -n "$window_size," >> $4
			((print = subject + 1 ))
			echo -n "$print," >> $4
			echo -n "regular," >> $4
			((print = sensornum + 1 ))
			echo -n "$print," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4

			# semiregular sensor data
			echo -n "$window_size," >> $4
			((print = subject + 1 ))
			echo -n "$print," >> $4
			echo -n "semiregular," >> $4
			((print = sensornum + 1 ))
			echo -n "$print," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4

			# irregular sensor data
			echo -n "$window_size," >> $4
			((print = subject + 1 ))
			echo -n "$print," >> $4
			echo -n "irregular," >> $4
			((print = sensornum + 1 ))
			echo -n "$print," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4
			truncate -s -1 $4
			echo -n "," >> $4
			((line++))
			sed "${line}q;d" temp_data/important_results_$window_size.txt >> $4

		done
	done
done

rm -r temp_data

echo "$((num)) subjects tested."