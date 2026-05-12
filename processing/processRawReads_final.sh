
#paths
workdir="/your/path"
#logdir=$workdir/log_run2
output=$workdir/output_run2_ad_rem
input=$workdir/raw_sequence_run2


# create directiories
mkdir -p $output/combined_paired_end/adapterremoval
mkdir -p $output/combined_paired_end/fastqc
mkdir -p $output/processed

#adapter_sequences, rc = reverse complement
CS1=TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG
CS1rc=CTGTCTCTTATACACATCTGACGCTGCCGACGA
CS2=GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG
CS2rc=CTGTCTCTTATACACATCTCCGAGCCCACGAGAC

#renaming, filtering loop
for R1 in ./*/*_R1.fastq; do
   
    R1=${R1##*/}
    R2=${R1/_R1.fastq/_R2.fastq}
    
    TMP="${R1%_R*}"; 
    S_ID=`echo ${TMP##*/}`
    echo ${S_ID} 

    # merge, adapter removal, quality and length filter
    AdapterRemoval --file1 $input/$R1 --file2 $input/$R2 --basename $output/combined_paired_end/adapterremoval/${S_ID}_output_paired --adapter1 $CS1 --adapter2 $CS2 --collapse --trimns  --trimqualities --minquality 20 --minlength 10 --maxlength 500 --qualitymax 50 --threads 14


    # quality test  
    fastqc ./output_run2_ad_rem/combined_paired_end/adapterremoval/$_output_paired.collapsed -o ./output_run2_ad_rem/combined_paired_end/fastqc

    # split samples based on barcodes
    AdapterRemoval --file1 ./output_run1_ad_rem/combined_paired_end/adapterremoval/collapsed --basename ./${S_ID}_processed --barcode-mm 1 --barcode-list 20250723_barcodes.txt --demultiplex-only


    # #sort according to primers
    cutadapt -g GGGCAATCCTGAGCCAA -a TTGGCTCAGGATTGCCC -g TTGAGTCTCTGCACCTATC -a GATAGGTGCAGAGACTCAA --no-trim --discard-untrimmed -o $output/processed/${S_ID}_trnL.fasta $output/combined_paired_end/adapterremoval/${S_ID}_output_paired.collapsed
    cutadapt -g CATTGTRGGTAATGTATTTGG -a CCAAATACATTACCYACAATG -g AGGGGACGACCATACTTGTTCA -a TGAACAAGTATGGTCGTCCCCT --no-trim --discard-untrimmed -o $output/processed/${S_ID}_rbcL.fasta $output/combined_paired_end/adapterremoval/${S_ID}_output_paired.collapsed

done
