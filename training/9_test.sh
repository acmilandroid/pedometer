#!/bin/bash
# Basil Lin
# Step counter project
# Tests every {gait, sensor} pair CSV file for RCA and SDA using a trained input model [input_model.h5]
# Usage: ./9_test.sh [directory] [window_size] [window_stride] [model_directory] [normalization_type] [output_file.csv]
# [directory] is top level dir containing all subject files
# [model_directory] is top level dir containing trained models
# [normalization_type] 0 for per sensor per axis, 1 for -1.5 to 1.5 gravities
# cutsteps executable must be compiled in ../cut/cutsteps
# creates [output_file.csv]

echo "Bash version ${BASH_VERSION}"

# usage warning
if [ "$#" -ne 6 ]; then
    echo "Usage: ./9_test.sh [directory] [window_size] [window_stride] [model_directory] [normalization_type] [output_file.csv]"
    exit 1
fi

num=0

# remove old training data
echo "Removing old data..."
rm ALL_ALL_ALL_important.txt &> /dev/null
rm ALL_ALL_ALL_results.txt &> /dev/null
rm -r temp_testing_data &> /dev/null
rm predicted_steps_sensor* &> /dev/null
mkdir temp_testing_data &> /dev/null

# loop through all subdirectories
for d in $1*; do
    if [ -d "$d" ]; then
        echo "$d"
        ((num++))

        # remove old temporary training data
        echo "Removing old training data..."
        rm -r temp_testing_data/* &> /dev/null

        # cut gait and sensor
        for ((sensor=1; sensor<=3; sensor++)) do
            echo "Cutting Sensor0$sensor"
            ./../cut/cutsteps $2 $3 $d"/Regular/Sensor0$sensor.csv" $d"/Regular/steps.txt" > "temp_testing_data/"$num"_Regular_"$sensor"_cut.txt"
            ./../cut/cutsteps $2 $3 $d"/SemiRegular/Sensor0$sensor.csv" $d"/SemiRegular/steps.txt" > "temp_testing_data/"$num"_SemiRegular_"$sensor"_cut.txt"
            ./../cut/cutsteps $2 $3 $d"/Irregular/Sensor0$sensor.csv" $d"/Irregular/steps.txt" > "temp_testing_data/"$num"_Irregular_"$sensor"_cut.txt"
        done

        # normalize per axis per sensor
        if (($5 == 0)); then
            echo "Normalizing per axis per sensor..."
            for ((sensor=1; sensor<=3; sensor++)) do
                echo "Normalizing Sensor0$sensor"
                python3 ../cut/normalize.py "temp_testing_data/"$num"_Regular_"$sensor"_cut.txt" "temp_testing_data/"$num"_Regular_"$sensor"_norm.txt" 0 $sensor > /dev/null
                python3 ../cut/normalize.py "temp_testing_data/"$num"_SemiRegular_"$sensor"_cut.txt" "temp_testing_data/"$num"_SemiRegular_"$sensor"_norm.txt" 0 $sensor > /dev/null
                python3 ../cut/normalize.py "temp_testing_data/"$num"_Irregular_"$sensor"_cut.txt" "temp_testing_data/"$num"_Irregular_"$sensor"_norm.txt" 0 $sensor > /dev/null
            done
        fi

        # normalize from -1.5 to 1.5 gravities
        if (($5 == 1)); then
            echo "Normalizing from -1.5 to 1.5 gravities..."
            for ((sensor=1; sensor<=3; sensor++)) do
                echo "Normalizing Sensor0$sensor"
                python3 ../cut/normalize.py "temp_testing_data/"$num"_Regular_"$sensor"_cut.txt" "temp_testing_data/"$num"_Regular_"$sensor"_norm.txt" 1 > /dev/null
                python3 ../cut/normalize.py "temp_testing_data/"$num"_SemiRegular_"$sensor"_cut.txt" "temp_testing_data/"$num"_SemiRegular_"$sensor"_norm.txt" 1 > /dev/null
                python3 ../cut/normalize.py "temp_testing_data/"$num"_Irregular_"$sensor"_cut.txt" "temp_testing_data/"$num"_Irregular_"$sensor"_norm.txt" 1 > /dev/null
            done
        fi

        # test models
        echo "Testing..."
        for ((sensor=1; sensor<=3; sensor++)) do
            echo "Testing Sensor0$sensor"
            python3 test_model.py $4"/ALL_Regular_"$sensor"_model.h5" $2 "temp_testing_data/"$num"_Regular_"$sensor"_norm.txt" $d"/Regular/steps.txt" 0 "temp_testing_data/ALL_Regular_"$sensor"_debug.csv" > /dev/null
            python3 test_model.py $4"/ALL_SemiRegular_"$sensor"_model.h5" $2 "temp_testing_data/"$num"_SemiRegular_"$sensor"_norm.txt" $d"/SemiRegular/steps.txt" 0 "temp_testing_data/ALL_SemiRegular_"$sensor"_debug.csv" > /dev/null
            python3 test_model.py $4"/ALL_Irregular_"$sensor"_model.h5" $2 "temp_testing_data/"$num"_Irregular_"$sensor"_norm.txt" $d"/Irregular/steps.txt" 0 "temp_testing_data/ALL_Irregular_"$sensor"_debug.csv" > /dev/null
        done
        
    fi
done

# grab important result data and make temp file
pcregrep -M "TP:.*\nFP:.*\nFN:.*\nPPV:.*\nSensitivity:.*\nRun count accuracy:.*\nStep detection accuracy F1 Score:.*" ALL_ALL_ALL_results.txt | sed 's/^.*: //' > ALL_ALL_ALL_important.txt

# write data to csv file
line=0
echo "Subject,Gait,Sensor,TP,FP,FN,PPV,Sensitivity,RCA,SDA" > $6

for (( i = 0; i < $num; i++ )) do

    ((print = i + 1 ))
    echo "Subject $print"
    
    for (( j = 0; j < 3; j++ )) do

        # get line index
        ((line = 63 * $i + 21 * $j))

        # regular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> $6
        echo -n "regular," >> $6
        ((print = j + 1 ))
        echo -n "$print," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6

        # irregular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> $6
        echo -n "irregular," >> $6
        ((print = j + 1 ))
        echo -n "$print," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6

        # semiregular sensor data
        ((print = i + 1 ))
        echo -n "$print," >> $6
        echo -n "semiregular," >> $6
        ((print = j + 1 ))
        echo -n "$print," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6
        truncate -s -1 $6
        echo -n "," >> $6
        ((line++))
        sed "${line}q;d" ALL_ALL_ALL_important.txt >> $6

    done
done

rm ALL_ALL_ALL_important.txt
rm ALL_ALL_ALL_results.txt
rm -r temp_testing_data

echo "$((num)) subjects tested."