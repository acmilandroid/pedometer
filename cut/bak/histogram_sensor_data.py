# Basil Lin
# step counter project
# program to parse sensor cut file to find min and max
# generates histogram of accelerometer distribution
# requires ALL_ALL_ALL_cut.txt
# Usage: python3 histogram_sensor_data.py

# import sys
import sys

# checks if input args are correct
if len(sys.argv) != 1:
    sys.exit("Usage: python3 minmax.py")

# import stuff
import warnings
import numpy as np
import random
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

    
# open and load file
data = []
filename = "ALL_ALL_ALL_cut.txt"
print("Loading", filename, "...")
fpt = open(filename, 'r')
data = [[float(x) for x in line.split()] for line in fpt]
fpt.close()

# split into x y and z
data = np.array(data)
datax = np.copy(data[:, 1])
minvalx = datax.min()
maxvalx = datax.max()
datay = np.copy(data[:, 2])
minvaly = datay.min()
maxvaly = datay.max()
dataz = np.copy(data[:, 3])
minvalz = dataz.min()
maxvalz = dataz.max()

# print stats
print("Min x:", datax.min())
print("Max x:", datax.max())
print("Min y:", datay.min())
print("Max y:", datay.max())
print("Min z:", dataz.min())
print("Max z:", dataz.max())

# plot histogram of x
print("Plotting histogram x...")
d = np.diff(np.unique(datax)).min()
plt.figure(1)
figure = plt.hist(datax, bins=np.arange(-1.25, 1.75, 0.05), edgecolor='black', linewidth=1.2, color='white', histtype='bar')
plt.xticks(np.arange(-1.25, 1.75, 0.25))
filename = "histogram_ALL_ALL_ALL_cut"
plt.xlabel("Gravities")
plt.ylabel("Frequency")
plt.savefig(filename+'.eps', format='eps', bbox_inches="tight")
