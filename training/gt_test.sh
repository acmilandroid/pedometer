#!/bin/bash
# Usage: ./gt_test.sh [directory]
# tests ground truth files for spaces
# [directory] is top level dir containing all subject files

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 1 ]; then
    echo "Usage: ./example_test.sh [directory]"
    exit 1
fi

num=0

for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d/Regular/steps.txt"
        grep '^$' $d"/Regular/steps.txt"
        echo "$d/Irregular/steps.txt"
        grep '^$' $d"/Irregular/steps.txt"
        echo "$d/SemiRegular/steps.txt"
        grep '^$' $d"/SemiRegular/steps.txt"
    fi
done