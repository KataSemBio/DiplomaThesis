# finds all .fasta files in path and runs taxonomic assignment via Kraken2

INPUT=/your/path/output_run2_ad_rem/processed
OUTPUT=/your/path


for FFILE in ./output_run2_ad_rem/processed/*.fasta; do
    NEWNAME="${FFILE##*/}"
    echo "${NEWNAME}"

    kraken2 --db /your/path/cp_db \
            --threads 14 \
            --minimum-base-quality 20 \
            --confidence 0.1 \
            --classified-out ${OUTPUT}/${NEWNAME}_classified.fasta \
            --report ${OUTPUT}/${NEWNAME}.txt \
            \
            ${INPUT}/${NEWNAME}      
done


# runs bracken on all the .fasta files

for FFILE in ./*.fasta; do
    NEWNAME="${FFILE##*/}"
    echo "${NEWNAME}"
    bracken -d /your/path/cp_db \
            -i ${FFILE} \
            -o ${NEWNAME}.bracken \
            
done