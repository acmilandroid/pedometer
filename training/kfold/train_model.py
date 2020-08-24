# Basil Lin
# step counter project
# program to train classifier to detect steps in a window
# Usage: python3 train_model.py [input_file.txt]

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

total_axes = 6

# checks for correct number of command line args
if len(sys.argv) != 2:
    sys.exit("Usage: python3 train_model.py [input_file.txt]")

# open file
fpt = open(sys.argv[1], 'r')
rawdata = [[float(x) for x in line.split()] for line in fpt]
fpt.close

# copy to classes and data
classes = []
data = []

# separate data into one row per axis for normalizing
for i in range(0, len(rawdata)):
    classes.append(rawdata[i][0])
    for j in range(0, total_axes):
        row=[]
        for k in range(j+1, len(rawdata[i]), total_axes):
            row.append(rawdata[i][k])
        if len(row) != 75:
            print("error on line:", i, "length is", len(row))
        data.append(row)

classes = np.array(classes)
data = np.array(data)

print("data has shape", data.shape)
sample_length = data.shape[1]

# normalize each row of data
start=time.time()
normdata=np.empty_like(data)
for i in range(0, len(data)):
    norm=[]
    s=min(data[i])
    t=max(data[i])
    if s == t:
        t = s+1
    normdata[i] = (data[i]-s) / (t-s)
end = time.time()
print("data normalized in", end-start, " seconds")

data = normdata

# check normalization
# for i in range(0, len(normdata)):
#     if min(normdata[i]) != 0:
#         print("min ", i, " does not equal 0.")
#     if max(normdata[i]) != 1:
#         print("max ", i, " does not equal 1.")

# reshape data to flatten it to one row per recording
# data_flat in following format:
# x1 x2... xn y1 y2... yn z1 z2... zn Y1... P1... R1... Rn per row
data_flat = data.reshape(len(classes), len(data[0])*total_axes)
print("data_flat has shape", data_flat.shape)
num_samples = data_flat.shape[0]

# copies data from 2D matrix data_flat[#windows][x0 y0 z0 Y0 P0 R0 x1 y1 z1 Y1 P1 R1 ...] to 3D matrix data_input[#windows][window_length][#axes]
data_input = np.zeros((len(data_flat), sample_length, total_axes))
for i in range(0, num_samples):
    for j in range(0, sample_length):
        for k in range(0, total_axes):
            data_input[i][j][k] = data_flat[i][k*sample_length + j]
print("data_input has shape", data_input.shape)

# set up classifier
model = keras.Sequential([
    keras.layers.Conv1D(input_shape=(sample_length, total_axes,), filters=100, kernel_size=30, strides=5, activation='relu'),
    keras.layers.Conv1D(filters=100, kernel_size=5, activation='relu'),
    keras.layers.Flatten(),  # must flatten to feed dense layer
    keras.layers.Dense(1)
])

model.compile(optimizer='adam', loss='mean_squared_error', metrics=['mean_absolute_error'])
es = keras.callbacks.EarlyStopping(monitor='val_loss', mode='min', verbose=1, patience=50)

model.summary()

print("Training")
metrics = model.fit(data_input, classes, epochs=200,
    validation_split=0.2, verbose=2, callbacks=[es])

print("Testing")
loss, accuracy = model.evaluate(data_input, classes)
print("Validation loss:", loss)
print("Validation Mean Absolute Error:", accuracy)

predictions = model.predict(data_input)
# print("Actual:\tPrediction:")

# find average difference
predicted_steps = 0
actual_steps = 0
window_size = 75
window_stride = 5
predictions = model.predict(data_input)
for i in range(0, num_samples):
    # print(classes[i], "\t", predictions[i][0])
    predicted_steps += predictions[i][0] / window_size * window_stride
    actual_steps += classes[i] / window_size * window_stride
predicted_steps = round(predicted_steps)
actual_steps = round(actual_steps)
diff = abs(predicted_steps-actual_steps)
print("Predicted steps:", predicted_steps, "Actual steps:", actual_steps)
print("Difference in steps:", diff)
print("Training run count accuracy: %.4f" %(predicted_steps/actual_steps))

tf.keras.models.save_model(model, 'model.hd5', True, True)