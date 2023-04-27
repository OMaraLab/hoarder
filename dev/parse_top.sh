#!/bin/bash

#scan the file system.top
INFILE=$1

while read line 
do 
    if [[ $line == "[ molecules ]" ]]
    then # find every line afterwards that includes a single unbroken string of characters, followed by whitespace of undetermined nonzero length, and then a number 
        while read line 
        do 
            if [[ $line != "\;*" ]] 
                then 
                if [[ $line =~ ^([^[:blank:]]+)[[:blank:]]+([[:digit:]]+) ]] 
                    then
                    echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}" # print all these lines 
                fi 
            fi 
        done < "$INFILE" 
    fi 
done < "$INFILE"