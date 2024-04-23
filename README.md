# Bacterial Genome Assembly and Analysis Pipeline

This Nextflow pipeline performs the following tasks:

1. Read trimming using fastp
2. Read assembly using skesa
3. Quality assessment of assembled contigs using QUAST
4. Multi-Locus Sequence Typing (MLST) of assembled contigs

## Prerequisites

- Nextflow (>=21.04.0)
- Docker (optional, if running processes in containers)

The following tools are required and should be installed or available in containers:

- fastp (0.23.3 or later)
- skesa (2.5.1 or later)
- QUAST (5.2.0 or later)
- mlst (2.19.0 or later)

## Usage

1. Clone or download this repository.
2. Navigate to the repository directory.
3. Run the pipeline using the following command:

```bash
   nextflow readassembly.nf --reads {some/path/*{1,2}.fq.gz} --outdir {your/output/dir/} --quality_threshold 30
```

## Parameters

The following parameters can be modified in the `main.nf` script:

- `params.outdir`: Path to the output directory (default: `'./results/'`)
- `params.quality_threshold`: Quality threshold for fastp (default: `30`)
- `params.reads`: Pattern for input FASTQ files (default: `"./raw_reads/SRR*_{1,2}.fastq.gz"`)

## Output

The pipeline will generate the following output directories:

- `results/trim/`: Trimmed reads (FASTQ files)
- `results/asm/`: Assembled contigs (FASTA files)
- `results/quast/`: QUAST quality assessment reports
- `results/mlst/`: MLST results (TSV files)

## Docker Containers

If you want to run the pipeline using Docker containers, uncomment the relevant container lines in the `main.nf` script and ensure that the specified container images are available on your system.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you encounter any problems or have suggestions for improvements.
