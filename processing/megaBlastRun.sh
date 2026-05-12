# CALCULUS OR SEDIMENT
# finds all .fasta files in path and runs taxonomic assignment via blastn

INPUT=/your/path/output_run2_ad_rem/processed
OUTPUT=/your/path

for FFILE in /your/path/output_run2_ad_rem/processed/*.fasta; do
    
    NEWNAME="${FFILE##*/}"
    echo "${NEWNAME}"
  
    blastn -query ${INPUT}/${NEWNAME} -db chloroplast_db -num_threads 14 -task megablast -evalue 1e-20 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle" -out ${OUTPUT}/${NEWNAME}.tsv;


done