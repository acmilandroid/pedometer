# Basil Lin
# step counter project
# program to parse sensor cut file to find min and max
# generates histogram of accelerometer distribution
# requires ALL_ALL_1_cut.txt ALL_ALL_2_cut.txt ALL_ALL_3_cut.txt
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
    filename = "ALL_ALL_" + str(i) + "_cut.txt"
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

    # make title string
    if i == 1:
        title = "Wrist Sensor, "
    elif i == 2:
        title = "Hip Sensor, "
    elif i == 3:
        title = "Ankle Sensor, "

    # plot histogram of x
    print("Plotting histogram x...")
    d = np.diff(np.unique(datax)).min()
    plt.figure(1)
    figure = plt.hist(datax, bins=np.arange(-1.25, 1.75, 0.25), edgecolor='black', linewidth=1.2, color='white', histtype='bar')
    plt.xticks(np.arange(-1.25, 1.75, 0.25))
    filename = "histogram_sensor0" + str(i) + "_x"
    title += "X axis"
    plt.title(title)
    plt.xlabel("Gravities")
    plt.ylabel("Frequency")
    plt.savefig(filename+'.eps', format='eps', bbox_inches="tight")

    # plot histogram of y
    print("Plotting histogram y...")
    d = np.diff(np.unique(datay)).min()
    plt.figure(2)
    figure = plt.hist(datay, bins=np.arange(-1.25, 1.75, 0.25), edgecolor='black', linewidth=1.2, color='white', histtype='bar')
    plt.xticks(np.arange(-1.25, 1.75, 0.25))
    filename = "histogram_sensor0" + str(i) + "_y"
    title += "Y axis"
    plt.title(title)
    plt.xlabel("Gravities")
    plt.ylabel("Frequency")
    plt.savefig(filename+'.eps', format='eps', bbox_inches="tight")

    # plot histogram of z
    print("Plotting histogram z...")
    d = np.diff(np.unique(dataz)).min()
    plt.figure(3)
    figure = plt.hist(dataz, bins=np.arange(-1.25, 1.75, 0.25), edgecolor='black', linewidth=1.2, color='white', histtype='bar')
    plt.xticks(np.arange(-1.25, 1.75, 0.25))
    filename = "histogram_sensor0" + str(i) + "_z"
    title += "Z axis"
    plt.title(title)
    plt.xlabel("Gravities")
    plt.ylabel("Frequency")
    plt.savefig(filename+'.eps', format='eps', bbox_inches="tight")

    print("------------------------------------")

