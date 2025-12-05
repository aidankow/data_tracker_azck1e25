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

function create_table_for {
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

create_table_for fbmklci
create_table_for cpo
create_table_for sgdmyr
create_table_for usdmyr
create_table_for cnymyr
create_table_for gbpmyr
create_table_for hkdmyr
create_table_for twdmyr
create_table_for jypmyr
create_table_for nzdmyr
create_table_for audmyr
create_table_for eurmyr
create_table_for cadmyr
create_table_for chfmyr