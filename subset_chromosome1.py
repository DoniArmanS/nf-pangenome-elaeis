#!/usr/bin/env python3
"""
subset_chromosome1.py — potong chromosome 1 dari 3 assembly nyata Elaeis guineensis
ke ukuran target (dalam Mb) untuk uji skala resource pipeline (bukan data test/dev,
langsung dipakai sebagai --input pipeline utama).

Chromosome 1 per assembly (dicek langsung dari header .fna):
  EG11     -> CM002081.2
  EGPMv6   -> GK000076.1
  Eg-DCM   -> CBHZAK010000001.1

Jalankan dari root project:
    python3 subset_chromosome1.py 10
    -> tulis data_bench/10MB/{EG11,EGPMv6,Eg-DCM}.fa + samplesheet.csv

Lalu jalankan pipeline langsung (bukan profile test terpisah):
    sbatch run_hpc.sh data_bench/10MB/samplesheet.csv results_bench_10MB/
"""

import os
import sys

ASSEMBLIES = [
    # (sample, haplotype, cultivar, path_fna, accession_chr1)
    (
        "EG11", "1", "Tenera",
        "data/EG11/ncbi_dataset/data/GCA_000442705.2/GCA_000442705.2_EG11_genomic.fna",
        "CM002081.2",
    ),
    (
        "EGPMv6", "1", "AVROS",
        "data/EGPMv6/ncbi_dataset/data/GCA_015461965.1/GCA_015461965.1_EGPMv6_genomic.fna",
        "GK000076.1",
    ),
    (
        "Eg-DCM", "1", "DCM",
        "data/Eg-DCM/ncbi_dataset/data/GCA_966131455.1/GCA_966131455.1_Eg-DCM_assembly_v1_genomic.fna",
        "CBHZAK010000001.1",
    ),
]

OUT_ROOT = "data_bench"


def extract_chr1(fna_path, accession, max_bp):
    """Baca fna_path, ambil record berheader accession, potong ke max_bp basepair."""
    lines_out = []
    bp_so_far = 0
    in_record = False

    with open(fna_path) as f:
        for line in f:
            line = line.rstrip("\n")
            if line.startswith(">"):
                if in_record:
                    break
                header_id = line[1:].split()[0]
                in_record = header_id == accession
                continue
            if in_record:
                remaining = max_bp - bp_so_far
                if remaining <= 0:
                    break
                chunk = line[:remaining]
                lines_out.append(chunk)
                bp_so_far += len(chunk)

    if not lines_out:
        raise RuntimeError(f"Accession {accession} tidak ditemukan di {fna_path}")
    return lines_out, bp_so_far


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 subset_chromosome1.py <size_mb>")
        print("  contoh: python3 subset_chromosome1.py 10")
        sys.exit(1)

    size_arg = sys.argv[1]
    size_mb = float(size_arg)
    max_bp = int(size_mb * 1_000_000)

    out_dir = os.path.join(OUT_ROOT, f"{size_arg}MB")
    os.makedirs(out_dir, exist_ok=True)

    csv_rows = ["sample,fasta,cultivar"]

    print(f"\n{'─' * 60}")
    print(f"  Subsetting chromosome 1 -> target {size_mb} Mb per assembly")
    print(f"{'─' * 60}\n")

    for sample, hap, cultivar, fna_path, accession in ASSEMBLIES:
        if not os.path.exists(fna_path):
            print(f"  ⚠️  SKIP {sample} — file tidak ditemukan: {fna_path}")
            continue

        seq_lines, bp_written = extract_chr1(fna_path, accession, max_bp)

        out_path = os.path.join(out_dir, f"{sample}.fa")
        with open(out_path, "w") as f:
            f.write(f">{sample}#{hap}#{accession}\n")
            f.write("\n".join(seq_lines) + "\n")

        print(f"  ✅ {sample} ({cultivar}) — {bp_written:,} bp -> {out_path}")
        csv_rows.append(f"{sample},{out_path},{cultivar}")

    csv_path = os.path.join(out_dir, "samplesheet.csv")
    with open(csv_path, "w") as f:
        f.write("\n".join(csv_rows) + "\n")

    print(f"\n{'─' * 60}")
    print(f"  ✅ Samplesheet: {csv_path}")
    print(f"\n  Jalankan pipeline:")
    print(f"  sbatch run_hpc.sh {csv_path} results_bench_{size_arg}MB/")
    print(f"{'─' * 60}\n")


if __name__ == "__main__":
    main()
