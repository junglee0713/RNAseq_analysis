###===
### Rules for RNAseq processingfungal
### BLAST against contigs
###===

from helper import *

PROJECT_DIR = config["PROJECT_DIR"]
BARCODES = config["BARCODES"]
SAMPLE_IDS = get_sample_from_barcodes_file(PROJECT_DIR + "/" + BARCODES) 
DB_LIST = get_db_list(config["CONTIGS_DB"], fasta_extension = ".fa")
BLASTOUT_DIR = PROJECT_DIR + "/" + config["BLASTOUT_DIR"]
DECONTAM_DIR = PROJECT_DIR + "/" + config["SUNBEAM_OUTPUT_DIR"] + "/" + config["QC_DIR"] + "/" + config["DECONTAM_DIR"]
R1_FASTA_DIR = PROJECT_DIR + "/" + config["R1_FASTA_DIR"]
workdir: PROJECT_DIR

rule all:
    input:
        expand(BLASTOUT_DIR + "/{sample}_against_{contig_name}.blastout", sample = SAMPLE_IDS, contig_name = DB_LIST)

rule blast:
    input: 
        OUTPUT_DIR = BLASTOUT_DIR,
        R1_FASTA = R1_FASTA_DIR + "/{sample}_R1.fasta"
    params:
        db_path = config["CONTIGS_DB"] + "/{contig_name}"
    output: 
        BLASTOUT_DIR + "/{sample}_against_{contig_name}.blastout"     
    shell:
        """
        mkdir -p {input.OUTPUT_DIR}
        blastn -query {input.R1_FASTA} -evalue 1e-5 -outfmt 6 \
        -db {params.db_path} \
        -out {output} -num_threads 8 -max_target_seqs 10
        """   

rule get_R1_fasta:
    input: 
        OUTPUT_DIR = R1_FASTA_DIR,
        R1_FASTQ = DECONTAM_DIR + "/{sample}_R1.fastq.gz"
    output: 
        R1_FASTA_DIR + "/{sample}_R1.fasta"
    shell:
        """
        mkdir -p {input.OUTPUT_DIR}
        vsearch --fastq_filter {input.R1_FASTQ} \
        --fastaout {output} 
        """

onsuccess:
    print("Workflow finished, no error")
    shell("mail -s 'Workflow finished successfully' " + config["ADMIN_EMAIL"] + " < {log}")

onerror:
    print("An error occurred")
    shell("mail -s 'An error occurred' " + config["ADMIN_EMAIL"] + " < {log}")
