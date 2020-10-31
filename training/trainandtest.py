# Basil Lin
# step counter project
# program to train regression model to predict steps in a window
# Usage: python3 trainandtest.py [training_file.txt] [testing_file.txt] [window_size] [window_stride] [model_name.h5]
# input file must already be cut and normalized

# globals for switching program functionality
TOTAL_FEATURES = 3  # total number of features (3 for X,Y,Z acceleration)
WEIGHTED = False    # whether or not to weight the labels (keep False if data is balanced prior to training)
DATA_SPLIT = 0.8    # ratio of data to use as training

# import system for command line arguments
import sys

# checks for correct number of command line args
if len(sys.argv) != 6:
    sys.exit("Usage: python3 trainandtest.py [training_file.txt] [testing_file.txt] [window_size] [window_stride] [model_name.h5]")

window_size = int(sys.argv[3])
window_stride = int(sys.argv[4])

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

# open training and testing files
print("Opening training file...")
fpt = open(sys.argv[1], 'r')
training_rawdata = [[float(x) for x in line.split()] for line in fpt]
fpt.close
print("training_rawdata has shape", np.array(training_rawdata).shape)
print("Opening testing file...")
fpt = open(sys.argv[2], 'r')
testing_rawdata = [[float(x) for x in line.split()] for line in fpt]
fpt.close
print("testing_rawdata has shape", np.array(testing_rawdata).shape)

# copy to labels (steps per window) and features (sensor measurement axes)
print("Seperating training labels and features...")
training_rawdata = np.array(training_rawdata)
training_labels = training_rawdata[:,0]
training_batches = len(training_labels)
training_features_normalized = training_rawdata[:,1:]
print("training_features_normalized has shape", training_features_normalized.shape)
print("Seperating testing labels and features...")
testing_rawdata = np.array(testing_rawdata)
testing_labels = testing_rawdata[:,0]
testing_batches = len(testing_labels)
testing_features_normalized = testing_rawdata[:,1:]
print("testing_features_normalized has shape", testing_features_normalized.shape)

# copies features from 2D matrix training_features_normalized[#windows][x0 y0 z0 x1 y1 z1 ...] to 3D matrix training_data[#windows][window_length][#features]
# first dimension contains 1 measurement of each feature (X,Y,Z)
# second dimension contains the number of measurements in each time window (window_size)
# third dimension contains the total number of windows, or total samples
print("Reshaping normalized features for training...")
training_data = np.zeros((training_batches, window_size, TOTAL_FEATURES))
for i in range(0, training_batches):
    for j in range(0, window_size):
        for k in range(0, TOTAL_FEATURES):
            training_data[i][j][k] = training_features_normalized[i][k*window_size + j]
print("training_data has shape", training_data.shape)
print("Reshaping normalized features for testing...")
testing_data = np.zeros(testing_batches, window_size, TOTAL_FEATURES))
for i in range(0, testing_batches):
    for j in range(0, window_size):
        for k in range(0, TOTAL_FEATURES):
            testing_data[i][j][k] = testing_features_normalized[i][k*window_size + j]
print("testing_data has shape", testing_data.shape)

# set weight classes based on original distribution if weights are turned on
if (WEIGHTED == True):
    values, counts = np.unique(training_labels, return_counts=True)
    class_weight = dict(zip(values, counts))

# set up classifier
model = keras.Sequential([
    keras.layers.Conv1D(input_shape=(window_size, TOTAL_FEATURES), filters=10, kernel_size=10, strides=1, activation='relu'),
    keras.layers.Conv1D(filters=10, kernel_size=5, activation='relu'),
    keras.layers.Flatten(),  # must flatten to feed dense layer
    keras.layers.Dense(1)
])

model.compile(optimizer='adam', loss='mean_squared_error', metrics=['mean_absolute_error'])
es = keras.callbacks.EarlyStopping(monitor='val_loss', mode='min', verbose=1, patience=50)

model.summary()

print("Training...")
if (WEIGHTED == True):
    metrics = model.fit(training_data, training_labels, epochs=200, verbose=2, callbacks=[es], class_weight=class_weight)
else:
    metrics = model.fit(training_data, training_labels, epochs=200, verbose=2, callbacks=[es])

# print("Testing")
# loss, accuracy = model.evaluate(training_data, training_labels)
# print("Validation loss:", loss)
# print("Validation Mean Absolute Error:", accuracy)

# find average difference
training_predicted_steps = 0
training_actual_steps = 0
testing_predicted_steps = 0
testing_actual_steps = 0
training_predictions = model.predict(training_data)
testing_predictions = model.predict(testing_data)

# loop through all training windows
for i in range(0, training_batches):
    # don't let training_predictions be negative
    if training_predictions[i][0] < 0:
        training_predictions[i][0] = 0
    training_predicted_steps += training_predictions[i][0] / window_size * window_stride  # integrate window to get step count
    training_actual_steps += training_labels[i] / window_size * window_stride

# loop through all testing windows
for i in range(0, testing_batches):
    # don't let testing_predictions be negative
    if testing_predictions[i][0] < 0:
        testing_predictions[i][0] = 0
    testing_predicted_steps += testing_predictions[i][0] / window_size * window_stride  # integrate window to get step count
    testing_actual_steps += testing_labels[i] / window_size * window_stride

# calculate training difference
training_predicted_steps = round(training_predicted_steps)
training_actual_steps = round(training_actual_steps)
training_diff = abs(training_predicted_steps-training_actual_steps)

# calculate testing difference
testing_predicted_steps = round(testing_predicted_steps)
testing_actual_steps = round(testing_actual_steps)
testing_diff = abs(testing_predicted_steps-testing_actual_steps)

# print training results
print("Training predicted steps:", training_predicted_steps)
print("Training actual steps:", training_actual_steps)
print("Training difference in steps:", training_diff)
print("Training RCA: %.4f" %(training_predicted_steps/training_actual_steps))

# print testing results
print("Testing predicted steps:", testing_predicted_steps)
print("Testing actual steps:", testing_actual_steps)
print("Testing difference in steps:", testing_diff)
print("Testing RCA: %.4f" %(testing_predicted_steps/testing_actual_steps))

# save model
model.save(sys.argv[5])