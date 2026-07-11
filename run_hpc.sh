#!/bin/bash
# ==============================================================================
# run_hpc.sh — Jalankan pipeline di HPC Mahameru (SLURM)
# ==============================================================================
# Pastikan sudah:
#   1. Upload data genome ke data/*/ncbi_dataset/...
#   2. Install Nextflow & Singularity/Docker di HPC
#   3. Conda env 'pangenome' sudah dibuat (atau pakai Singularity)
#
# Jalankan:
#   sbatch run_hpc.sh
# ==============================================================================

#SBATCH --job-name=pangenome
#SBATCH --output=slurm-pangenome-%j.out
#SBATCH --error=slurm-pangenome-%j.err
#SBATCH --partition=medium-small
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=72:00:00

echo "============================================"
echo "  nf-pangenome-elaise — HPC Mahameru Run"
echo "  Start: $(date)"
echo "  Node : $(hostname)"
echo "  CPUs : $SLURM_CPUS_PER_TASK"
echo "  RAM  : $SLURM_MEM_PER_NODE MB"
echo "============================================"

# Load modules (sesuaikan dengan HPC)
# module load nextflow singularity

# Aktifkan conda
source ~/miniforge3/etc/profile.d/conda.sh
conda activate pangenome

# Jalankan pipeline
nextflow run main.nf \
    -profile conda \
    --input samplesheet.csv \
    --reference_name EG11 \
    --outdir results/ \
    --max_cpus 32 \
    --max_memory 64.GB \
    --max_time 72.h \
    --cactus_cores 16 \
    -resume

echo "============================================"
echo "  Selesai: $(date)"
echo "============================================"
