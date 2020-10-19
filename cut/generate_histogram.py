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

# open file
print("Loading file...")
fpt = open(sys.argv[1], 'r')
data = [[float(x) for x in line.split()] for line in fpt]
fpt.close()

# calculate some values
data = np.array(data)
samples = len(data)
diff_steps = len(np.unique(data[:,0]))
histdata = data[:,0]

print("Samples in original data:", samples)
print("Number of different steps:", diff_steps)

# plot histogram of steps
print("Plotting histogram...")
d = np.diff(np.unique(histdata)).min()
left_of_first_bin = histdata.min() - float(d)/2
right_of_last_bin = histdata.max() + float(d)/2
plt.figure(1)
figure = plt.hist(histdata, np.arange(left_of_first_bin, right_of_last_bin + d, d), edgecolor='black', linewidth=1.2)
plt.xticks(np.arange(min(histdata), max(histdata)+1, 1.0))
plt.title("Step Histogram Original Data")
plt.xlabel("Steps in a Window")
plt.ylabel("Frequency")
plt.savefig(sys.argv[2])