# Environment setup

## Create conda environment

conda create -n amr_env python=3.9 -y
conda activate amr_env

## Install tools

conda install -c bioconda rgi prodigal mlst -y

## Download CARD database

rgi auto_load

## Verify installation

rgi --version
prodigal -v
mlst --version
