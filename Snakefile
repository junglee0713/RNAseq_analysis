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
PCTID_ALNLEN_DIR = PROJECT_DIR + "/" + config["PCTID_ALNLEN_DIR"]
FILTERED_DIR = PROJECT_DIR + "/pctid_" + config["BLAST_FILTER"]["PCTID_CUT"] + "_alnpct_" + config["BLAST_FILTER"]["ALNPCT_CUT"]
FILTER_OUT_BEGIN = "pctid_" + config["BLAST_FILTER"]["PCTID_CUT"] + "_alnpct_" + config["BLAST_FILTER"]["ALNPCT_CUT"] 
CONTIG_INFO_DIR = PROJECT_DIR + "/" + config["CONTIG_INFO_DIR"]

workdir: PROJECT_DIR

rule all:
    input:
        expand(PCTID_ALNLEN_DIR + "/{sample}_against_{contig_name}.pctid_alnlen", sample = SAMPLE_IDS, contig_name = DB_LIST)

#rule all:
#    input:
#        expand(FILTERED_DIR + "/" + FILTER_OUT_BEGIN + "_{sample}_against_{contig_name}.blastout_filtered", sample = SAMPLE_IDS, contig_name = DB_LIST),
#        expand(CONTIG_INFO_DIR + "/{contig_name}.start_stop", contig_name = DB_LIST)

rule get_contig_start_stop:
    input: 
        config["CONTIGS_DB"] + "/{contig_name}" 
    output:
        CONTIG_INFO_DIR + "/{contig_name}.start_stop"
    params:
        OUTPUT_DIR = CONTIG_INFO_DIR
    shell:
        """
        mkdir -p {params.OUTPUT_DIR}
        awk '$1 ~ />cap3-contigs/ {{print $1, $3, $5}}' < {input} > {output}
        """

rule filter_blast:
    input: 
        BLASTOUT_DIR + "/{sample}_against_{contig_name}.blastout"
    params:
        OUTPUT_DIR = FILTERED_DIR,
        pctid = config["BLAST_FILTER"]["PCTID_CUT"],
        alnpct = config["BLAST_FILTER"]["ALNPCT_CUT"] 
    output:
        FILTERED_DIR + "/" + FILTER_OUT_BEGIN + "_{sample}_against_{contig_name}.blastout_filtered"
    shell:
        """
        mkdir -p {params.OUTPUT_DIR}
        awk -v pctid={params.pctid} -v alnpct={params.alnpct} 'BEGIN {{FS="\t"}} $3>pctid && $4>alnpct {{print $1, $2, $3, $4}}' < {input} > {output}
        """

rule get_pctid_alnlen:
    input:
        BLASTOUT_DIR + "/{sample}_against_{contig_name}.blastout"
    output:
        PCTID_ALNLEN_DIR + "/{sample}_against_{contig_name}.pctid_alnlen"
    params: 
        OUTPUT_DIR = PCTID_ALNLEN_DIR
    shell:
        """
        mkdir -p {params.OUTPUT_DIR}
        awk 'BEGIN {{FS="\t"}} {{print $3, 100*$4/($8 - $7 + 1)}}' < {input} > {output}
        """

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
