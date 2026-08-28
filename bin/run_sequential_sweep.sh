#!/usr/bin/env bash
# =============================================================================
# run_sequential_sweep.sh — jalankan sisa run 3x benchmark satu-per-satu
# =============================================================================
# Dijalankan LANGSUNG DI HPC (bukan di dev machine). Submit satu job,
# tunggu sampai job itu (dan seluruh sub-task SLURM-nya) benar-benar keluar
# dari antrean, verifikasi tidak ada task berstatus CACHED, baru lanjut ke
# baris berikutnya. Didesain untuk jalan lewat `nohup ... &` supaya tahan
# terputusnya koneksi SSH.
#
# Log progres ditulis ke sequential_sweep.log di direktori project.
# =============================================================================
set -uo pipefail
cd "$HOME/nf-pangenome-elaeis" || exit 1

LOG="sequential_sweep.log"

# Daftar (samplesheet, outdir) yang masih perlu dijalankan, urut prioritas.
RUNS=(
  "data_bench/1MB/samplesheet.csv results_bench_1MB_3"
  "data_bench/10MB/samplesheet.csv results_bench_10MB_2"
  "data_bench/10MB/samplesheet.csv results_bench_10MB_3"
  "data_bench/20MB/samplesheet.csv results_bench_20MB_2"
  "data_bench/20MB/samplesheet.csv results_bench_20MB_3"
  "data_bench/40MB/samplesheet.csv results_bench_40MB_2"
  "data_bench/40MB/samplesheet.csv results_bench_40MB_3"
  "data_bench/72MB/samplesheet.csv results_bench_72MB_2"
  "data_bench/72MB/samplesheet.csv results_bench_72MB_3"
  "data_bench/350MB/samplesheet.csv results_bench_350MB_2"
  "data_bench/350MB/samplesheet.csv results_bench_350MB_3"
)

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"
}

log "=== Mulai sequential sweep: ${#RUNS[@]} run tersisa ==="

for entry in "${RUNS[@]}"; do
  samplesheet=$(echo "$entry" | awk '{print $1}')
  outdir=$(echo "$entry" | awk '{print $2}')

  log "--- Submit: $samplesheet -> ${outdir}/ ---"
  jobid=$(sbatch run_hpc.sh "$samplesheet" "${outdir}/" noresume | awk '{print $NF}')

  if [ -z "$jobid" ]; then
    log "GAGAL submit untuk ${outdir}, skip ke berikutnya."
    continue
  fi
  log "Job ID: $jobid"

  # Tunggu sampai job orchestrator DAN seluruh sub-task-nya keluar dari antrean.
  # Cek berdasarkan nama outdir yang unik di NAME job (nextflow subtask job
  # namenya panjang berisi nama process, jadi kita tunggu sampai squeue -u
  # kosong sepenuhnya, karena kita jamin cuma 1 pipeline jalan di satu waktu).
  while squeue -u "$USER" --noheader 2>/dev/null | grep -q .; do
    sleep 60
  done

  # Verifikasi hasil: cek trace.tsv ada dan tidak ada baris CACHED
  trace="${outdir}/pipeline_info/trace.tsv"
  if [ -f "$trace" ]; then
    cached_count=$(cut -f5 "$trace" 2>/dev/null | grep -c "CACHED" || true)
    completed_count=$(cut -f5 "$trace" 2>/dev/null | grep -c "COMPLETED" || true)
    if [ "$cached_count" -gt 0 ]; then
      log "PERINGATAN: ${outdir} punya $cached_count task CACHED (data mungkin tidak valid)."
    else
      log "OK: ${outdir} selesai, $completed_count task COMPLETED, 0 cached."
    fi
  else
    log "PERINGATAN: ${outdir} tidak menghasilkan trace.tsv (kemungkinan gagal)."
  fi

  # Jeda singkat sebelum submit berikutnya
  sleep 10
done

log "=== Sequential sweep selesai — semua ${#RUNS[@]} run telah diproses ==="
