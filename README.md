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
- [GATK4](https://gatk.broadinstitute.org/) — variant calling

All installed via the [bioconda](https://bioconda.github.io/) channel inside
a [Miniforge](https://github.com/conda-forge/miniforge)-based image.

## Prerequisites

- [Docker Desktop](https://docs.docker.com/desktop/) installed and running

## Build the image

\`\`\`bash
git clone https://github.com/<your-username>/ngs-docker.git
cd ngs-docker
docker build -t ngs-tools .
\`\`\`

## Run it

\`\`\`bash
mkdir -p ~/ngs-data
docker run -it --rm -v ~/ngs-data:/data ngs-tools bash
\`\`\`

Any files placed in `~/ngs-data` on your host machine are available inside
the container at `/data`.

## Example usage

See `examples/run_fastqc_trimmomatic.sh` for a full example: quality-checking
a FASTQ file with FastQC, trimming it with Trimmomatic, then re-checking the
trimmed output.

## Project structure

\`\`\`
ngs-docker/
├── Dockerfile
├── README.md
├── LICENSE
├── .dockerignore
└── examples/
    └── run_fastqc_trimmomatic.sh
\`\`\`

## License

MIT — see [LICENSE](LICENSE).
