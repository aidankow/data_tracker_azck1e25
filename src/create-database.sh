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

if [ ! -f "$DATA_FILE" ]; then
    echo "Error: Data file not found: $DATA_FILE"
    exit $MISSING_FILE
fi

$MYSQL -u root -e "CREATE DATABASE IF NOT EXISTS my_market_tracker;"

function create_table2dp_for {
    $MYSQL -u root my_market_tracker <<EOF
    CREATE TABLE IF NOT EXISTS $1 (
        DataPointID INT AUTO_INCREMENT PRIMARY KEY,
        MarketID VARCHAR(8),
        Price DECIMAL(10,2),
        Timestamp DATETIME,
        FOREIGN KEY (MarketID) REFERENCES markets(MarketID)
    );
EOF
}

function create_table4dp_for {
    $MYSQL -u root my_market_tracker <<EOF
    CREATE TABLE IF NOT EXISTS $1 (
        DataPointID INT AUTO_INCREMENT PRIMARY KEY,
        MarketID VARCHAR(8),
        Price DECIMAL(10,4),
        Timestamp DATETIME,
        FOREIGN KEY (MarketID) REFERENCES markets(MarketID)
    );
EOF
}

$MYSQL -u root my_market_tracker <<EOF
CREATE TABLE IF NOT EXISTS markets(
    MarketID VARCHAR(8) PRIMARY KEY,
    MarketName VARCHAR(256),
    GraphID VARCHAR(64)
);
EOF

while IFS=',' read -r MarketID MarketName Price Timestamp; do
    $MYSQL -u root my_market_tracker <<EOF
    INSERT INTO markets
    VALUES ('$MarketID', '$MarketName', '$MarketID-graph.png'
    );
EOF
done < "$DATA_FILE"

create_table2dp_for fbmklci
create_table2dp_for cpo
create_table4dp_for sgdmyr
create_table4dp_for usdmyr
create_table4dp_for cnymyr
create_table4dp_for gbpmyr
create_table4dp_for hkdmyr
create_table4dp_for twdmyr
create_table4dp_for jypmyr
create_table4dp_for nzdmyr
create_table4dp_for audmyr
create_table4dp_for eurmyr
create_table4dp_for cadmyr
create_table4dp_for chfmyr