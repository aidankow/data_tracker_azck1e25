#!/bin/bash

set -e

#exit codes:
UNEXPECTED_ERROR=99
MYSQL_FAIL=100
MISSING_FILE=101

trap 'echo "(ERROR) Script failed at line $LINENO" >&2; exit $UNEXPECTED_ERROR' ERR

MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"
DATA_FILE="../textfiles/cleaned_data.csv"

if [ ! -x "$MYSQL" ]; then
    echo "Error: MySQL client not found: $MYSQL"
    exit $MYSQL_FAIL
fi

if [ ! -s "$DATA_FILE" ]; then
    echo "Error: Data file not found or is empty: $DATA_FILE"
    exit $MISSING_FILE
fi

CPO_OT=$(date -j -f "%H:%M:%S" "10:30:00" "+%s") # opening time: 10:30
CPO_CT=$(date -j -f "%H:%M:%S" "18:05:00" "+%s") # closing time: 18:00

FKLI_OT=$(date -j -f "%H:%M:%S" "08:45:00" "+%s") # opening time: 08:45
FKLI_CT=$(date -j -f "%H:%M:%S" "18:05:00" "+%s") # closing time: 5:15

while IFS=',' read -r MarketID MarketName Price Timestamp; do
    Time=$(echo "$Timestamp" | cut -d' ' -f2)
    if ! CURRENT_TIME=$(date -j -f "%H:%M:%S" "$Time" "+%s"); then
        echo "(ERROR) Invalid time '$Time'" >&2
        continue
    fi

    if [[ "$MarketID" == "CPO" ]]; then
        if (( CURRENT_TIME < CPO_OT || CURRENT_TIME > CPO_CT )); then
            continue;
        fi
    elif [[ "$MarketID" == "FBMKLCI" ]]; then
        if (( CURRENT_TIME < FKLI_OT || CURRENT_TIME > FKLI_CT )); then
            continue;
        fi
    fi

    $MYSQL -u root my_market_tracker <<EOF
    INSERT INTO $MarketID (MarketID, Price, Timestamp) 
    VALUES ('$MarketID', '$Price', '$Timestamp');
EOF
done < "$DATA_FILE"