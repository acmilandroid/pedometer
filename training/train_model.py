# Basil Lin
# step counter project
# program to train regression model to predict steps in a window
# Usage: python3 train_model.py [input_file.txt] [window_size] [window_stride]
# input file must already be cut by cutsteps.c

# globals for switching program functionality
DEBUG = 0           # debug prints
NORMALIZE = 0       # switches type of normalization (0 for per sensor per position, 1 for -1.5 to 1.5 gravities)
TOTAL_FEATURES = 3  # total number of features (3 for X,Y,Z acceleration)

# import system for command line arguments
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
print("rawdata has shape", np.array(rawdata).shape)

# copy to labels (steps per window) and features (sensor measurement axes)
labels = rawdata[:,0]
features = rawdata[:,1:]

# copies features from 2D matrix features_flat[#windows][x0 y0 z0 x1 y1 z1 ...] to 3D matrix features_input[#windows][window_length][#features]
# first dimension contains 1 measurement of each feature (X,Y,Z)
# second dimension contains the number of measurements in each time window (window_size)
# third dimension contains the total number of windows, or total samples
features_input = np.zeros((len(features_flat), sample_length, TOTAL_FEATURES))
for i in range(0, num_samples):
    for j in range(0, sample_length):
        for k in range(0, TOTAL_FEATURES):
            features_input[i][j][k] = features_flat[i][k*sample_length + j]
print("features_input has shape", features_input.shape)

if DEBUG == 1:
    print("features_input:")
    print(features_input)

# set up classifier
model = keras.Sequential([
    keras.layers.Conv1D(input_shape=(sample_length, TOTAL_FEATURES,), filters=100, kernel_size=30, strides=5, activation='relu'),
    keras.layers.Conv1D(filters=100, kernel_size=5, activation='relu'),
    keras.layers.Flatten(),  # must flatten to feed dense layer
    keras.layers.Dense(1, activation='relu')
    # keras.layers.Conv1D(input_shape=(sample_length, TOTAL_FEATURES,), filters=100, kernel_size=6, activation='relu'),
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