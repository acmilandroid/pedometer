# Basil Lin
# step counter project
# program to test classifier model with input
# Usage: python3 test_model.py [model_name.h5] [input_file.txt] [steps.txt]

import logging
logging.getLogger('tensorflow').disabled = True
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 

# import stuff
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning) #suppresses future warnings
import tensorflow as tf
from tensorflow import keras
import numpy as np
import time
import csv
import sys

total_features = 6

# checks for correct number of command line args
if len(sys.argv) != 4:
    sys.exit("Usage: python3 test_model.py [model_name.h5] [input_file.txt] [steps.txt]")

# open input and ground truth files
fpt = open(sys.argv[2], 'r')
rawfeatures = [[float(x) for x in line.split()] for line in fpt]
fpt.close()
fpt = open(sys.argv[3], 'r')
gt_steps = fpt.read().split()

gt_steps = [float(x) for x in gt_steps if not isinstance(x, str)]
print(gt_steps)
fpt.close()

# load keras model
model = tf.keras.models.load_model(sys.argv[1])

# copy to labels and features
labels = []
features = []

# separate features into one row per axis for normalizing
for i in range(0, len(rawfeatures)):
    labels.append(rawfeatures[i][0])
    for j in range(0, total_features):
        row=[]
        for k in range(j+1, len(rawfeatures[i]), total_features):
            row.append(rawfeatures[i][k])
        if len(row) != 75:
            print("error on line:", i, "length is", len(row))
        features.append(row)

labels = np.array(labels)
features = np.array(features)

print("features has shape", features.shape)
sample_length = features.shape[1]

# normalize each row of features
start=time.time()
normfeatures=np.empty_like(features)
for i in range(0, len(features)):
    norm=[]
    s=min(features[i])
    t=max(features[i])
    if s == t:
        t = s+1
    normfeatures[i] = (features[i]-s) / (t-s)
end = time.time()
print("features normalized in", end-start, " seconds")

features = normfeatures

# reshape features to flatten it to one row per recording
# features_flat in following format:
# x1 x2... xn y1 y2... yn z1 z2... zn Y1... P1... R1... Rn per row
features_flat = features.reshape(len(labels), len(features[0])*total_features)
print("features_flat has shape", features_flat.shape)
num_samples = features_flat.shape[0]

# copies features from 2D matrix features_flat[#windows][x0 y0 z0 Y0 P0 R0 x1 y1 z1 Y1 P1 R1 ...] to 3D matrix features_input[#windows][window_length][#axes]
features_input = np.zeros((len(features_flat), sample_length, total_features))
for i in range(0, num_samples):
    for j in range(0, sample_length):
        for k in range(0, total_features):
            features_input[i][j][k] = features_flat[i][k*sample_length + j]
print("features_input has shape", features_input.shape)

# test model on features
print("Testing")
loss = model.evaluate(features_input, labels)
print("Validation loss:", loss[1])
predictions = model.predict(features_input)

# find average difference
step_indices = []
predicted_steps = 0
prev_predicted_steps = 0
actual_steps = 0
window_size = 75
window_stride = 5
predictions = model.predict(features_input)

# loop through all windows
for i in range(0, num_samples):

    # print(labels[i], "\t", predictions[i][0])
    predicted_steps += predictions[i][0] / window_size * window_stride  # integrate window to get step count
    actual_steps += labels[i] / window_size * window_stride
    step_delta = int(predicted_steps) - prev_predicted_steps            # find difference in steps for each window shift
    prev_predicted_steps = int(predicted_steps)

    # mark detected steps when the number of steps changes
    if step_delta > 0:
        for j in range (0, step_delta):
            step_indices.append(round(i + index_delta))

# calculate difference
predicted_steps = round(predicted_steps)
actual_steps = round(actual_steps)
diff = abs(predicted_steps-actual_steps)

# print testing results
print("Predicted steps:", predicted_steps, "Actual steps:", actual_steps)
print("Difference in steps:", diff)
print("Run count accuracy: %.4f" %(predicted_steps/actual_steps))

# write steps detected
steps_file = open("predicted_step_indices.txt", "w")
steps_file.write('\n'.join(map(str, step_indices)))
steps_file.close()