configfile: "config.yaml"

rule all:
    input:
        expand("data/fastq/{sample}.fastq.gz", sample=config["samples"])

rule download_fastq:
    output: "data/fastq/{sample}.fastq.gz"
    log: "logs/download_fastq/{sample}.log"
    container: "https://zenodo.org/record/10894351/files/sratoolkit_3.1.0.img"
    shell:
        """
        fasterq-dump --threads 4 --progress --outdir data/fastq {wildcards.sample} > {log} 2>&1
        gzip data/fastq/{wildcards.sample}.fastq
        """

