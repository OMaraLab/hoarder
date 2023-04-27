#!/bin/bash

#scan the file system.top
INFILE=$1
OUTPUT=""

while read line 
do 
    if [[ $line == "[ molecules ]" ]]
    then # find every line afterwards that includes a single unbroken string of characters, followed by whitespace of undetermined nonzero length, and then a number 
        while read line 
        do 
            if [[ $line != "\;*" ]] 
                then 
                if [[ $line =~ ^([^[:blank:]]+)[[:blank:]]+([[:digit:]]+)  && ${BASH_REMATCH[2]} != "0" ]] 
                    then
                    OUTPUT="$OUTPUT${BASH_REMATCH[1]} ${BASH_REMATCH[2]}\n" # save all these lines to the variable
                fi 
            fi 
        done < "$INFILE" 
    fi 
done < "$INFILE"

# use awk to modify the output variable
MODIFIED=$(echo -e "$OUTPUT" | awk '{print $1}' | awk '!seen[$0]++' | sort)

FINAL=$(echo "$MODIFIED" | awk '{print "molecule-"$1}')

# append to file
echo "$FINAL" >> atbrepo.yaml