# NGS Toolkit Docker Environment

A reproducible Linux environment for common NGS (next-generation sequencing)
preprocessing tools, built with Docker and conda/bioconda. Originally set up
to run whole-genome sequencing tools on a MacBook without needing a native
Linux machine.

## Tools included

- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) — read quality control
- [Trimmomatic](https://github.com/usadellab/Trimmomatic) — adapter/quality trimming
- [BWA-MEM](https://github.com/lh3/bwa) — short-read alignment
- [HISAT2](http://daehwankimlab.github.io/hisat2/) — spliced aligner (RNA-seq)
- [samtools](https://www.htslib.org/) — SAM/BAM file manipulation
- [GATK4](https://gatk.broadinstitute.org/) — variant calling & BQSR

All installed via the [bioconda](https://bioconda.github.io/) channel inside
a [Miniforge](https://github.com/conda-forge/miniforge)-based image.

## Prerequisites

- [Docker Desktop](https://docs.docker.com/desktop/) installed and running

## Build the image

```bash
git clone https://github.com/<your-username>/ngs-docker.git
cd ngs-docker
docker build -t ngs-tools .
```

## Run it

```bash
mkdir -p ~/ngs-data
docker run -it --rm -v ~/ngs-data:/data ngs-tools bash
```

Any files placed in `~/ngs-data` on your host machine are available inside
the container at `/data`.

## Example usage

See `examples/run_alignment_pipeline.sh` for a full example, covering:

1. Quality control (FastQC)
2. Paired-end adapter/quality trimming (Trimmomatic)
3. Reference indexing (BWA, samtools, GATK)
4. Alignment with read-group tagging (BWA-MEM)
5. SAM → BAM conversion (samtools)
6. Mate-information fixing and duplicate marking (samtools)
7. Base quality score recalibration (GATK4)
8. Germline variant calling (GATK4 HaplotypeCaller)

The result is a VCF file listing candidate genetic variants for the sample.

### External reference files needed

- a reference genome FASTA (e.g. `hg38.fa`)
- a known-sites VCF (e.g. dbSNP from gark.broadinstitute.org's Google Cloud bucket) for BSQR

## Project structure

```
ngs-docker/
├── Dockerfile
├── README.md
├── LICENSE
├── .dockerignore
└── examples/
    └── run_fastqc_trimmomatic.sh
```

## License

MIT — see [LICENSE](LICENSE).
