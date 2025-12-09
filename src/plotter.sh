MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"

function fetch_plots_for {
    $MYSQL -u root my_market_tracker <<EOF | tail -n +2 > "$2"
    SELECT Timestamp, Price FROM $1 ORDER BY Timestamp;
EOF
}

function create_graph_for {
    gnuplot <<EOF
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set terminal pngcairo size 1200,600
        set output "$1"
        set grid
        set title "$3"
        set xlabel "Timestamp"
        set ylabel "Price"
        set format x "%y-%m-%d\n%H:%M"
        plot "$2" using 1:2 with lines linewidth 2 title "Price"
EOF
}

function iterate_markets {
    MARKETS_FILE="../textfiles/marketIDs.txt"
    while IFS= read -r MarketID; do
        OUTPUT_FILE="../plots/$MarketID.dat"
        GRAPH_NAME=$($MYSQL -u root -N my_market_tracker -e "SELECT GraphID FROM markets WHERE MarketID='$MarketID';")
        GRAPH_FILE="../graphs/$GRAPH_NAME"
        MarketName=$($MYSQL -u root -N my_market_tracker -e "SELECT MarketName FROM markets WHERE MarketID='$MarketID';")

        fetch_plots_for $MarketID $OUTPUT_FILE
        create_graph_for $GRAPH_FILE $OUTPUT_FILE "$MarketName"
    done < $MARKETS_FILE
}

iterate_markets