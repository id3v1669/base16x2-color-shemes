#!/usr/bin/env bash

for file in ./src/*.yml; do
    echo "File: $file"
    
    grep -oE 'base[0-9A-Fa-f]{2}: "[0-9A-Fa-f]{6}"*' $file | while IFS= read -r line; do
        # Extract HEX
        color=$(echo "$line" | grep -oP '(?<=: ")[0-9A-Fa-f]{6}')
        # HEX to RGB
        r=$(printf '%d' "0x${color:0:2}")
        g=$(printf '%d' "0x${color:2:2}")
        b=$(printf '%d' "0x${color:4:2}")

        colored_block=$(echo -e "\033[48;2;${r};${g};${b}m     \033[0m")
        echo "${line%%$comment} | $colored_block"
    done
done

#ps tried to use jq but I'm too dumb for that

# TODO: 
# * Output comments after colored_block
# * output propper theme names instead of file names