def get_sample_from_barcodes_file(sample_fp):
    DELIMITER = "\t"
    SAMPLES = []
    with open(sample_fp) as f:
        for line in f:
            sample = line.split(DELIMITER)[0]
            SAMPLES.append(sample)
    return(SAMPLES)

def get_db_list(db_dir, fasta_extension = ".fa"):
    import os
    db_list = []
    for file in os.listdir(db_dir):
        if file.endswith(fasta_extension):
            db_list.append(file)
    return(db_list)
