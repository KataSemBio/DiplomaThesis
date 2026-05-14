
### Metabarcoding data processing and visualisation ###
The DNA analysed in this study was from ancient dental calculus and sediment from the same burial. Amplicons of the isolated samples made with two sets of universal primers were sequenced.
Data processing starts with **processRawReads_final.sh**. Raw .FASTQ files from paired-end reads are required. The output is trimmed, filtered and ready for taxonomic assingment.
This can be done via blastn (**megaBlastRun.sh**) or Kraken2 (**getKrakenTaxonomyViaKraken2.sh**). To convert the files to .tsv for further processing and visualisation, **txtToTsv.sh** was used.
For filtering out taxa found in sediment and dental calculus, **Venn_diag.py** was used.
The amplification success and primer specificity was visualised with a bar plot for each material (sediment and calculus) separately (**readCountsPlt.py**). Further taxonomic assingment was evaluated by plotting stacked bar plots (**abs+relBarPlt.R**) and a heatmap (**genomicsHeatmap.R**).

### Proteomic data visualisation ###
Data processed via the MaxQuant environment were filtered and then visualised using a heatmap (**proteomicsHeatmap.R**).
