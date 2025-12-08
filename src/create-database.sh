#!/bin/bash
# XAMPP_BIN="/Applications/XAMPP/xamppfiles/bin"

# echo "Starting Apache..."
# sudo "$XAMPP_BIN/apachectl" start

# echo "Starting MySQL..."
# sudo "$XAMPP_BIN/mysql.server" start

MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"

$MYSQL -u root -e "CREATE DATABASE IF NOT EXISTS my_market_tracker;"

$MYSQL -u root my_market_tracker <<EOF
CREATE TABLE IF NOT EXISTS markets(
    MarketID VARCHAR(8) PRIMARY KEY,
    MarketName VARCHAR(256),
    GraphID VARCHAR(64)
);
EOF

function create_table1_for {
    $MYSQL -u root my_market_tracker <<EOF
    CREATE TABLE IF NOT EXISTS $1 (
        DataPointID INT AUTO_INCREMENT PRIMARY KEY,
        MarketID VARCHAR(8),
        Price DECIMAL(10,2),
        Timestamp DATETIME,
        FOREIGN KEY (MarketID) REFERENCES Markets(MarketID)
    );
EOF
}

function create_table2_for {
    $MYSQL -u root my_market_tracker <<EOF
    CREATE TABLE IF NOT EXISTS $1 (
        DataPointID INT AUTO_INCREMENT PRIMARY KEY,
        MarketID VARCHAR(8),
        Price DECIMAL(10,4),
        Timestamp DATETIME,
        FOREIGN KEY (MarketID) REFERENCES Markets(MarketID)
    );
EOF
}

create_table1_for fbmklci
create_table1_for cpo
create_table2_for sgdmyr
create_table2_for usdmyr
create_table2_for cnymyr
create_table2_for gbpmyr
create_table2_for hkdmyr
create_table2_for twdmyr
create_table2_for jypmyr
create_table2_for nzdmyr
create_table2_for audmyr
create_table2_for eurmyr
create_table2_for cadmyr
create_table2_for chfmyr