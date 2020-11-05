#!/bin/bash
# Basil Lin
# Step counter project
# Find total number of gt steps
# Usage: ./totalsteps.sh [PedometerData]

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 1 ]; then
	echo "Usage: ./totalsteps.sh [PedometerData]"
	exit 1
fi

totalsteps=0

# loop through each subject to test
for d in $1*; do
	if [ -d "$d" ]; then
		echo "$d"
		steps=$(cat $d/Regular/steps.txt | wc -l)
		((totalsteps += steps))
		steps=$(cat $d/SemiRegular/steps.txt | wc -l)
		((totalsteps += steps))
		steps=$(cat $d/Irregular/steps.txt | wc -l)
		((totalsteps += steps))
	fi
done

echo "Total steps in $1: $totalsteps"