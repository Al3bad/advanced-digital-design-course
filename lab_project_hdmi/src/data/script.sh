
#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "[ERROR] Specify the image that you want to convert!"
    exit 1
fi

input="$1"
hexFile="`dirname $0`/out.txt"
output="`dirname $0`/img.mif"

echo $input
echo $hexFile
echo $output

# Covert img to hex values (txt)
convert $input txt: | tail -n +2  | awk '{print substr($3,2); }' > $hexFile

# Generate the .mif file
echo "WIDTH=24;" > "$output"
echo "DEPTH=34225;" >> "$output"
echo "ADDRESS_RADIX=HEX;" >> "$output"
echo "DATA_RADIX=HEX;" >> "$output"

echo "" >> "$output"

echo "CONTENT BEGIN" >> "$output"

i=0
while IFS= read -r line
do
    # echo "    $i : $line;" >> "$output"
    printf "\t%x : $line;\n" "$i" >> "$output"
    i=$((i+1))
done < "$hexFile"

echo "END;" >> "$output"


rm "$hexFile"
