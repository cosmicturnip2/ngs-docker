FROM condaforge/miniforge3

RUN conda config --add channels bioconda \
    && conda config --add channels conda-forge \
    && conda config --set channel_priority strict \
    && mamba install -y -n base fastqc trimmomatic bwa gatk4 hisat2 python=3.11 \
    && conda clean -afy

WORKDIR /data
