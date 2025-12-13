#!/bin/bash
MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"
DATA_FILE="../textfiles/cleaned_data.csv"

if [ ! -x "$MYSQL" ]; then
    echo "Error: MySQL client not found: $MYSQL"
    exit 1
fi

if [ ! -f "$DATA_FILE" ]; then
    echo "Error: Data file not found: $DATA_FILE"
    exit 1
fi

CPO_OT=$(date -j -f "%H:%M:%S" "10:30:00" "+%s") # opening time: 10:30
CPO_CT=$(date -j -f "%H:%M:%S" "18:05:00" "+%s") # closing time: 18:00

FKLI_OT=$(date -j -f "%H:%M:%S" "08:45:00" "+%s") # opening time: 08:45
FKLI_CT=$(date -j -f "%H:%M:%S" "18:05:00" "+%s") # closing time: 5:15

line_no=0
while IFS=',' read -r MarketID MarketName Price Timestamp CurrentTime; do
    line_no=$((line_no + 1))
    
    CURRENT_TIME=$(date -j -f "%H:%M:%S" $CurrentTime "+%s")
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
    if [ $? -ne 0 ]; then
        echo "Line $line_no: MySQL insert failed (MarketID=$MarketID)"
        continue
    fi
done < "$DATA_FILE"