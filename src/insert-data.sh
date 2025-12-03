#!/bin/bash
awk -F, 'NR==FNR { map[$2]=$1; next } { $1 = map[$1]; print $0 }' OFS=, marketIDs.csv cleaned_data.csv > cleaned_data_with_ids.csv