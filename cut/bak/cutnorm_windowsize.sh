#!/bin/bash
# Basil Lin
# Step counter project
# creates cut and normalized data for various window sizes

WINDOW_START=15			# start size of window in datum
WINDOW_END=150			# end size of window in datum
WINDOW_INCREMENT=15		# increment of window in datum

echo "Bash version ${BASH_VERSION}"

# loop through all window sizes to test
for (( window_size=$WINDOW_START; window_size<=$WINDOW_END; window_size+=$WINDOW_INCREMENT )); do
	# remove old training data
	rm -r cutnorm_$window_size
	./cutnorm.sh ../PedometerData $window_size 1 0 &> /dev/null &
done