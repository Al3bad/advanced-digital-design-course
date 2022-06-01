
#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "[ERROR] Specify the image that you want to convert!"
    exit 1
fi

filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

if ! [[ $extension == "jpg" || $extension == "png" ]] ; then
    echo "[ERROR] Input file must be a jpg image!"
    exit 1
fi

input="$1"
hexFile="`dirname $0`/out.txt"
output="`dirname $0`/${filename}_img.mif"

echo $input
echo $hexFile
echo $output


# Covert img to hex values (txt)
convert $input txt: | tail -n +2  | awk '{print substr($3,2); }' > $hexFile

total_px=$(wc -l < $hexFile)
echo $total_px

# Generate the .mif file
# echo "WIDTH=24;" > "$output" # RGB
echo "WIDTH=8;" > "$output" # BW
echo "DEPTH=${total_px};" >> "$output"
echo "ADDRESS_RADIX=HEX;" >> "$output"
echo "DATA_RADIX=HEX;" >> "$output"

echo "" >> "$output"

echo "CONTENT BEGIN" >> "$output"

i=0
while IFS= read -r line
do
    # echo "    $i : $line;" >> "$output"
    # printf "\t%x : $line;\n" "$i" >> "$output"      # RGB
    printf "\t%x : ${line:0:2};\n" "$i" >> "$output"  # BW
    i=$((i+1))
done < "$hexFile"

echo "END;" >> "$output"


rm "$hexFile"
