# Basil Lin
# step counter project
# program to normalize the cut data
# Usage: python3 normalize.py [input_file.txt] [normalization_type] [sensor#]
# [normalization_type] 0 for per sensor per axis (requires independently cut sensor files), only does per axis
# [normalization_type] 1 for -1.5 to 1.5 gravities
# [sensor#] required for [normalization_type] = 0

# globals for switching program functionality
DEBUG = 1                   # debug prints
TOTAL_FEATURES = 3          # total number of features (3 for X,Y,Z acceleration)
MINMAX_VALUES = [           # contains min and max values for wrist, hip, ankle for x, y, z respectively
    [   # wrist (1)
        [-1.186, 1.118],    # x
        [-1.438, 1.561],    # y
        [-1.121, 1.079]     # z
    ], 
    [   # hip (2)
        [-1.01, 1.033],     # x
        [-1.166, 1.283],    # y
        [-1.077, 0.984]     # z
    ],
    [   # ankle (3)
        [-1.016, 0.954],    # x
        [-0.401, 1.546],    # y
        [-1.093, 0.948]     # z
    ]
]

# import system for command line arguments
import sys

# checks for correct number of command line args
if len(sys.argv) != 3 and len(sys.argv) != 4:
    sys.exit("Usage: python3 normalize.py [input_file.txt] [normalization_type] [sensor#]")
if sys.argv[2] == '0':
    if len(sys.argv) != 4:
        sys.exit("Usage: python3 normalize.py [input_file.txt] [normalization_type] [sensor#]")
    if int(sys.argv[3]) < 1 or int(sys.argv[3]) > 3:
        sys.exit("[sensor#] must be 1 2 or 3")

# import other stuff
import os
import numpy as np

# open file
print("Opening data file...")
fpt = open(sys.argv[1], 'r')
rawdata = [[float(x) for x in line.split()] for line in fpt]
fpt.close
print("rawdata has shape", np.array(rawdata).shape)

# copy to labels (steps per window) and features (sensor measurement axes)
rawdata = np.array(rawdata)
labels = rawdata[:,0]

# per sensor per axis normalization
if sys.argv[2] == '0':

    # separate feature data into one row per feature (x,y,z axis) for normalizing
    print("Separating features into one row per feature...")
    features_x = rawdata[:,1::TOTAL_FEATURES]
    features_y = rawdata[:,2::TOTAL_FEATURES]
    features_z = rawdata[:,3::TOTAL_FEATURES]

    # normalize each row of features
    print("Normalizing each row of features...")
    # for x
    minval = MINMAX_VALUES[int(sys.argv[3])-1][0][0]
    maxval = MINMAX_VALUES[int(sys.argv[3])-1][0][1]
    normdata_x = (features_x - minval) / (maxval - minval)
    # for y
    minval = MINMAX_VALUES[int(sys.argv[3])-1][1][0]
    maxval = MINMAX_VALUES[int(sys.argv[3])-1][1][1]
    normdata_y = (features_y - minval) / (maxval - minval)
    # for z
    minval = MINMAX_VALUES[int(sys.argv[3])-1][2][0]
    maxval = MINMAX_VALUES[int(sys.argv[3])-1][2][1]
    normdata_z = (features_z - minval) / (maxval - minval)

    # concatenate features together
    # x1 x2... xn y1 y2... yn z1 z2... zn for each row
    features_normalized = np.concatenate([normdata_x, normdata_y, normdata_z], axis=1)
    print("features_normalized has shape:", features_normalized.shape)

    # concatenate labels and normalized features to make data
    data = np.insert(features_normalized, 0, labels, axis=1)
    print("data has shape:", data.shape)

# normalize from -1.5 to 1.5 gravities
elif sys.argv[2] == '1':
    features = rawdata[:,1:]
    minval = -1.5
    maxval = 1.5
    features_normalized = (features - minval) / (maxval - minval)
    print("features_normalized has shape:", features_normalized.shape)

    # concatenate labels and normalized features to make data
    data = np.insert(features_flat, 0, labels, axis=1)
    print("data has shape:", data.shape)

# write data to output file
print("Writing data to data_normalized.txt...")
outfile = open("data_normalized.txt", 'w')
np.savetxt(outfile, data, fmt='%.3f', delimiter='\t')
outfile.close()