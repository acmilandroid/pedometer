# Basil Lin
# step counter project
# generates histogram based on given debug data
# Usage: python3 generate_histogram_debug.py [input_debug_file.txt] [histogram_output.png]

# import sys
import sys

# checks if input args are correct
if len(sys.argv) != 3:
	sys.exit("Usage: python3 generate_histogram_debug.py [input_debug_file.txt] [histogram_output.png]")

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

predicted_steps = list(line[4] for line in data)                    # get column 5 (predicted steps in window)
gt_steps = list(line[3] for line in data)                           # get column 4 (gt steps in window)
predicted_steps.pop(0)                                              # remove string header
gt_steps.pop(0)
predicted_steps = np.array([float(x) for x in predicted_steps])     # convert to float
gt_steps = np.array([float(x) for x in gt_steps])
predicted_steps = np.array(predicted_steps)                         # convert to array
gt_steps = np.array(gt_steps) 

# plot histogram of steps
print("Plotting histogram...")
plt.style.use('grayscale')
plt.hist([gt_steps, predicted_steps], bins=range(0, 14, 1), edgecolor='black', linewidth=1.2, label=['GT Steps', 'Predicted Steps'])
plt.legend(loc='upper right')
plt.xticks(np.arange(0, 14, step=1))
plt.xlabel("Steps in a Window")
plt.ylabel("Frequency")
plt.savefig(sys.argv[2])