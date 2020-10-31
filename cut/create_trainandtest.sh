#!/bin/bash
# Basil Lin
# Uses cutnorm data and create testing and training files
# Usage: ./create_trainandtest.sh [directory] [num_folds] [fold_num]
# [directory] is top level dir containing all cut and normalized subject data files for testing
# [num_folds] is the total number of folds for the test
# [fold_num] is the fold number to cut for testing. Smaller folds are earlier data

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "Usage: ./create_trainandtest.sh [directory] [num_folds] [fold_num]"
    exit 1
fi

# remove old files
echo "Removing old files..."
for ((sensor=1; sensor<=3; sensor++)); do
	rm testing_Regular_"$sensor"_cutnorm.txt
	rm testing_SemiRegular_"$sensor"_cutnorm.txt
	rm testing_Irregular_"$sensor"_cutnorm.txt
	rm training_Regular_"$sensor"_cutnorm.txt
	rm training_SemiRegular_"$sensor"_cutnorm.txt
	rm training_Irregular_"$sensor"_cutnorm.txt
done

# get number of subjects in directory
cd $1
subjects=$(ls | wc -l)
(($subject = $subjects / 18))
echo "$subjects subjects in directory $1"

# error handling
if (($subjects%$2 != 0)); then
	echo "Subject count $subjects is not divisible by $2 folds. Choose a new [num_folds]"
	exit 1
fi
if (($3 > $2)); then
	echo "Fold number $3 is greater than $2 total folds. Choose a new [fold_num]."
	exit 1
fi
if (($3 <= 0)); then
	echo "Fold number $3 is less than 1. Choose a new [fold_num]."
	exit 1
fi

# find start and end subjects for withheld testing data
fold_end=$(($subjects/$2*$3))
fold_start=$(($fold_end-$subjects/$2+1))

# create testing data
echo "Creating testing data..."
for ((subject=$fold_start; subject<=$fold_end; subject++)); do
	for ((sensor=1; sensor<=3; sensor++)); do
		cat "$subject"_Regular_"$sensor"_cutnorm.txt >> testing_Regular_"$sensor"_cutnorm.txt
		cat "$subject"_SemiRegular_"$sensor"_cutnorm.txt >> testing_SemiRegular_"$sensor"_cutnorm.txt
		cat "$subject"_Irregular_"$sensor"_cutnorm.txt >> testing_Irregular_"$sensor"_cutnorm.txt
	done
done

# create training data
echo "Creating training data..."
for ((subject=1; subject<=$subjects; subject++)); do
	# if not in the withheld testing subjects
	if (($subject<$fold_start || $subject>$fold_end)); then
		for ((sensor=1; sensor<=3; sensor++)); do
			cat "$subject"_Regular_"$sensor"_cutnorm.txt >> training_Regular_"$sensor"_cutnorm.txt
			cat "$subject"_SemiRegular_"$sensor"_cutnorm.txt >> training_SemiRegular_"$sensor"_cutnorm.txt
			cat "$subject"_Irregular_"$sensor"_cutnorm.txt >> training_Irregular_"$sensor"_cutnorm.txt
		done
	fi
done

echo "Done creating training and testing data files."

