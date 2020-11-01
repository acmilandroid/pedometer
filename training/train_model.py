# Basil Lin
# step counter project
# program to train regression model to predict steps in a window
# Usage: python3 train_model.py [input_file.txt] [window_size] [window_stride] [model_name.h5]
# input file must already be cut and normalized

# globals for switching program functionality
TOTAL_FEATURES = 3  # total number of features (3 for X,Y,Z acceleration)
WEIGHTED = False    # whether or not to weight the labels (keep False if data is balanced prior to training)
DATA_SPLIT = 1	    # ratio of data to use as training

# import system for command line arguments
import sys

# checks for correct number of command line args
if len(sys.argv) != 5:
	sys.exit("Usage: python3 train_model.py [input_file.txt] [window_size] [window_stride] [model_name.h5]")

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
print("Seperating labels and features...")
rawdata = np.array(rawdata)
labels = rawdata[:,0]
num_samples = len(labels)
features_normalized = rawdata[:,1:]
print("features_normalized has shape", features_normalized.shape)

# copies features from 2D matrix features_normalized[#windows][x0 y0 z0 x1 y1 z1 ...] to 3D matrix features_input[#windows][window_length][#features]
# first dimension contains 1 measurement of each feature (X,Y,Z)
# second dimension contains the number of measurements in each time window (window_size)
# third dimension contains the total number of windows, or total samples
print("Reshaping normalized features for training...")
features_input = np.zeros((len(features_normalized), window_size, TOTAL_FEATURES))
for i in range(0, num_samples):
	for j in range(0, window_size):
		for k in range(0, TOTAL_FEATURES):
			features_input[i][j][k] = features_normalized[i][k*window_size + j]
print("features_input has shape", features_input.shape)
batches = features_input.shape[0]

# split into training and testing data
train_data = []
test_data = []
train_labels = []
test_labels = []
split_start = 0
split_end = int(DATA_SPLIT * len(rawdata))
print("Splitting training data from rows", split_start, "to", split_end)
train_data[0:] = features_input[split_start:split_end]
test_data[0:] = np.delete(features_input, slice(split_start, split_end), 0)
train_labels[0:] = labels[split_start:split_end]
test_labels[0:] = np.delete(labels, slice(split_start, split_end), 0)

train_samples = len(train_labels)
test_samples = len(test_labels)
train_data = np.array(train_data)
train_labels = np.array(train_labels)
test_data = np.array(test_data)
test_labels = np.array(test_labels)

# set weight classes based on original distribution if weights are turned on
if (WEIGHTED == True):
	values, counts = np.unique(train_labels, return_counts=True)
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
	metrics = model.fit(train_data, train_labels, epochs=200, verbose=2, callbacks=[es], class_weight=class_weight)
else:
	metrics = model.fit(train_data, train_labels, epochs=1, verbose=2, callbacks=[es])

# print("Testing")
# loss, accuracy = model.evaluate(train_data, train_labels)
# print("Validation loss:", loss)
# print("Validation Mean Absolute Error:", accuracy)

train_predicted_steps = 0
train_actual_steps = 0
train_predictions = model.predict(train_data)

# loop through all training windows
for i in range(0, train_samples):
	# don't let train_predictions be negative
	if train_predictions[i][0] < 0:
		train_predictions[i][0] = 0
	train_predicted_steps += train_predictions[i][0] / window_size * window_stride  # integrate window to get step count
	train_actual_steps += train_labels[i] / window_size * window_stride

# calculate training difference
train_predicted_steps = round(train_predicted_steps)
train_actual_steps = round(train_actual_steps)
train_diff = abs(train_predicted_steps-train_actual_steps)

# print training results
print("Training predicted steps:", train_predicted_steps)
print("Training actual steps:", train_actual_steps)
print("Training difference in steps:", train_diff)
print("Training RCA: %.4f" %(train_predicted_steps/train_actual_steps))

# do same with testing results if there is a testing set
if DATA_SPLIT < 1:
	test_predicted_steps = 0
	test_actual_steps = 0
	test_predictions = model.predict(test_data)

	# loop through all testing windows
	for i in range(0, test_samples):
		# don't let test_predictions be negative
		if test_predictions[i][0] < 0:
			test_predictions[i][0] = 0
		test_predicted_steps += test_predictions[i][0] / window_size * window_stride  # integrate window to get step count
		test_actual_steps += test_labels[i] / window_size * window_stride

	# calculate testing difference
	test_predicted_steps = round(test_predicted_steps)
	test_actual_steps = round(test_actual_steps)
	test_diff = abs(test_predicted_steps-test_actual_steps)

	# print testing results
	print("Testing predicted steps:", test_predicted_steps)
	print("Testing actual steps:", test_actual_steps)
	print("Testing difference in steps:", test_diff)
	print("Testing RCA: %.4f" %(test_predicted_steps/test_actual_steps))

# save model
model.save(sys.argv[4])