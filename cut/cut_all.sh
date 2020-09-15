#!/bin/bash
#usage: ./make_all_data.sh [cutsteps_executable] [CUT] [STRIDE]
#run in top level directory containing subject directories
#combines and cuts all CSV files
#creates alldata.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 3 ]; then
    echo "usage: ./make_all_data.sh [cutsteps_executable] [CUT] [STRIDE]"
    exit 1
fi

num=0

echo "removing alldata.txt..."
rm alldata.txt

for d in ./*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./$1 $2 $3 $d"/Iregular/Sensor01.csv" $d"/Iregular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/Iregular/Sensor02.csv" $d"/Iregular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/Iregular/Sensor03.csv" $d"/Iregular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/Regular/Sensor01.csv" $d"/Regular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/Regular/Sensor02.csv" $d"/Regular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/Regular/Sensor03.csv" $d"/Regular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/SemiRegular/Sensor01.csv" $d"/SemiRegular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/SemiRegular/Sensor02.csv" $d"/SemiRegular/steps.txt" >> alldata.txt
        ./$1 $2 $3 $d"/SemiRegular/Sensor03.csv" $d"/SemiRegular/steps.txt" >> alldata.txt
    fi
done

echo "$((num)) cut for bite windows."