#!/bin/bash
# Basil Lin
# step counter project
# combines and cuts all CSV files
# usage: ./all_cut.sh [directory] [CUT] [STRIDE]
# [directory] is top level dir containing all subject files
# requires cutstep.c to be compiled as cutsteps in same directory
# creates everything_cut.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "usage: ./all_cut.sh [directory] [CUT] [STRIDE]"
    exit 1
fi

num=0

echo "removing everything_cut.txt..."
rm everything_cut.txt &> /dev/null

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./cutsteps $2 $3 $d"/Irregular/Sensor01.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Irregular/Sensor02.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Irregular/Sensor03.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Regular/Sensor01.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Regular/Sensor02.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/Regular/Sensor03.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/SemiRegular/Sensor01.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/SemiRegular/Sensor02.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
        ./cutsteps $2 $3 $d"/SemiRegular/Sensor03.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
    fi
done

echo "$((num)) csv files cut for step windows."