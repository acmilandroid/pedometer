#!/bin/bash
# Basil Lin
# Step counter project
# Tests every {gait, sensor} pair CSV file for RCA and SDA using corresponding trained model
# Tests multiple window sizes
# Usage: ./9_test.sh [data_directory] [model_directory] [groundtruth_directory] [output_file.csv]
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
	echo "Usage: ./9_test.sh [data_directory] [model_directory] [groundtruth_directory] [output_file.csv]"
	exit 1
fi

# remove old training data
rm -r temp_data
mkdir temp_data

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
				python3 ../training/test_model.py $2/training_Regular_"$sensor"_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$num"_Regular_"$sensor"_cutnorm.txt $d/Regular/steps.txt 0 >> temp_data/test_results_$window_size.txt
				echo "Testing $2/training_SemiRegular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2/training_SemiRegular_"$sensor"_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$num"_SemiRegular_"$sensor"_cutnorm.txt $d/SemiRegular/steps.txt 0 >> temp_data/test_results_$window_size.txt
				echo "Testing $2/training_Irregular_"$sensor"_"$window_size"_model.h5"
				python3 ../training/test_model.py $2/training_Irregular_"$sensor"_"$window_size"_model.h5 $window_size $1/cutnorm_"$window_size"/"$num"_Irregular_"$sensor"_cutnorm.txt $d/Irregular/steps.txt 0 >> temp_data/test_results_$window_size.txt
			done
		fi
	done

	# grab important result data and make temp file
	pcregrep -M "TP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRun count accuracy:.*\nStep detection accuracy F1 Score:.*" temp_data/test_results_$window_size.txt | sed 's/^.*: //' > temp_data/important_results_$window_size.txt

done

# write data to csv file
echo "Window size,Subject,Gait,Sensor,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $4
for (( window_size=$WINDOW_START; window_size<=$WINDOW_END; window_size+=$WINDOW_INCREMENT )); do

	line=0

	for (( i = 0; i < $num; i++ )) do

		((print = i + 1 ))
		echo "Subject $print"
		
		for (( j = 0; j < 3; j++ )) do

			# get line index
			((line = 63 * $i + 21 * $j))

			# regular sensor data
			echo -n "$window_size," >> $4
			((print = i + 1 ))
			echo -n "$print," >> $4
			echo -n "regular," >> $4
			((print = j + 1 ))
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

			# semiregular sensor data
			echo -n "$window_size," >> $4
			((print = i + 1 ))
			echo -n "$print," >> $4
			echo -n "semiregular," >> $4
			((print = j + 1 ))
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

			# irregular sensor data
			echo -n "$window_size," >> $4
			((print = i + 1 ))
			echo -n "$print," >> $4
			echo -n "irregular," >> $4
			((print = j + 1 ))
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

		done
	done
done

rm -r temp_data

echo "$((num)) subjects tested."