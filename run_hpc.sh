#!/bin/bash
# ==============================================================================
# run_hpc.sh — Jalankan pipeline di HPC Mahameru BRIN (SLURM)
# ==============================================================================
# Prasyarat (semua sudah terpenuhi):
#   ✅ 1. Nextflow    → ~/bin/nextflow
#   ✅ 2. Java 21     → sdkman (~/.sdkman)
#   ✅ 3. Conda env   → ~/miniforge3/envs/pangenome
#   ✅ 4. Cactus .sif → ~/cactus_v2.9.0.sif
#   ✅ 5. Data genome → data/EG11/, data/EGPMv6/, data/Eg-DCM/
#
# Cara submit ke SLURM:
#   cd ~/nf-pangenome-elaeis
#   sbatch run_hpc.sh
#
# Monitor progress:
#   squeue -u darman
#   tail -f slurm-pangenome-<JOBID>.out
# ==============================================================================

#SBATCH --job-name=pangenome-elaeis
#SBATCH --output=slurm-pangenome-%j.out
#SBATCH --error=slurm-pangenome-%j.err
#SBATCH --partition=medium-small
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=72:00:00
#SBATCH --nodelist=trembesi56

echo "============================================================"
echo "  nf-pangenome-elaeis — HPC Mahameru Run"
echo "  Start : $(date)"
echo "  Node  : $(hostname)"
echo "  CPUs  : $SLURM_CPUS_PER_TASK"
echo "  RAM   : ${SLURM_MEM_PER_NODE:-64000} MB"
echo "============================================================"

# ── Load Singularity (tersedia via module di Mahameru) ──────────────────────
module load singularity

# Singularity cache = home dir (lokasi cactus_v2.9.0.sif)
export SINGULARITY_CACHEDIR=$HOME
export NXF_SINGULARITY_CACHEDIR=$HOME

# ── Aktifkan Java (sdkman) ──────────────────────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"
source "$HOME/.sdkman/bin/sdkman-init.sh"

# ── Aktifkan Conda env pangenome ────────────────────────────────────────────
source ~/miniforge3/etc/profile.d/conda.sh
conda activate pangenome

# ── Tambahkan Nextflow ke PATH ──────────────────────────────────────────────
export PATH=$HOME/bin:$PATH

# ── Jalankan pipeline ───────────────────────────────────────────────────────
nextflow run main.nf \
    -profile conda,slurm \
    --input samplesheet.csv \
    --outdir results/ \
    --cactus_cores 16 \
    --call_variants false \
    -resume \
    -with-report results/pipeline_info/report.html \
    -with-timeline results/pipeline_info/timeline.html \
    -with-trace results/pipeline_info/trace.tsv

echo "============================================================"
echo "  Selesai: $(date)"
echo "  Hasil  : results/"
echo "  Log    : slurm-pangenome-${SLURM_JOB_ID}.out"
echo "============================================================"

