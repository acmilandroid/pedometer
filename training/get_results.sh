#!/bin/bash
# Usage: ./get_results.sh [datafile]
# creates results.csv

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 1 ]; then
    echo "Usage: ./get_results.sh [datafile]"
    exit 1
fi

# number of subjects
num=30

# write CSV file of data
echo "Subject,Gait,Sensor,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > results.csv

# grab important result data and make temp file
pcregrep -M "TP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRun count accuracy:.*\nStep detection accuracy F1 Score:.*" $1 | sed 's/^.*: //' > important_results.txt

line=0

# write data to csv file
for (( i = 0; i < $num; i++ )) do

    ((print = i + 1 ))
    echo "Subject $print"
    
    for (( j = 0; j < 3; j++ )) do

        # get line index
        ((line = 63 * $i + 21 * $j))

        # regular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> results.csv
        echo -n "regular," >> results.csv
        ((print = j + 1 ))
        echo -n "$print," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv

        # irregular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> results.csv
        echo -n "irregular," >> results.csv
        ((print = j + 1 ))
        echo -n "$print," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv

        # semiregular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> results.csv
        echo -n "semiregular," >> results.csv
        ((print = j + 1 ))
        echo -n "$print," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv
        truncate -s -1 results.csv
        echo -n "," >> results.csv
        ((line++))
        sed "${line}q;d" important_results.txt >> results.csv

    done
done

rm important_results.txt

echo "$((num)) subjects tested."