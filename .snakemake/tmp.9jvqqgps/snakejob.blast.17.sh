#!/bin/sh
# properties = {"local": false, "cluster": {"h_vmem": "8G", "mem_free": "6G", "m_mem_free": "5G"}, "jobid": 17, "input": ["/scr1/users/leej39/USDA_RUN22/R1_FASTA/D27.BAF_R1.fasta", "/scr1/users/leej39/USDA_RUN22/blast_against_contigs"], "resources": {}, "threads": 1, "params": {"db_path": "/scr1/users/leej39/USDA_RUN22/RUN12_blastdb/D13.BAF_genes_nucl.fa"}, "rule": "blast", "wildcards": ["D27.BAF", "D13.BAF_genes_nucl.fa"], "log": [], "output": ["/scr1/users/leej39/USDA_RUN22/blast_against_contigs/D27.BAF_against_D13.BAF_genes_nucl.fa.blastout"]}
cd /home/leej39/RNAseq_analysis && \
/home/leej39/miniconda3/envs/sunbeam/bin/python -m snakemake /scr1/users/leej39/USDA_RUN22/blast_against_contigs/D27.BAF_against_D13.BAF_genes_nucl.fa.blastout --snakefile /home/leej39/RNAseq_analysis/Snakefile \
--force -j --keep-target-files --keep-shadow --keep-remote \
--wait-for-files /home/leej39/RNAseq_analysis/.snakemake/tmp.9jvqqgps /scr1/users/leej39/USDA_RUN22/R1_FASTA/D27.BAF_R1.fasta /scr1/users/leej39/USDA_RUN22/blast_against_contigs --latency-wait 90 \
--benchmark-repeats 1 \
--force-use-threads --wrapper-prefix https://bitbucket.org/snakemake/snakemake-wrappers/raw/ \
 --configfile /home/leej39/RNAseq_analysis/config.yml -p --nocolor \
--notemp --quiet --no-hooks --nolock --printshellcmds  --force-use-threads  --allowed-rules blast  && touch "/home/leej39/RNAseq_analysis/.snakemake/tmp.9jvqqgps/17.jobfinished" || (touch "/home/leej39/RNAseq_analysis/.snakemake/tmp.9jvqqgps/17.jobfailed"; exit 1)

