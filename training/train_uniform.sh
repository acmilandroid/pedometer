#!/bin/bash
#usage: ./train_uniform.sh [input_file.txt]
#takes input file, creates uniform distribution of output data
#trains uniform data, outputs to model.hd5
#tests model.hd5 against all data

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 1 ]; then
    echo "Usage: ./train_uniform.sh [input_file.txt]"
    exit 1
fi

python3 uniformize_data.py $1 uniform_data.txt
python3 train_model.py uniform_data.txt
python3 test_model.py $1 model.h5