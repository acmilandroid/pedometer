#!/bin/bash
# Basil Lin
# Step counter project
# Script to test models for RCA and SDA
# Usage: ./rca_sda_test.sh [directory] [model_directory] [window_size] [window_stride]
# [directory] is top level dir containing all cut and normalized subject data files for testing
# [model_directory] is top level dir containing trained models to test
# requires cut and normalized individual subject files

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 4 ]; then
	echo "Usage: ./rca_sda_test.sh [directory] [model_directory] [window_size] [window_stride]"
	exit 1
fi

# create result CSV file
echo "Window size,Gait,Sensor #,Training predicted steps,Training actual steps,Training difference,Training RCA,Training SDA,Testing predicted steps,Testing actual steps,Testing difference,Testing RCA,Testing SDA" > ../window_test/ALL_ALL_ALL_rca_sda.csv

# train models and get result
echo "testing models..."
cd ../training/

num=0

# test models
# loop through all subdirectories
for d in $1*; do
	if [ -d "$d" ]; then
		echo "$d"
		((num++))

		# test models
		echo "Testing..."
		for ((sensor=1; sensor<=3; sensor++)) do
			echo "Testing Sensor0$sensor"
			python3 test_model.py $4"/ALL_Regular_"$sensor"_model.h5" $2 "temp_testing_data/"$num"_Regular_"$sensor"_norm.txt" $d"/Regular/steps.txt" 0 >> ALL_ALL_ALL_results.txt
			python3 test_model.py $4"/ALL_SemiRegular_"$sensor"_model.h5" $2 "temp_testing_data/"$num"_SemiRegular_"$sensor"_norm.txt" $d"/SemiRegular/steps.txt" 0 >> ALL_ALL_ALL_results.txt
			python3 test_model.py $4"/ALL_Irregular_"$sensor"_model.h5" $2 "temp_testing_data/"$num"_Irregular_"$sensor"_norm.txt" $d"/Irregular/steps.txt" 0 >> ALL_ALL_ALL_results.txt
		done

	fi
done

# grab important result data and make temp file
pcregrep -M "TP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRun count accuracy:.*\nStep detection accuracy F1 Score:.*" ALL_ALL_ALL_results.txt | sed 's/^.*: //' > ALL_ALL_ALL_important.txt

# write data to csv file
line=0
echo "Subject,Gait,Sensor,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $6

for (( i = 0; i < $num; i++ )) do

	((print = i + 1 ))
	echo "Subject $print"

	for (( j = 0; j < 3; j++ )) do

		# get line index
		((line = 63 * $i + 21 * $j))

		# regular sensor data
		((print = i + 1 ))
		echo -n "$print," >> $6
		echo -n "regular," >> $6
		((print = j + 1 ))
		echo -n "$print," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6

		# irregular sensor data
		((print = i + 1 ))
		echo -n "$print," >> $6
		echo -n "irregular," >> $6
		((print = j + 1 ))
		echo -n "$print," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6

		# semiregular sensor data
		((print = i + 1 ))
		echo -n "$print," >> $6
		echo -n "semiregular," >> $6
		((print = j + 1 ))
		echo -n "$print," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
		truncate -s -1 $6
		echo -n "," >> $6
		((line++))
		sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6

	done
done

rm ALL_ALL_ALL_important.txt &> /dev/null
rm ALL_ALL_ALL_results.txt &> /dev/null
rm -r temp_testing_data &> /dev/null

echo "$((num)) subjects tested."