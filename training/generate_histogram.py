# Basil Lin
# step counter project
# generates histogram based on given debug data
# Usage: python3 generate_histogram.py [input_debug_file.txt] [histogram_output.png]

# import sys
import sys

# checks if input args are correct
if len(sys.argv) != 3:
    sys.exit("Usage: python3 generate_histogram.py [input_debug_file.txt] [histogram_output.png]")

# import stuff
import warnings
import numpy as np
import random
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import csv

# open file
print("Loading file...")
with open(sys.argv[1], newline='\n') as fpt:
    reader = csv.reader(fpt, delimiter=',')
    data = list(reader)

histdata = list(line[4] for line in data)           # get column 5 (predicted steps in window)
histdata.pop(0)                                     # remove string header
histdata = np.array([float(x) for x in histdata])   # convert to float
histdata = np.array(histdata)                       # convert to array

# plot histogram of steps
print("Plotting histogram...")
d = np.diff(np.unique(histdata)).min()
left_of_first_bin = histdata.min() - float(d)/2
right_of_last_bin = histdata.max() + float(d)/2
plt.figure(1)
figure = plt.hist(histdata, bins=range(0, 19, 1), edgecolor='black', linewidth=1.2, histtype='stepfilled')
plt.xticks(np.arange(0, 19, step=1))
plt.xlabel("Steps in a Window")
plt.ylabel("Frequency")
plt.savefig(sys.argv[2])