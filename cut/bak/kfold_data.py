# Basil Lin
# step counter project
# program to parse data txt file as kfold data
# Usage: python3 kfoldize_data.py [K] [input_file.txt] [output_file] (no extension on output file)

# import stuff
import warnings
import numpy as np
import sys
import random

# checks if input args are correct
if len(sys.argv) != 4:
    sys.exit("Usage: python3 kfoldize_data.py [K] [input_file.txt] [output_file] (no extension on output)")

# set K value (number of folds)
K = int(sys.argv[1])

# open file
fpt = open(sys.argv[2], 'r')
data = [[float(x) for x in line.split()] for line in fpt]
fpt.close()

# calculate some values
samples = len(data)
print("Samples in original data:", samples)

split = int(samples/K)
print("Split data at", split)
split_data = [None]*samples

for i in range(0, K):

    # split data up
    split_data = data[split-1:]
    split_data.extend(data[:split-1])
    split_data = np.array(split_data)

    # write split data to output file
    filename = sys.argv[3] + str(i) + ".txt"
    fpt = open(filename, 'w')
    np.savetxt(fpt, split_data, fmt='%.3f', delimiter='\t')
    fpt.close()
