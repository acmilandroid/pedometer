# Basil Lin
# step counter project
# program to parse data txt file as kfold data
# output of kfold_split_data_[K#].txt and kfold_split_test_[K#].txt
# Usage: python3 kfoldize_data.py [K] [input_file.txt]

# import stuff
import warnings
import numpy as np
import sys
import random

# checks if input args are correct
if len(sys.argv) != 3:
    sys.exit("Usage: python3 kfoldize_data.py [K] [input_file.txt]")

# set K value (number of folds)
K = int(sys.argv[1])

# open file
fpt = open(sys.argv[2], 'r')
data = [[float(x) for x in line.split()] for line in fpt]
fpt.close()

# calculate some values
samples = len(data)
datapoints = len(data[0])
print("Samples in original data:", samples)
print("Data points per sample:", datapoints)

test_data = []
split_data = []

for i in range(0, K):

    # find split point
    split_start = i*int(samples/K)
    split_end = (i+1)*int(samples/K)
    print("Splitting data from rows", split_start, "to", split_end)

    # copy split to testing data and delete from original
    # test_data.append(np.zeros(datapoints))
    test_data[0:] = data[split_start:split_end]
    # test_data.append(np.zeros(datapoints))
    # split_data.append(np.zeros(datapoints))
    split_data[0:] = np.delete(data, slice(split_start, split_end), 0)
    # split_data.append(np.zeros(datapoints))

    # write testing data to output file
    filename = "kfold_split_test_" + str(i) + ".txt"
    fpt = open(filename, 'w')
    np.savetxt(fpt, test_data, fmt='%.3f', delimiter='\t')
    fpt.close()

    # write remaining data to output file
    filename = "kfold_split_data_" + str(i) + ".txt"
    fpt = open(filename, 'w')
    np.savetxt(fpt, split_data, fmt='%.3f', delimiter='\t')
    fpt.close()
