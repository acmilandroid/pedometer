# Basil Lin
# step counter project
# program to test model with window_size input file
# Usage: python3 test_model.py [model_name.h5] [window_size] [input_file.txt] [steps.txt] [print 0|1] [debug.csv]
# print input allows you to print predicted_step_indices for STEPCOUNTERVIEW
# input file must be first cut and normalized
# if [debug.csv] is populated, a debug file showing predictions for each window will be created as [debug.csv]
# if [debug.csv] exists, it will be appended. If not, it will be created

# import system for command line arguments
import sys

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

# load keras model
model = tf.keras.models.load_model(sys.argv[1])
model.summary()