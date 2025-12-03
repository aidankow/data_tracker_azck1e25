#!/bin/bash
MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"
# XAMPP_BIN="/Applications/XAMPP/xamppfiles/bin"

# echo "Starting Apache..."
# sudo "$XAMPP_BIN/apachectl" start

# echo "Starting MySQL..."
# sudo "$XAMPP_BIN/mysql.server" start

$MYSQL -u root -e "CREATE DATABASE IF NOT EXISTS my_market_tracker;"

$MYSQL -u root my_market_tracker <<EOF
CREATE TABLE IF NOT EXISTS Markets(
    MarketID VARCHAR(8) PRIMARY KEY,
    MarketName VARCHAR(256),
    GraphID VARCHAR(8)
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

create_table_for FBMKLCI
create_table_for CPO
create_table_for SGDMYR
create_table_for USDMYR
create_table_for CNYMYR
create_table_for GBPMYR
create_table_for HKDMYR
create_table_for TWDMYR
create_table_for JYPMYR
create_table_for NZDMYR
create_table_for AUDMYR
create_table_for EURMYR
create_table_for CADMYR
create_table_for CHFMYR