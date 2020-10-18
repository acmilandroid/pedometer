#!/bin/bash
# Basil Lin
# Step counter project
# Tests a given {sensor, gait} pair and creates distribution of predicted steps using [input_model.h5]
# Usage: ./distribution.sh [directory] [window_size] [window_stride] [input_model.h5] [normalization_type] [output_file.csv]
# [directory] is top level dir containing all subject files
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]