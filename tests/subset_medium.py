#!/usr/bin/env python3
"""
subset_medium.py
================
Buat subset MEDIUM dari genome asli — cukup besar untuk menghasilkan
output yang realistis (graph dengan banyak node/edge, visualisasi jelas),
tapi masih bisa jalan di laptop (8 GB free disk, 12 GB RAM).

Estimasi output: ~30 MB total (4 assembly × ~7 MB each)
Estimasi runtime: ~5-10 menit di laptop

Jalankan:
    python3 tests/subset_medium.py
"""

import os
import re

# ──────────────────────────────────────────────────────────────────────────────
# KONFIGURASI
# ──────────────────────────────────────────────────────────────────────────────

# Ambil 20 sequences per assembly, masing-masing max 500 kbp
N_SEQS = 20
MAX_BP = 500_000  # 500 kb per sequence

# Data asli dari folder data/
PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..")

# 4 assembly — cukup untuk pangenome yang bermakna
# EG11 (29 seq, kromosom-level) jadi referensi karena paling sedikit contig = paling bagus
ASSEMBLIES = [
    (
        "EG11",
        "1",
        "Tenera",
        os.path.join(PROJECT_ROOT, "data/EG11/ncbi_dataset/data/GCA_000442705.2/GCA_000442705.2_EG11_genomic.fna"),
    ),
    (
        "EGPMv6",
        "1",
        "AVROS",
        os.path.join(PROJECT_ROOT, "data/EGPMv6/ncbi_dataset/data/GCA_015461965.1/GCA_015461965.1_EGPMv6_genomic.fna"),
    ),
    (
        "ASM167249v1",
        "1",
        "Dura",
        os.path.join(PROJECT_ROOT, "data/ASM167249v1/ncbi_dataset/data/GCA_001672495.1/GCA_001672495.1_ASM167249v1_genomic.fna"),
    ),
    (
        "EG01",
        "1",
        "Jacq",
        os.path.join(PROJECT_ROOT, "data/EG01/ncbi_dataset/data/GCA_002146295.1/GCA_002146295.1_EG01_genomic.fna"),
    ),
]

OUT_DIR = os.path.join(os.path.dirname(__file__), "medium_data")


# ──────────────────────────────────────────────────────────────────────────────

def safe_seqname(header: str) -> str:
    raw = header.lstrip(">").split()[0]
    return re.sub(r"[^A-Za-z0-9._]", "_", raw)


def subset_fasta(src_path, sample, hap, n_seqs, max_bp):
    lines_out = []
    seq_count = 0
    current_header = None
    current_bp = 0
    current_seq_lines = []

    def flush_sequence():
        nonlocal lines_out, current_seq_lines
        if current_header and current_seq_lines:
            lines_out.append(current_header)
            lines_out.extend(current_seq_lines)

    with open(src_path, "r") as f:
        for line in f:
            line = line.rstrip()
            if line.startswith(">"):
                flush_sequence()
                current_seq_lines = []
                current_bp = 0

                seq_count += 1
                if seq_count > n_seqs:
                    break

                seqname = safe_seqname(line)
                current_header = f">{sample}#{hap}#{seqname}"

            elif current_header and seq_count <= n_seqs:
                remaining = max_bp - current_bp
                if remaining <= 0:
                    continue
                chunk = line[:remaining]
                current_seq_lines.append(chunk)
                current_bp += len(chunk)

    flush_sequence()
    return lines_out


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    csv_rows = ["sample,fasta,cultivar"]

    print(f"\n{'─'*60}")
    print(f"  MEDIUM Subset — Elaeis guineensis")
    print(f"  N sequences : {N_SEQS} per assembly")
    print(f"  Max length  : {MAX_BP:,} bp per sequence")
    print(f"  Assemblies  : {len(ASSEMBLIES)}")
    print(f"{'─'*60}\n")

    total_bp = 0
    for sample_id, hap, cultivar, fasta_path in ASSEMBLIES:
        if not os.path.exists(fasta_path):
            print(f"  ⚠️  SKIP {sample_id} — file tidak ditemukan:")
            print(f"       {fasta_path}\n")
            continue

        out_path = os.path.abspath(os.path.join(OUT_DIR, f"{sample_id}.fa"))
        lines = subset_fasta(fasta_path, sample_id, hap, N_SEQS, MAX_BP)

        with open(out_path, "w") as f:
            f.write("\n".join(lines) + "\n")

        n_seqs_out = sum(1 for l in lines if l.startswith(">"))
        n_bp = sum(len(l) for l in lines if not l.startswith(">"))
        total_bp += n_bp
        file_size = os.path.getsize(out_path)

        print(f"  ✅ {sample_id} ({cultivar})")
        print(f"     {n_seqs_out} sequences, {n_bp:,} bp, {file_size/1024/1024:.1f} MB")
        print(f"     → {out_path}\n")

        csv_rows.append(f"{sample_id},{out_path},{cultivar}")

    csv_path = os.path.join(OUT_DIR, "samplesheet.csv")
    with open(csv_path, "w") as f:
        f.write("\n".join(csv_rows) + "\n")

    print(f"{'─'*60}")
    print(f"  Total: {total_bp:,} bp ({total_bp/1_000_000:.1f} Mbp)")
    print(f"  Samplesheet: {csv_path}")
    print(f"\n  Jalankan pipeline:")
    print(f"  conda activate pangenome")
    print(f"  nextflow run main.nf -profile conda \\")
    print(f"    --input {csv_path} \\")
    print(f"    --reference_name EG11 \\")
    print(f"    --outdir results_medium \\")
    print(f"    --max_cpus 8 --max_memory 8.GB")
    print(f"{'─'*60}\n")


if __name__ == "__main__":
    main()
