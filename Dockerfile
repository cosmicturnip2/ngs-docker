FROM condaforge/miniforge3

RUN conda config --add channels bioconda \
    && conda config --add channels conda-forge \
    && conda config --set channel_priority strict \
    && conda install -y -n base fastqc trimmomatic bwa gatk4 hisat2 samtools python=3.11 \
    && conda clean -afy

WORKDIR /data
