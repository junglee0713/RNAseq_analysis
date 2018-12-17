def get_sample_from_barcodes_file(sample_fp):
    DELIMITER = '\t'
    SAMPLES = []
    with open(sample_fp) as f:
        for line in f:
            sample = line.split(DELIMITER)[0]
            SAMPLES.append(sample)
    return(SAMPLES)
