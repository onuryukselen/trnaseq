FROM ubuntu:22.04
LABEL author="zach@viascientific.com" description="Docker image containing all requirements for the tRNAseq pipeline"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y vim wget bzip2 unzip ca-certificates curl git libtbb-dev gcc g++ libcairo2-dev pandoc libhdf5-dev cmake

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get update && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && aws --version
    
COPY environment.yml /
RUN . /opt/conda/etc/profile.d/conda.sh && \ 
    conda activate base && \
    conda update conda && \
    conda install -c conda-forge mamba && \
    mamba env create -f /environment.yml && \
    mamba clean -a

# Install usearch
RUN wget https://drive5.com/downloads/usearch10.0.240_i86linux32.gz && \
    gunzip usearch10.0.240_i86linux32.gz && mv usearch10.0.240_i86linux32 usearch && \
    cp usearch /usr/local/bin/usearch && chmod 777 /usr/local/bin/usearch 
ENV PATH /usr/local/bin/usearch:$PATH

RUN mkdir -p /project /nl /mnt /share /pi
ENV PATH /opt/conda/envs/via/bin:$PATH
