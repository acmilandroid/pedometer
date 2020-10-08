# Basil Lin
# step counter project
# program to parse sensor cut file to find min and max
# generates histogram of accelerometer distribution
# requires sensor01.txt sensor02.txt sensor03.txt
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

# do for each sensor
for i in range(1, 4):
    
    # open and load file
    data = []
    filename = "sensor0" + str(i) + "_cut.txt"
    print("Loading", filename, "...")
    fpt = open(filename, 'r')
    data = [[float(x) for x in line.split()] for line in fpt]
    fpt.close()

    # remove steps in window column
    for row in data:
        del row[0]

    # split into x y and z
    data = np.array(data)
    datax = np.copy(data[:, ::3]).flatten()
    minvalx = datax.min()
    maxvalx = datax.max()
    datay = np.copy(data[:, 1::3]).flatten()
    minvaly = datay.min()
    maxvaly = datay.max()
    dataz = np.copy(data[:, 2::3]).flatten()
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
    left_of_first_bin = minvalx - float(d)/2
    right_of_last_bin = maxvalx + float(d)/2
    plt.figure(1)
    figure = plt.hist(datax, np.arange(left_of_first_bin, right_of_last_bin + d, d), edgecolor='black', linewidth=1.2)
    plt.xticks(np.arange(-1.5, 1.75, 0.25))
    filename = "histogram_sensor0" + str(i) + "_x"
    plt.title(filename)
    plt.xlabel("Gravities")
    plt.ylabel("Frequency")
    plt.savefig(filename + ".png")

    # plot histogram of y
    print("Plotting histogram y...")
    d = np.diff(np.unique(datay)).min()
    left_of_first_bin = minvaly - float(d)/2
    right_of_last_bin = maxvaly + float(d)/2
    plt.figure(2)
    figure = plt.hist(datay, np.arange(left_of_first_bin, right_of_last_bin + d, d), edgecolor='black', linewidth=1.2)
    plt.xticks(np.arange(-1.5, 1.75, 0.25))
    filename = "histogram_sensor0" + str(i) + "_y"
    plt.title(filename)
    plt.xlabel("Gravities")
    plt.ylabel("Frequency")
    plt.savefig(filename + ".png")

    # plot histogram of z
    print("Plotting histogram z...")
    d = np.diff(np.unique(dataz)).min()
    left_of_first_bin = minvalz - float(d)/2
    right_of_last_bin = maxvalz + float(d)/2
    plt.figure(3)
    figure = plt.hist(dataz, np.arange(left_of_first_bin, right_of_last_bin + d, d), edgecolor='black', linewidth=1.2)
    plt.xticks(np.arange(-1.5, 1.75, 0.25))
    filename = "histogram_sensor0" + str(i) + "_z"
    plt.title(filename)
    plt.xlabel("Gravities")
    plt.ylabel("Frequency")
    plt.savefig(filename + ".png")

    print("------------------------------------")

