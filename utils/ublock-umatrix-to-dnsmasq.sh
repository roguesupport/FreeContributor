#!/bin/sh

# Extract blocked domains from uMatrix or uBlock Origin rules
# uMatrix https://github.com/gorhill/uMatrix/
# uBlock Origin https://github.com/gorhill/uBlock
#
# input: 
#  - filename from uMatrix (default my-umatrix-rules.txt)
#  - filename from uBlock (default my-ublock-dynamic-rules-date.txt)

file=$1

head -n 20 $file

## remove the header
echo "Wich line starts the blocking domains?"
read header;

echo "The blocked domains starts at line $((header + 1))"
tail -n +$((header + 1)) $file | \
grep "block" | \
sort | uniq | \
awk '{print "address=/"$2"/"}' > dnsmasq-umatrix.conf

echo "Domains extracted successful"
echo "Number of domains extracted are: $(wc -l dnsmasq-umatrix.conf)"
echo "The domains are stored in filename dnsmasq-umatrix.conf"