#!/bin/bash
# Basil Lin
# Step counter project
# Tests every {gait, sensor} pair CSV file for RCA and SDA using 1 trained model on all data
# Usage: ./big_test.sh [data] [model_directory] [PedometerData] [output_file.csv]
# [data] is top level dir containing cut and normalized data files
# [model_directory] is top level dir containing trained models
# [PedometerData] is top level dir containing all subject files (raw data)
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 4 ]; then
	echo "Usage: ./big_test.sh [data] [model_directory] [PedometerData] [output_file.csv]"
	exit 1
fi

# remove old training data
rm -r temp_big_test_data
mkdir temp_big_test_data

num=0

# loop through each subject to test
for d in $3*; do
	if [ -d "$d" ]; then
		echo "$d"
		((num++))
		# test models (25-30 will be withheld test group results)
		for (( sensor=1; sensor<=3; sensor++ )); do
			echo "Testing Regular gait, sensor $sensor..."
			python3 ../training/test_model.py $2/training75_ALL_ALL_model.h5 75 $1/cutnorm_"75"/"$num"_Regular_"$sensor"_norm.txt $d/Regular/steps.txt 0 >> temp_big_test_data/test_results.txt
			echo "Testing SemiRegular gait, sensor $sensor..."
			python3 ../training/test_model.py $2/training75_ALL_ALL_model.h5 75 $1/cutnorm_"75"/"$num"_SemiRegular_"$sensor"_norm.txt $d/SemiRegular/steps.txt 0 >> temp_big_test_data/test_results.txt
			echo "Testing Irregular gait, sensor $sensor..."
			python3 ../training/test_model.py $2/training75_ALL_ALL_model.h5 75 $1/cutnorm_"75"/"$num"_Irregular_"$sensor"_norm.txt $d/Irregular/steps.txt 0 >> temp_big_test_data/test_results.txt
		done
	fi
done

# grab important result data and make temp file
pcregrep -M "Predicted steps:.*\nActual steps:.*\nDifference in steps:.*\nTP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRCA:.*\nSDA:.*" temp_big_test_data/test_results.txt | sed 's/^.*: //' > temp_big_test_data/important_results.txt

# write data to csv file
echo "Window size,Subject,Gait,Sensor,Predicted,Actual,Difference,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $4

line=0

for (( subject = 0; subject < $num; subject++ )) do

	((print = subject + 1 ))
	echo "Subject $print"
	
	for (( sensornum = 0; sensornum < 3; sensornum++ )) do

		# get line index
		((line = 90 * $subject + 30 * $sensornum))

		# regular sensor data
		echo -n "75," >> $4
		((print = subject + 1 ))
		echo -n "$print," >> $4
		echo -n "regular," >> $4
		((print = sensornum + 1 ))
		echo -n "$print," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4

		# semiregular sensor data
		echo -n "75," >> $4
		((print = subject + 1 ))
		echo -n "$print," >> $4
		echo -n "semiregular," >> $4
		((print = sensornum + 1 ))
		echo -n "$print," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4

		# irregular sensor data
		echo -n "75," >> $4
		((print = subject + 1 ))
		echo -n "$print," >> $4
		echo -n "irregular," >> $4
		((print = sensornum + 1 ))
		echo -n "$print," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4
		truncate -s -1 $4
		echo -n "," >> $4
		((line++))
		sed "${line}q;d" temp_big_test_data/important_results.txt >> $4

	done
done

rm -r temp_big_test_data

echo "$((num)) subjects tested."