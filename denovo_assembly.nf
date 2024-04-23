#!/usr/bin/env nextflow

// Set the output directory for the results
params.outdir = './results/'

// Parameters for fastp
params.quality_threshold = 30  // Quality threshold for fastp
params.reads = "./raw_reads/SRR*_{1,2}.fastq.gz"  // Pattern for input FASTQ files

// Create a channel from the input file pairs
reads_ch_pairs = Channel.fromFilePairs(params.reads, checkIfExists:true)

// Log the parameters
log.info """\\
LIST OF PARAMETERS
================================
GENERAL
Results-folder : $params.outdir
================================
INPUT & REFERENCES
Input-files : $params.reads
================================
FASTP
quality threshold: $params.quality_threshold
================================
SKESA
================================
"""

// Process for read trimming using fastp
process READTRIM {
    publishDir "$params.outdir/trim/", mode: 'copy', overwrite: true  // Publish trimmed reads to output directory
    //container 'quay.io/biocontainers/fastp:0.23.3--h5f740d0_0'  // Container image for fastp

    input:
    tuple val(sample), path(reads)  // Input channel with sample name and read files

    output:
    tuple val("${sample}"), path("${sample}*.fq.gz"), emit: trim_fq  // Output channel with sample name and trimmed reads

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} -o ${sample}_R1.fq.gz -O ${sample}_R2.fq.gz -3 -M 30  // Run fastp for read trimming
    """
}

// Process for read assembly using skesa
process READASSEMBLY {
    publishDir "$params.outdir/asm/", mode: 'copy', overwrite: true  // Publish assembled contigs to output directory
    //container 'quay.io/biocontainers/skesa:2.5.1--hdcf5f25_0'  // Container image for skesa

    input:
    tuple val(sample), path(reads)  // Input channel with sample name and trimmed reads

    output:
    tuple val("${sample}"), path("${sample}*.fna"), emit: skesa  // Output channel with sample name and assembled contigs

    script:
    """
    skesa --reads ${reads[0]} ${reads[1]} --contigs_out ${sample}_skesa.fna  // Run skesa for read assembly
    """
}

// Process for quality assessment using quast
process QUALITY_ASSESSMENT {
    publishDir "$params.outdir/quast/", mode: 'copy', overwrite: true  // Publish QUAST results to output directory
    //container 'quay.io/biocontainers/quast:5.2.0--py38h1c8e9b9_2'  // Container image for quast

    input:
    tuple val(sample), path(skesa)  // Input channel with sample name and assembled contigs

    output:
    path("quast_results_${sample}"), emit: quast  // Output channel with QUAST results directory

    script:
    """
    quast.py -o quast_results_${sample} ${skesa}  // Run quast for quality assessment
    """
}

// Process for MLST (Multi-Locus Sequence Typing)
process MLST {
    publishDir "$params.outdir/mlst/", mode: 'copy', overwrite: true  // Publish MLST results to output directory
    //container 'quay.io/biocontainers/mlst:2.19.0--pl5321h87f3376_4'  // Container image for mlst

    input:
    tuple val(sample), path(skesa)  // Input channel with sample name and assembled contigs

    output:
    tuple val("${sample}"), path("${sample}*.tsv"), emit: mlst  // Output channel with MLST results file

    script:
    """
    mlst ${skesa} > ${sample}_MLST_Summary.tsv  // Run mlst for Multi-Locus Sequence Typing
    """
}

// Workflow
workflow {
    READTRIM(reads_ch_pairs)  // Run the READTRIM process with input read pairs
    results = READASSEMBLY(READTRIM.out.trim_fq)  // Run the READASSEMBLY process with trimmed reads
    quast_results = QUALITY_ASSESSMENT(results)  // Run the QUALITY_ASSESSMENT process with assembled contigs
    mlst_results = MLST(results)  // Run the MLST process with assembled contigs
}