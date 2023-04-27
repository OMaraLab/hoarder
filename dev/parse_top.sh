#!/bin/bash

#scan the file $1, should be a topology file
INFILE=$1
OUTPUT=""

while read line 
do 
    if [[ $line == "[ molecules ]" ]]
    then # find every line afterwards that includes a single unbroken string of characters, followed by whitespace of undetermined nonzero length, and then a number 
        while read line 
        do 
            if [[ $line != "\;*" ]] # skip lines that are commented out
                then 
                if [[ $line =~ ^([^[:blank:]]+)[[:blank:]]+([[:digit:]]+)  && ${BASH_REMATCH[2]} != "0" ]]  # match molecule name and number where number is non zero
                    then
                    OUTPUT="$OUTPUT${BASH_REMATCH[1]} ${BASH_REMATCH[2]}\n" # save all these lines to the variable
                fi 
            fi 
        done < "$INFILE" 
    fi 
done < "$INFILE"

# use awk to modify the output variable
MODIFIED=$(echo -e "$OUTPUT" | awk '{print $1}' | awk '!seen[$0]++' | sort) # exclude molecules already seen, sort alphabetically

FINAL=$(echo "$MODIFIED" | awk '{print "    - molecule-"$1}') # format as yaml list entries, user will need to change molecule to the relevant molecule type

# append to file
echo "$FINAL" >> atbrepo.yaml