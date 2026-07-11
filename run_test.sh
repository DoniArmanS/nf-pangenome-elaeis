#!/bin/bash
# ==============================================================================
# run_test.sh — Test pipeline lokal dengan sample data kecil
# ==============================================================================
# Jalankan: bash run_test.sh
# ==============================================================================

echo "============================================"
echo "  nf-pangenome-elaise — Local Test Run"
echo "============================================"

# Aktifkan conda
source ~/miniforge3/etc/profile.d/conda.sh
conda activate pangenome

# Jalankan test (data kecil ~760 KB)
nextflow run main.nf \
    -profile conda,test \
    -resume

echo "============================================"
echo "  Selesai! Cek results/ untuk output"
echo "  Buka: xdg-open results/pipeline_info/timeline.html"
echo "============================================"
