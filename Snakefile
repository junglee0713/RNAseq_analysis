###===
### Rules for RNAseq processingfungal
###===

from helper import *

PROJECT_DIR = config["PROJECT_DIR"]
BARCODES = config["BARCODES"]
workdir: PROJECT_DIR
SAMPLE_IDS = get_sample_from_barcodes_file(PROJECT_DIR + "/" + BARCODES) 

onsuccess:
        print("Workflow finished, no error")
        shell("mail -s 'Workflow finished successfully' " + config["ADMIN_EMAIL"] + " < {log}")

onerror:
        print("An error occurred")
        shell("mail -s 'An error occurred' " + config["ADMIN_EMAIL"] + " < {log}")
                                  
