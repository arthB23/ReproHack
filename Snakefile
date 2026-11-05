configfile: "config.yaml"

rule all:
    input:
        expand("data/fastq/{sample}.trimmed.fastq.gz", sample=config["samples"]),
        "data/reference/reference.fasta",
        "data/reference/reference.gff"

rule download_fastq:
    output: "data/fastq/{sample}.fastq.gz"
    log: "logs/download_fastq/{sample}.log"
    container: "https://zenodo.org/record/10894351/files/sratoolkit_3.1.0.img"
    shell:
        """
        fasterq-dump --threads 4 --progress --outdir data/fastq {wildcards.sample} > {log} 2>&1
        gzip data/fastq/{wildcards.sample}.fastq
        """
rule download_genome:
    output: "data/reference/reference.fasta"
    log: "logs/download_genome.log"
    container: "docker://evolbioinfo/ubuntu:v24.04"
    shell:
        """
        wget -O {output} "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=CP000253.1&rettype=fasta" > {log} 2>&1
        """

rule download_annotation:
    output: "data/reference/reference.gff"
    log: "logs/download_annotation.log"
    container: "docker://evolbioinfo/ubuntu:v24.04"
    shell:
        """
        wget -O {output} "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1" > {log} 2>&1
        """

rule cutadapt:
    input: "data/fastq/{sample}.fastq.gz"
    output: "data/fastq/{sample}.trimmed.fastq.gz"
    log: "logs/cutadapt/{sample}.log"
    container: "https://zenodo.org/records/18834062/files/cutadapt_4.6.0.img"
    shell:"""cutadapt -q 20 -m 25 -a AGATCGGAAGAGC -o {output} {input} > {log} 2>&1"""
