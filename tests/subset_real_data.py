#!/usr/bin/env python3
"""
subset_real_data.py
===================
Potong sebagian kecil dari FASTA genome asli Elaeis guineensis
untuk dipakai testing pipeline tanpa butuh HPC.

Strategi:
  - Ambil N sequences pertama dari masing-masing assembly
  - Potong tiap sequence ke MAX_BP basepair pertama
  - Rename header ke format PanSN-spec: {sample}#{hap}#{seqname}
  - Output: tests/test_data/{sample}.fa + samplesheet.csv

Jalankan dari root project:
    python3 tests/subset_real_data.py

Syarat:
  - Data asli sudah diekstrak (lihat README.md)
  - Tidak butuh dependency tambahan (pure Python)
"""

import os
import re

# ──────────────────────────────────────────────────────────────────────────────
# KONFIGURASI — sesuaikan jika perlu
# ──────────────────────────────────────────────────────────────────────────────

# Jumlah sequences yang diambil per assembly
N_SEQS = 5

# Panjang maksimum tiap sequence (basepair) — 100kb cukup untuk test
MAX_BP = 100_000

# Root data skripsi (di-gitignore)
DATA_ROOT = os.path.join(os.path.dirname(__file__), "..", "DATA SKRIPSI", "Elaeis guineensis")

# Mapping: (sample_id, haplotype, variety, path_ke_fasta_asli)
ASSEMBLIES = [
    (
        "EGPMv6",   # sample ID
        "1",        # haplotype (PanSN-spec)
        "AVROS",    # varietas/cultivar
        os.path.join(DATA_ROOT, "EGPMv6_extract/ncbi_dataset/data/GCA_015461965.1/GCA_015461965.1_EGPMv6_genomic.fna"),
    ),
    (
        "EG01",
        "1",
        "Jacq",
        os.path.join(DATA_ROOT, "EG01_extract/ncbi_dataset/data/GCA_002146295.1/GCA_002146295.1_EG01_genomic.fna"),
    ),
    (
        "ASM167249v1",
        "1",
        "Dura",
        os.path.join(DATA_ROOT, "ASM167249v1_extract/ncbi_dataset/data/GCA_001672495.1/GCA_001672495.1_ASM167249v1_genomic.fna"),
    ),
]

# Output directory (masuk git — ukurannya kecil)
OUT_DIR = os.path.join(os.path.dirname(__file__), "test_data")

# ──────────────────────────────────────────────────────────────────────────────


def safe_seqname(header: str) -> str:
    """Ambil accession/ID dari header FASTA, bersihkan karakter spesial."""
    # Ambil kata pertama setelah '>'
    raw = header.lstrip(">").split()[0]
    # Bersihkan — hanya alfanumerik, titik, underscore
    return re.sub(r"[^A-Za-z0-9._]", "_", raw)


def subset_fasta(src_path: str, sample: str, hap: str, n_seqs: int, max_bp: int) -> list[str]:
    """
    Baca FASTA dari src_path, ambil n_seqs pertama, potong ke max_bp.
    Return: list string baris FASTA dengan header PanSN-spec.
    """
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
                # Simpan sequence sebelumnya
                flush_sequence()
                current_seq_lines = []
                current_bp = 0

                seq_count += 1
                if seq_count > n_seqs:
                    break

                seqname = safe_seqname(line)
                # PanSN-spec format: sample#hap#seqname
                current_header = f">{sample}#{hap}#{seqname}"

            elif current_header and seq_count <= n_seqs:
                remaining = max_bp - current_bp
                if remaining <= 0:
                    continue
                chunk = line[:remaining]
                current_seq_lines.append(chunk)
                current_bp += len(chunk)

    # Flush sequence terakhir
    flush_sequence()
    return lines_out


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    csv_rows = ["sample,fasta,cultivar"]

    print(f"\n{'─'*60}")
    print(f"  Subsetting real Elaeis guineensis genome data")
    print(f"  N sequences : {N_SEQS} per assembly")
    print(f"  Max length  : {MAX_BP:,} bp per sequence")
    print(f"{'─'*60}\n")

    for sample_id, hap, cultivar, fasta_path in ASSEMBLIES:
        if not os.path.exists(fasta_path):
            print(f"  ⚠️  SKIP {sample_id} — file tidak ditemukan:")
            print(f"       {fasta_path}")
            print(f"       Pastikan zip sudah diekstrak.\n")
            continue

        out_path = os.path.join(OUT_DIR, f"{sample_id}.fa")
        lines = subset_fasta(fasta_path, sample_id, hap, N_SEQS, MAX_BP)

        with open(out_path, "w") as f:
            f.write("\n".join(lines) + "\n")

        # Hitung stats
        n_seqs_out = sum(1 for l in lines if l.startswith(">"))
        n_bp = sum(len(l) for l in lines if not l.startswith(">"))

        print(f"  ✅ {sample_id} ({cultivar})")
        print(f"     {n_seqs_out} sequences, {n_bp:,} bp total")
        print(f"     → {out_path}\n")

        csv_rows.append(f"{sample_id},{out_path},{cultivar}")

    # Tulis samplesheet
    csv_path = os.path.join(OUT_DIR, "samplesheet.csv")
    with open(csv_path, "w") as f:
        f.write("\n".join(csv_rows) + "\n")

    print(f"{'─'*60}")
    print(f"  ✅ Samplesheet: {csv_path}")
    print(f"\n  Jalankan pipeline test:")
    print(f"  nextflow run main.nf -profile test \\")
    print(f"      --input tests/test_data/samplesheet.csv \\")
    print(f"      --stub-run")
    print(f"{'─'*60}\n")


if __name__ == "__main__":
    main()
