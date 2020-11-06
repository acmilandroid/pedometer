#!/bin/bash
# Basil Lin
# Step counter project
# Cuts each window from 1-10 seconds with 5 folds of training and testing data

./create_trainandtest.sh ../data/cutnorm_15 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_15 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_15 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_15 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_15 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_30 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_30 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_30 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_30 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_30 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_45 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_45 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_45 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_45 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_45 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_60 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_60 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_60 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_60 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_60 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_75 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_75 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_75 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_75 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_75 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_90 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_90 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_90 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_90 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_90 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_105 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_105 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_105 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_105 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_105 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_120 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_120 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_120 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_120 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_120 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_135 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_135 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_135 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_135 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_135 5 5 &> /dev/null &

./create_trainandtest.sh ../data/cutnorm_150 5 1 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_150 5 2 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_150 5 3 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_150 5 4 &> /dev/null &
./create_trainandtest.sh ../data/cutnorm_150 5 5 &> /dev/null &