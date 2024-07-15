rule all:
    input:
        "rna_featurecounts.txt"

rule QC:
    input:
        fastq="/home/bharath/pipelines/rna_pipeline/fastq/rna.fastq"        
    output:
        "rna_fastqc.zip",
        "rna_fastqc.html"
    shell:
        "fastqc {input.fastq} -o output/"

rule trim:
    input:
        trimjar="/home/bharath/pipelines/Trimmomatic-0.39/trimmomatic-0.39.jar",
        fastq="/home/bharath/pipelines/rna_pipeline/fastq/rna.fastq"   
    
    output:
        "rna_trimmed.fastq"
    
    
    shell:
        "java -jar {input.trimjar} SE -threads 4 {input.fastq} rna_trimmed.fastq TRAILING:10 -phred33"
        
rule hisat:
    input:
        index="/home/bharath/pipelines/rna_pipeline/grch38",
        fastq="rna_trimmed.fastq"
    
    output:
        "rna_trimmed.bam"
    
    shell:
        "hisat2 -q --rna-strandness R -x {input.index}/genome -U {input.fastq} | samtools sort -o rna_trimmed.bam"
        
rule featurecounts:
    input:
        annotation="/home/bharath/pipelines/rna_pipeline/Homo_sapiens.GRCh38.106.gtf",
        bam="rna_trimmed.bam"
    
    output:
        "rna_featurecounts.txt"
    
    shell:
        "featureCounts -S 2 -a {input.annotation} -o rna_featurecounts.txt {input.bam}"
