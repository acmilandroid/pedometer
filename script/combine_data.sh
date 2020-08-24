#!/bin/bash
#usage: ./combine_data.sh [cutsteps_executable] [filename.csv]
#creates regular.txt, semiregular.txt, irregular.txt, and alldata.txt

echo "Bash version ${BASH_VERSION}"

if [ "$#" -ne 2 ]; then
    echo "Usage: ./combine_data.sh [cutsteps_executable] [filename.csv]"
    exit 1
fi

#do for regular
echo "Cutting regular step data..."
((num=0))

for d in ./*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./$1 $d"/Regular/"$2 $d"/Regular/steps.txt" > output$((num)).out
    fi
done

echo "$((num)) cut for bite windows."
cat output* > regular.txt
rm output*

#do for semiregular
echo "Cutting semiregular step data..."
((num=0))

for d in ./*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./$1 $d"/SemiRegular/"$2 $d"/SemiRegular/steps.txt" > output$((num)).out
    fi
done

echo "$((num)) files cut for semiregular windows."
cat output* > semiregular.txt
rm output*

#do for irregular
echo "Cutting irregular step data..."
((num=0))

for d in ./*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))
        ./$1 $d"/Irregular/"$2 $d"/Irregular/steps.txt" > output$((num)).out
    fi
done

echo "$((num)) files cut for irregular windows."
cat output* > irregular.txt
rm output*

#create alldata file
echo "Creating alldata.txt file..."
cat regular.txt semiregular.txt irregular.txt > alldata.txt
echo "Done cutting data!"