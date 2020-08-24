#!/bin/bash
#usage: ./combine_data.sh [cutsteps_executable] [filename.csv]
#creates finaldata.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 2 ]; then
    echo "Usage: ./combine_data.sh [cutsteps_executable] [filename.csv]"
    exit 1
fi

num=0

echo "removing finaldata.txt..."
rm finaldata.txt

for d in ./*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./$1 $d"/"$2 $d"/steps.txt" > output$((num)).out
    fi
done

echo "$((num)) cut for bite windows."

for ((i = 1; i <= num; i++)); do
    cat "output${i}.out" >> finaldata.txt    
done

rm output*