# Basil Lin
# step counter project
# program to randomly select lines from data file, makes smaller file to train on
# Usage: python3 reduce_data.py [input_file.txt] [output_file.txt] [Percent Chance]

# import sys
import sys

# checks if input args are correct
if len(sys.argv) != 4:
    sys.exit("Usage: python3 reduce_data.py [input_file.txt] [output_file.txt] [Percent Chance]")

# import stuff
import warnings
import numpy as np
import random

# randomly write lines
outfile = open(sys.argv[2], 'w')
with open(sys.argv[1], 'r') as infile:
    line = infile.readline()
    print("Percent chance:", float(sys.argv[3]))
    while line:
        if random.randint(0, 100) <= float(sys.argv[3]):
            outfile.write(line)
        line = infile.readline()
infile.close()
outfile.close()