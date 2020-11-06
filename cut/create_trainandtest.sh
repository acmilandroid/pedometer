#!/bin/bash
# Basil Lin
# Uses norm data and create testing and training files
# Usage: ./create_trainandtest.sh [data/cutnorm_windowsize] [num_folds] [fold_num]
# [data/cutnorm_windowsize] is top level dir containing all cut and normalized subject data files
# [num_folds] is the total number of folds for the test
# [fold_num] is the fold number to cut for testing. Smaller folds are earlier data

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "Usage: ./create_trainandtest.sh [data/cutnorm_windowsize] [num_folds] [fold_num]"
    exit 1
fi

# remove old files
cd $1
for ((sensor=1; sensor<=3; sensor++)); do
	rm testingfold$3_Regular_"$sensor"_norm.txt &> /dev/null
	rm testingfold$3_SemiRegular_"$sensor"_norm.txt &> /dev/null
	rm testingfold$3_Irregular_"$sensor"_norm.txt &> /dev/null
	rm trainingfold$3_Regular_"$sensor"_norm.txt &> /dev/null
	rm trainingfold$3_SemiRegular_"$sensor"_norm.txt &> /dev/null
	rm trainingfold$3_Irregular_"$sensor"_norm.txt &> /dev/null
done

# get number of subjects in directory
subjects=$(ls *_1_cut.txt | wc -l)
subjects=$(($subjects / 3))
echo "There are $subjects subjects in directory $1"

# error handling
if (($subjects%$2 != 0)); then
	echo "Subject count $subjects is not divisible by $2 folds. Choose a new [num_folds]"
	exit 1
fi
if (($3 > $2)); then
	echo "Fold number $3 is greater than $2 total folds. Choose a new [fold_num]."
	exit 1
fi
if (($3 < 1)); then
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
		cat "$subject"_Regular_"$sensor"_norm.txt >> testingfold$3_Regular_"$sensor"_norm.txt
		cat "$subject"_SemiRegular_"$sensor"_norm.txt >> testingfold$3_SemiRegular_"$sensor"_norm.txt
		cat "$subject"_Irregular_"$sensor"_norm.txt >> testingfold$3_Irregular_"$sensor"_norm.txt
	done
done

# create training data
echo "Creating training data..."
for ((subject=1; subject<=$subjects; subject++)); do
	# if not in the withheld testingfold$3 subjects
	if (($subject<$fold_start || $subject>$fold_end)); then
		for ((sensor=1; sensor<=3; sensor++)); do
			cat "$subject"_Regular_"$sensor"_norm.txt >> trainingfold$3_Regular_"$sensor"_norm.txt
			cat "$subject"_SemiRegular_"$sensor"_norm.txt >> trainingfold$3_SemiRegular_"$sensor"_norm.txt
			cat "$subject"_Irregular_"$sensor"_norm.txt >> trainingfold$3_Irregular_"$sensor"_norm.txt
		done
	fi
done

echo "Done creating training and testing data files."

