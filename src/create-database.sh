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

$MYSQL -u root -e "CREATE DATABASE IF NOT EXISTS my_market_tracker;"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create database"
    exit 1
fi

function create_table2dp_for {
    $MYSQL -u root my_market_tracker <<EOF
    CREATE TABLE IF NOT EXISTS $1 (
        DataPointID INT AUTO_INCREMENT PRIMARY KEY,
        MarketID VARCHAR(8),
        Price DECIMAL(10,2),
        Timestamp DATETIME,
        FOREIGN KEY (MarketID) REFERENCES Markets(MarketID)
    );
EOF
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create table $1"
        exit 1
    fi
}

function create_table4dp_for {
    $MYSQL -u root my_market_tracker <<EOF
    CREATE TABLE IF NOT EXISTS $1 (
        DataPointID INT AUTO_INCREMENT PRIMARY KEY,
        MarketID VARCHAR(8),
        Price DECIMAL(10,4),
        Timestamp DATETIME,
        FOREIGN KEY (MarketID) REFERENCES Markets(MarketID)
    );
EOF
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create table $1"
        exit 1
    fi
}

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

$MYSQL -u root my_market_tracker <<EOF
CREATE TABLE IF NOT EXISTS markets(
    MarketID VARCHAR(8) PRIMARY KEY,
    MarketName VARCHAR(256),
    GraphID VARCHAR(64)
);
EOF
if [ $? -ne 0 ]; then
    echo "Error: Failed to create markets table"
    exit 1
fi

line_no=0
while IFS=',' read -r MarketID MarketName Price Timestamp; do
    line_no=$((line_no + 1))
    $MYSQL -u root my_market_tracker <<EOF
    INSERT INTO markets
    VALUES ('$MarketID', '$MarketName', '$MarketID-graph.png'
    );
EOF
if [ $? -ne 0 ]; then
    echo "Error: Failed to insert market on line $line_no ($MarketID)"
    exit 1
fi
done < "$DATA_FILE"