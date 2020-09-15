#!/bin/bash
# usage: ./all_cut.sh [directory] [cutsteps_executable] [CUT] [STRIDE]
# [directory] is top level dir containing all subject files
# combines and cuts all CSV files
# creates everything_cut.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 4 ]; then
    echo "usage: ./all_cut.sh [directory] [cutsteps_executable] [CUT] [STRIDE]"
    exit 1
fi

num=0

echo "removing everything_cut.txt..."
rm everything_cut.txt

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./$2 $3 $4 $d"/Irregular/Sensor01.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/Irregular/Sensor02.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/Irregular/Sensor03.csv" $d"/Irregular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/Regular/Sensor01.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/Regular/Sensor02.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/Regular/Sensor03.csv" $d"/Regular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/SemiRegular/Sensor01.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/SemiRegular/Sensor02.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
        ./$2 $3 $4 $d"/SemiRegular/Sensor03.csv" $d"/SemiRegular/steps.txt" >> everything_cut.txt
    fi
done

echo "$((num)) csv files cut for step windows."