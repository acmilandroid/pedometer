#!/bin/bash
# Basil Lin
# Uses norm data and create testing and training files
# Usage: ./create_bigdata.sh [data/cutnorm_windowsize] [num_folds]
# [data/cutnorm_windowsize] is top level dir containing all cut and normalized subject data files
# creates a training data file of all data of the first num_folds-1 folds of subjects
# creates a testing data file of all data of the last num_folds fold of subjects

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 2 ]; then
    echo "Usage: ./create_trainandtest.sh [data/cutnorm_windowsize] [num_folds]"
    exit 1
fi

# remove old files
cd $1
for ((sensor=1; sensor<=3; sensor++)); do
	rm trainingfold$2_ALL_ALL_norm.txt &> /dev/null
	rm testingfold$2_ALL_ALL_norm.txt &> /dev/null
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

# find start and end subjects for withheld testing data
fold_end=$(($subjects/$2*$2))
fold_start=$(($fold_end-$subjects/$2+1))

# create testing data
echo "Creating testing data..."
for ((subject=$fold_start; subject<=$fold_end; subject++)); do
	for ((sensor=1; sensor<=3; sensor++)); do
		cat "$subject"_Regular_"$sensor"_norm.txt >> testingfold$2_ALL_ALL_norm.txt
		cat "$subject"_SemiRegular_"$sensor"_norm.txt >> testingfold$2_ALL_ALL_norm.txt
		cat "$subject"_Irregular_"$sensor"_norm.txt >> testingfold$2_ALL_ALL_norm.txt
	done
done

# create training data
echo "Creating training data..."
for ((subject=1; subject<=$subjects; subject++)); do
	# if not in the withheld testingfold$3 subjects
	if (($subject<$fold_start || $subject>$fold_end)); then
		for ((sensor=1; sensor<=3; sensor++)); do
			cat "$subject"_Regular_"$sensor"_norm.txt >> trainingfold$2_ALL_ALL_norm.txt
			cat "$subject"_SemiRegular_"$sensor"_norm.txt >> trainingfold$2_ALL_ALL_norm.txt
			cat "$subject"_Irregular_"$sensor"_norm.txt >> trainingfold$2_ALL_ALL_norm.txt
		done
	fi
done

echo "Done creating big training and big testing data files."

