# Basil Lin
# step counter project
# program to parse sensor cut file to find min and max
# generates histogram of accelerometer distribution
# Usage: python3 minmax.py [sensor_0#_cut.txt]

# import sys
import sys

# checks if input args are correct
if len(sys.argv) != 2:
    sys.exit("Usage: python3 minmax.py [sensor_0#_cut.txt]")

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
for row in data:
    del row[0]
histdata = np.array(data).flatten()
minval = histdata.min()
maxval = histdata.max()

print("Min accelerometer reading:", histdata.min())
print("Max accelerometer reading:", histdata.max())

# plot histogram of steps
print("Plotting histogram...")
d = np.diff(np.unique(histdata)).min()
left_of_first_bin = minval - float(d)/2
right_of_last_bin = maxval + float(d)/2
plt.figure(1)
figure = plt.hist(histdata, np.arange(left_of_first_bin, right_of_last_bin + d, d), edgecolor='black', linewidth=1.2)
plt.xticks(np.arange(int(minval-1), int(maxval + 1), 0.25))
plt.title("Histogram of Accelerometer Readings")
plt.xlabel("Gravities")
plt.ylabel("Frequency")
plt.savefig("accelerometer_histogram.png")
