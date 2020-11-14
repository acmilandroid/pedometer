# Basil Lin
# step counter project
# program to train regression model to predict steps in a window
# Usage: python3 train_model.py [input_file.txt] [window_size] [window_stride] [model_name.h5]
# input file must already be cut and normalized

import sys

# checks for correct number of command line args
if len(sys.argv) != 4:
	sys.exit("Usage: python3 train_model.py [input_file.txt] [window_size] [window_stride]")

window_size = int(sys.argv[2])
window_stride = int(sys.argv[3])

# import other stuff so I don't slow down the Usage warning
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning) #suppresses future warnings
import logging
logging.getLogger('tensorflow').disabled = True
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 
import numpy as np

# open file
print("Opening training file...")
fpt = open(sys.argv[1], 'r')
rawdata = [[float(x) for x in line.split()] for line in fpt]
fpt.close
print("rawdata has shape", np.array(rawdata).shape)

# copy to labels (steps per window) and features (sensor measurement axes)
print("Seperating labels and features...")
rawdata = np.array(rawdata)
labels = rawdata[:,0]
num_samples = len(labels)
features_normalized = rawdata[:,1:]
print("features_normalized has shape", features_normalized.shape)


train_samples = len(labels)
train_actual_steps = 0
# loop through all training windows
for i in range(0, train_samples):
	train_actual_steps += labels[i] / window_size * window_stride

# print training results
print("Training actual steps:", train_actual_steps)