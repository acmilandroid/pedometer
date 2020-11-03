#!/bin/bash
# Basil Lin
# Step counter project
# Tests every {gait, sensor} pair CSV file for RCA and SDA using a single trained input model [input_model.h5]
# Tests multiple window sizes
# Usage: ./1_test.sh [data_directory] [modedl.h5] [groundtruth_directory] [output_file.csv]
# [data_directory] is top level dir containing cut and normalized data files
# [model_directory] is top level dir containing trained models
# [groundtruth_directory] is top level dir containing all subject files (raw data)
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

WINDOW_START=15			# start size of window in datum
WINDOW_END=150			# end size of window in datum
WINDOW_INCREMENT=15		# increment of window in datum

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 4 ]; then
	echo "Usage: ./1_test.sh [data_directory] [modedl.h5] [groundtruth_directory] [output_file.csv]"
	exit 1
fi

# remove old training data
rm -r temp_data_1test
mkdir temp_data_1test

# loop through all window sizes to test
for (( window_size=$WINDOW_START; window_size<=$WINDOW_END; window_size+=$WINDOW_INCREMENT )); do

	echo "Testing window size of $window_size..."
	num=0

	# loop through each subject to test
	for d in $3*; do
		if [ -d "$d" ]; then
			echo "$d"
			((num++))
			# test models (25-30 will be withheld test group results)
			for (( sensor=1; sensor<=3; sensor++ )); do
				echo "Testing $2/training_Regular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$num"_Regular_"$sensor"_cutnorm.txt $d/Regular/steps.txt 0 >> temp_data_1model/test_results_$window_size.txt
				echo "Testing $2/training_SemiRegular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$num"_Regular_"$sensor"_cutnorm.txt $d/Regular/steps.txt 0 >> temp_data_1model/test_results_$window_size.txt
				echo "Testing $2/training_Irregular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$num"_Regular_"$sensor"_cutnorm.txt $d/Regular/steps.txt 0 >> temp_data_1model/test_results_$window_size.txt
			done
		fi
	done

	# grab important result data and make temp file
	pcregrep -M "Predicted steps:.*\nActual steps:.*\nDifference in steps:.*\nTP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRCA:.*\nSDA:.*" temp_data/test_results_$window_size.txt | sed 's/^.*: //' > temp_data/important_results_$window_size.txt

done

# write data to csv file
echo "Window size,Subject,Gait,Sensor,Predicted,Actual,Difference,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $4
for (( window_size=$WINDOW_START; window_size<=$WINDOW_END; window_size+=$WINDOW_INCREMENT )); do

	line=0

	for (( subject = 0; subject < $num; subject++ )) do

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

rm -r temp_data_1test

echo "$((num)) subjects tested."