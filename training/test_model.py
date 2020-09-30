# Basil Lin
# step counter project
# program to test classifier model with input
# Usage: python3 test_model.py [model_name.h5] [window_size] [input_file.txt] [steps.txt] [print 0|1]
# print input allows you to print predicted_step_indices or not
# input file must be first cut by cutsteps.c

# puts in debug mode to print individual window counts, sum, and output steps
debug = 1

# import system for command line arguments
import sys

total_features = 3

# half a second, or 7 sensor readings
RANGE = 7


# always test with a stride of 1 datum
testing_stride = 1 
training_stride = 1

# checks for correct number of command line args
if len(sys.argv) != 6:
    sys.exit("Usage: python3 test_model.py [model_name.h5] [window_size] [input_file.txt] [steps.txt] [print 0|1]")

cut = int(sys.argv[2])

# import other stuff so I don't slow down the Usage warning
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning) #suppresses future warnings
import logging
logging.getLogger('tensorflow').disabled = True
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 
import tensorflow as tf
from tensorflow import keras
import numpy as np
import time
import csv

print("Tensorflow version:", tf.__version__)
print("Python version:", sys.version)

# open input and ground truth files
fpt = open(sys.argv[3], 'r')
rawfeatures = [[float(x) for x in line.split()] for line in fpt]
fpt.close()
fpt = open(sys.argv[4], 'r')
gt_steps = [[x for x in line.split()] for line in fpt]
gt_steps = [int(x[0]) for x in gt_steps]
first_step = min(gt_steps)
fpt.close()

# load keras model
model = tf.keras.models.load_model(sys.argv[1])

# copy to labels and features
labels = []
features = []

# TODO: may need to rework normalization
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
predicted_step_indices = []
predicted_steps = 0
prev_predicted_steps = 0
predictions = model.predict(features_input)

if debug == 1:
    debug_file = open("debug.csv", "w")
    debug_file.write("Steps in Window,Running step sum,Difference,Index output\n")

# loop through all windows
for i in range(0, num_samples):
    # print(labels[i], "\t", predictions[i][0])
    predicted_steps += predictions[i][0] / cut * testing_stride  # integrate window to get step count
    step_delta = int(predicted_steps) - prev_predicted_steps     # find difference in steps for each window shift
    prev_predicted_steps = int(predicted_steps)
    if debug == 1:
        debug_file.write(str(predictions[i][0]) + "," + str(predicted_steps) + "," + str(step_delta) + ",")
    # mark detected steps when the number of steps changes
    if step_delta > 0:
        for j in range (0, step_delta):
            predicted_step_indices.append(first_step-int(cut/2) + testing_stride*i)
        if debug == 1:
            debug_file.write(str(first_step-int(cut/2) + testing_stride*i) + "\n")
    elif debug == 1:
        debug_file.write("None\n")

if debug == 1:
    debug_file.close()

print("Average steps detected per slide:", predicted_steps/num_samples)

# calculate difference
predicted_steps = int(round(predicted_steps))
actual_steps = len(gt_steps)
diff = abs(predicted_steps-actual_steps)

# write steps detected if user has print=1
if (int(sys.argv[5]) == 1):
    steps_file = open("predicted_steps.txt", "w")
    steps_file.write('\n'.join(map(str, predicted_step_indices)))
    steps_file.close()

# loop through and get FP, FN, TP
gt_steps.sort()
i = j = fp = fn = tp = 0
while i < len(predicted_step_indices) and j < len(gt_steps):
    if predicted_step_indices[i] < gt_steps[j] - RANGE:
        i += 1
        fp += 1
    elif predicted_step_indices[i] > gt_steps[j] + RANGE:
        j += 1
        fn += 1
    else:
        tp += 1
        i += 1
        j += 1

# get remaining fp and fn if they do not match in count
if diff < 0:
    fp -= diff
else:
    fn += diff

# calculate SDA metrics
ppv = tp / (tp + fp)
sensitivity = tp / (tp + fn)
f1 = 2*ppv*sensitivity / (ppv + sensitivity)

# print testing results
print("Predicted steps:", predicted_steps, "Actual steps:", actual_steps)
print("Difference in steps:", diff)
print("TP:", tp)
print("FP:", fp)
print("FN:", fn)
print("PPV:", ppv)
print("Sensitivity:", sensitivity)
print("Run count accuracy: %.4f" %(predicted_steps/actual_steps))
print("Step detection accuracy F1 Score:", f1)