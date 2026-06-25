#!/usr/bin/env python3
"""
generate_dummy.py
=================
Script untuk membuat data dummy kecil (5 "assembly" Elaeis guineensis palsu)
yang bisa dipakai testing pipeline tanpa data asli / HPC.

Jalankan:
    python3 tests/dummy_data/generate_dummy.py
"""

import random
import os

random.seed(42)

SAMPLES = [
    ("EG_ASM1", "dura"),
    ("EG_ASM2", "pisifera"),
    ("EG_ASM3", "tenera"),
    ("EG_ASM4", "dura"),
    ("EG_ASM5", "pisifera"),
]

SEQ_LEN = 5000   # panjang tiap kromosom dummy
N_CHROM = 3      # jumlah kromosom per sample

def random_seq(length):
    return ''.join(random.choices("ACGT", k=length))

out_dir = os.path.dirname(__file__)

csv_rows = ["sample,fasta,assembler"]

for sample_id, variety in SAMPLES:
    fasta_path = os.path.join(out_dir, f"{sample_id}.fa")
    with open(fasta_path, "w") as f:
        for i in range(1, N_CHROM + 1):
            # Format PanSN-spec: {sample}#{haplotype}#{sequence}
            header = f">{sample_id}#1#chr{i}"
            f.write(header + "\n")
            # Tulis sekuens 60 karakter per baris
            seq = random_seq(SEQ_LEN)
            for j in range(0, len(seq), 60):
                f.write(seq[j:j+60] + "\n")
    csv_rows.append(f"{sample_id},{fasta_path},{variety}")
    print(f"  ✓ {fasta_path} ({N_CHROM} contigs × {SEQ_LEN}bp)")

# Tulis samplesheet
csv_path = os.path.join(out_dir, "samplesheet.csv")
with open(csv_path, "w") as f:
    f.write("\n".join(csv_rows) + "\n")

print(f"\n✅ Samplesheet: {csv_path}")
print("Sekarang test pipeline dengan:")
print("  nextflow run main.nf -profile test --stub-run")
