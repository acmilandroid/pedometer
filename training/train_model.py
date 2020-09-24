# Basil Lin
# step counter project
# program to train classifier to detect steps in a window
# Usage: python3 train_model.py [input_file.txt] [window_size] [window_stride]
# input file must already be cut by cutsteps.c

# import system for command line arguments
import sys

debug = 0
total_features = 3

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
import tensorflow as tf
from tensorflow import keras
import numpy as np
import time
import csv

print("Tensorflow version:", tf.__version__)
print("Python version:", sys.version)

# open file
print("Opening training file...")
fpt = open(sys.argv[1], 'r')
rawdata = [[float(x) for x in line.split()] for line in fpt]
fpt.close

# copy to labels (steps per window) and features (sensor measurement axes)
labels = []
features = []

# separate features into one row per feature (axis) for normalizing
print("Separating features into one row per feature...")
for i in range(0, len(rawdata)):
    labels.append(rawdata[i][0])
    for j in range(0, total_features):
        row=[]
        for k in range(j+1, len(rawdata[i]), total_features):
            row.append(rawdata[i][k])
        if len(row) != window_size and debug == 0:
            print("error on line:", i, "length is", len(row))
        features.append(row)

labels = np.array(labels)
features = np.array(features)

print("features has shape", features.shape)
sample_length = features.shape[1]

#print labels and features for debugging
if debug == 1:
    print("labels:")
    print(labels)
    print("features:")
    print(features)

# normalize each row of features
print("Normalizing each row of features...")
start = time.time()
normdata = np.empty_like(features)
for i in range(0, len(features)):
    s = min(features[i])
    t = max(features[i])
    if s == t:
        t = s+1
    normdata[i] = (features[i]-s) / (t-s)
end = time.time()

features = normdata

# check normalization (debug mode only)
if debug == 1:
    for i in range(0, len(normdata)):
        s = min(normdata[i])
        t = max(normdata[i])
        if s != 0:
            print("min of", s, " at index", i, " does not equal 0.")
            print("normdata:")
            print(normdata[i])
        if t != 1:
            print("max of", t, " at index", i, " does not equal 1.")
            print("normdata:")
            print(normdata[i])

# reshape features to flatten it to one row per recording
# features_flat in following format:
# x1 x2... xn y1 y2... yn z1 z2... zn Y1... P1... R1... Rn per row
print("Reshaping normalized features...")
features_flat = features.reshape(len(labels), len(features[0])*total_features)
print("features_flat has shape", features_flat.shape)
num_samples = features_flat.shape[0]

if debug == 1:
    print("features_flat:")
    print(features_flat)

# copies features from 2D matrix features_flat[#windows][x0 y0 z0 Y0 P0 R0 x1 y1 z1 Y1 P1 R1 ...] to 3D matrix features_input[#windows][window_length][#features]
# first dimension contains 1 measurement of each feature (X,Y,Z, yaw,pitch,roll)
# second dimension contains the number of measurements (sensor samples) in the specific time window
# third dimension contains the total number of time windows, or total samples
features_input = np.zeros((len(features_flat), sample_length, total_features))
for i in range(0, num_samples):
    for j in range(0, sample_length):
        for k in range(0, total_features):
            features_input[i][j][k] = features_flat[i][k*sample_length + j]
print("features_input has shape", features_input.shape)

if debug == 1:
    print("features_input:")
    print(features_input)

# set up classifier
model = keras.Sequential([
    keras.layers.Conv1D(input_shape=(sample_length, total_features,), filters=100, kernel_size=30, strides=5, activation='relu'),
    keras.layers.Conv1D(filters=100, kernel_size=5, activation='relu'),
    keras.layers.Flatten(),  # must flatten to feed dense layer
    keras.layers.Dense(1)
    # keras.layers.Conv1D(input_shape=(sample_length, total_features,), filters=100, kernel_size=6, activation='relu'),
    # keras.layers.MaxPooling1D(pool_size=6),
    # keras.layers.Flatten(),  # must flatten to feed dense layer
    # keras.layers.Dense(50, activation='relu'),
    # keras.layers.Dense(1)
])

model.compile(optimizer='adam', loss='mean_squared_error', metrics=['mean_absolute_error'])
es = keras.callbacks.EarlyStopping(monitor='val_loss', mode='min', verbose=1, patience=50)

model.summary()

print("Training")
metrics = model.fit(features_input, labels, epochs=200, verbose=2, callbacks=[es])

# print("Testing")
# loss, accuracy = model.evaluate(features_input, labels)
# print("Validation loss:", loss)
# print("Validation Mean Absolute Error:", accuracy)

predictions = model.predict(features_input)

# find average difference
predicted_steps = 0
actual_steps = 0
predictions = model.predict(features_input)

# loop through all windows
for i in range(0, num_samples):
    predicted_steps += predictions[i][0] / window_size * window_stride  # integrate window to get step count
    actual_steps += labels[i] / window_size * window_stride

# calculate difference
predicted_steps = round(predicted_steps)
actual_steps = round(actual_steps)
diff = abs(predicted_steps-actual_steps)

# print training results
print("Predicted steps:", predicted_steps, "Actual steps:", actual_steps)
print("Difference in steps:", diff)
print("Training run count accuracy: %.4f" %(predicted_steps/actual_steps))

# save model
model.save("model.h5")