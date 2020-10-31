# Basil Lin
# step counter project
# program to print model summary
# Usage: python3 test_model.py [model_name.h5]

# import system for command line arguments
import sys

if len(sys.argv) != 2:
	sys.exit("Usage: python3 test_model.py [model_name.h5]")

# import other stuff so I don't slow down the Usage warning
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning) #suppresses future warnings
import logging
logging.getLogger('tensorflow').disabled = True
import tensorflow as tf
from tensorflow import keras

print("Tensorflow version:", tf.__version__)
print("Python version:", sys.version)

# load keras model
model = tf.keras.models.load_model(sys.argv[1])
model.summary()