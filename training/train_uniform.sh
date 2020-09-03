#!/bin/bash
#usage: ./train_uniform.sh [input_file.txt] [steps.txt]
#takes input file, creates uniform distribution of output data
#trains uniform data, outputs to model.h5
#tests model.h5 against all data

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 2 ]; then
    echo "Usage: ./train_uniform.sh [input_file.txt] [steps.txt]"
    exit 1
fi

python3 uniformize_data.py $1 uniform_data.txt
python3 train_model.py uniform_data.txt
python3 test_model.py model.h5 $1 $2