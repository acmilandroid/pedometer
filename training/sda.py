# sda.py
# compares steps.txt ground truth and predicted_steps.txt to get step detection accuracy (SDA)
# Usage: python3 sda.py [predicted_steps.txt] [ground_truth_steps.txt]

# import stuff
import warnings
import numpy as np
import sys
import random

# half a second, or 7 sensor readings
RANGE = 7

# checks if input args are correct
if len(sys.argv) != 3:
    sys.exit("Usage: python3 sda.py [predicted_steps.txt] [ground_truth_steps.txt]")


# open files and load steps
fpt = open(sys.argv[1], 'r')
predicted_steps = [int(line) for line in fpt]
fpt.close()
fpt = open(sys.argv[2], 'r')
gt_steps = [[x for x in line.split()] for line in fpt]
gt_steps = [int(x[0]) for x in gt_steps]
gt_steps.sort()

fpt.close()

# loop through and get FP, FN, TP
i = j = fp = fn = tp = 0
while i < len(predicted_steps) and j < len(gt_steps):
    if predicted_steps[i] < gt_steps[j] - RANGE:
        i += 1
        fp += 1
    elif predicted_steps[i] > gt_steps[j] + RANGE:
        j += 1
        fn += 1
    else:
        tp += 1
        i += 1
        j += 1

# get remaining fp and fn if they do not match in count
diff = len(predicted_steps) - len(gt_steps)
print("Predicted steps:", len(predicted_steps))
print("Actual steps:", len(gt_steps))
print("Difference:", diff)
if diff < 0:
    fp -= diff
else:
    fn += diff

print("TP:", tp)
print("FP:", fp)
print("FN:", fn)

ppv = tp / (tp + fp)
sensitivity = tp / (tp + fn)
f1 = 2*ppv*sensitivity / (ppv + sensitivity)

print("PPV:", ppv)
print("Sensitivity:", sensitivity)
print("F1 Score:", f1)