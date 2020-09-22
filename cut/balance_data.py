# Basil Lin
# step counter project
# program to parse data txt file to randomly choose more balanced data
# attempts to uniformly distribute labels (class)
# Usage: python3 balance_data.py [input_file.txt] [output_file.txt]

# import sys
import sys

# checks if input args are correct
if len(sys.argv) != 3:
    sys.exit("Usage: python3 balance_data.py [input_file.txt] [output_file.txt]")

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
values = len(np.unique(data[:,0]))

print("Samples in original data:", samples)
print("Number of different steps:", values)

# plot histogram of steps
print("Plotting histogram...")
histdata = data[:,0]
d = np.diff(np.unique(histdata)).min()
left_of_first_bin = histdata.min() - float(d)/2
right_of_last_bin = histdata.max() + float(d)/2
figure = plt.hist(histdata, np.arange(left_of_first_bin, right_of_last_bin + d, d), edgecolor='black', linewidth=1.2)
plt.xticks(np.arange(min(histdata), max(histdata)+1, 1.0))
plt.title("Histogram of Steps")
plt.xlabel("Steps")
plt.ylabel("Frequency")
plt.savefig("histogram.png")

# find percentage of labels and minimum
print("calculating percentages...")
count = [0] * values
total = 0
percent = [0] * values
smallest = 100

for i in range(0, samples):
    count[int(data[i][0])] += 1
    total += 1

for i in range(0, values):
    # print("Count", i, "is", count[i])
    percent[i] = count[i] / total * 100
    # print("Percent", i, "is %.2f" %(percent[i]))
    if percent[i] > 0.1 and percent[i] < smallest:
        smallest = percent[i]

samples_per_count = int(samples * smallest / values)
print("Maximum samples for each step count:", samples_per_count)

# print percentages of each step
for i in range(0, values):
    print("Count", i, "is", count[i])
    percent[i] = count[i] / total * 100
    print("Percent", i, "is %.2f" %(percent[i]))
    if percent[i] < smallest:
        smallest = percent[i]

# randomly choose data to make uniform
print("Choosing data uniformly...")
shuffled_data = []
shuffled_count = [0] * values
for i in range(0, samples):
    steps = int(data[i][0])
    if shuffled_count[steps] <= samples_per_count:
        if random.random() < (smallest / percent[steps]):
            shuffled_data.append(data[i])
            shuffled_count[steps] += 1
print("Samples in redistributed data:", len(shuffled_data))
print("Number of different steps:", values)

# write shuffled data to output file
print("Writing data to file...")
fpt = open(sys.argv[2], 'w')
np.savetxt(fpt, shuffled_data, fmt='%.3f', delimiter='\t')
fpt.close()

# evaluate uniformity of shuffled data
print("Evaluating distribution...")
fpt = open(sys.argv[2], 'r')
data = [[float(x) for x in line.split()] for line in fpt]
fpt.close()

data = np.array(data)
samples = len(data)
values = len(np.unique(data[:,0]))

count = [0] * values
total = 0
percent = [0] * values
smallest = 100

for i in range(0, samples):
    count[int(data[i][0])] += 1
    total += 1

for i in range(0, values):
    print("Count", i, "is", count[i])
    percent[i] = count[i] / total * 100
    print("Percent", i, "is %.2f" %(percent[i]))
    if percent[i] < smallest:
        smallest = percent[i]

print("Smallest percentage is", smallest)
