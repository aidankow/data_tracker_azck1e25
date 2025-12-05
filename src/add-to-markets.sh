MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"
DATA_FILE="../textfiles/cleaned_data.csv"

while IFS=',' read -r MarketID MarketName Price Timestamp; do
    $MYSQL -u root my_market_tracker <<EOF
    INSERT INTO markets
    VALUES ('$MarketID', '$MarketName', '$MarketID-graph.png'
    );
EOF
done < "$DATA_FILE"