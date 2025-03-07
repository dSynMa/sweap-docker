#!/bin/bash

old=$1
new=$2
echo "Tranform $old to $new"
echo "#LIA" > $new
sed 's/i\([0-9]\+\)()/int\1()/g' < $old | \
sed 's/le /lte /g' | \
sed 's/ge /gte /g' >> $new
