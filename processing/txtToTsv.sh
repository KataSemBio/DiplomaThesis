for f in *.txt; do
    echo "Upravuji formát pro Excel: $f"
    # Tento sed příkaz udělá dvě věci:
    # 1. 's/^[[:space:]]+//' -> Odstraní mezery/tabulátory na úplném začátku řádku
    # 2. 's/\t[[:space:]]+/\t/g' -> Najde tabulátor následovaný mezerami (to je to odsazení názvů) 
    #    a nahradí ho jen tabulátorem.
    sed -E 's/^[[:space:]]+//; s/\t[[:space:]]+/\t/g' "$f" > "cal_tsv_ready/${f%.txt}_clean.tsv"
done