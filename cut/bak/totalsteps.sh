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
regularsteps=0
semiregularsteps=0
irregularsteps=0

# loop through each subject to test
for d in $1*; do
	if [ -d "$d" ]; then
		echo "$d"
		steps=$(cat $d/Regular/steps.txt | wc -l)
		((regularsteps += steps))
		steps=$(cat $d/SemiRegular/steps.txt | wc -l)
		((semiregularsteps += steps))
		steps=$(cat $d/Irregular/steps.txt | wc -l)
		((irregularsteps += steps))
	fi
done

((totalsteps = regularsteps + semiregularsteps + irregularsteps))

echo "Regular steps in $1: $regularsteps"
echo "SemiRegular steps in $1: $semiregularsteps"
echo "Irregular steps in $1: $irregularsteps"
echo "Total steps in $1: $totalsteps"