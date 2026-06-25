# 📋 Progress Skripsi — nf-pangenome-elaise
> Terakhir diupdate: 2026-06-26
> **Deadline Analisis: November 2026 | Kompre: Desember 2026**

---

## ✅ Setup & Infrastruktur

- [x] Inisiasi repository `nf-pangenome-elaise`
- [x] Setup struktur folder (nf-core convention)
- [x] Buat `.gitignore` (data & proposal dikecualikan, logs dikecualikan)
- [x] `main.nf` — entry point Nextflow DSL2
- [x] `nextflow.config` — profiles: local, docker, singularity, slurm, test
- [x] Install Nextflow v26.04.4 di `~/.local/bin` (tanpa sudo)
- [x] Modules: `wfmash`, `seqwish`, `smoothxg`, `odgi`, `seqkit_stats`, `seqkit_filter`, `vg_deconstruct` (semua ada `stub:`)
- [x] Subworkflows: validate_input, preprocessing, graph_construction, graph_analysis, variant_calling
- [x] Real data subset dari genome asli (`tests/subset_real_data.py`)
  - [x] EGPMv6 — 5 seq × 100kb dari AVROS assembly (chromosom-level)
  - [x] EG01 — 5 seq × 100kb dari EG01 assembly
  - [x] ASM167249v1 — 5 seq × 100kb dari Dura assembly
- [x] `tests/test_data/samplesheet.csv` dibuat
- [x] PROGRESS.md + ERRORS.md
- [x] `docs/NEXTFLOW_PRINCIPLES.md`
- [x] README.md sebagai Nextflow project documentation
- [x] Git init + initial commit
- [x] **Push ke GitHub** ← sedang dikerjakan
- [ ] Fix open issue: WFMASH CPU limit di laptop (lihat ERRORS.md)

---

## 🔄 Analisis — Tahap 1: Data & Preprocessing

- [ ] Download & ekstrak 5 assembly dari NCBI (sudah ada di DATA SKRIPSI)
  - [ ] ASM167249v1 (Dura)
  - [ ] EG01
  - [ ] EG11
  - [ ] EGPMv6
  - [ ] Eg-DCM_assembly_v1
- [ ] Validasi format FASTA & rename header ke PanSN-spec (`{sample}#{hap}#{chrom}`)
- [ ] Buat `samplesheet.csv` dari data asli
- [ ] Jalankan seqkit stats → cek ukuran, N50, GC content
- [ ] Filter sekuens pendek (`min_seq_len = 1000`)

---

## 🔄 Analisis — Tahap 2: Konstruksi Pangenome Graph

- [ ] Test stub-run pipeline (tanpa tool asli)
  ```bash
  nextflow run main.nf -profile test --stub-run
  ```
- [ ] Install tools (pilih salah satu):
  - [ ] Conda: `conda env create -f environment.yml`
  - [ ] Docker: `docker pull quay.io/biocontainers/pggb`
- [ ] wfmash — all-vs-all alignment (5 assembly)
- [ ] seqwish — graph induction dari PAF
- [ ] smoothxg — normalisasi graph
- [ ] gfaffix — reduksi redundansi (opsional)

---

## 🔄 Analisis — Tahap 3: Analisis Graph

- [ ] odgi build → konversi GFA ke binary
- [ ] odgi stats → metrik: node, edge, path
- [ ] odgi viz → visualisasi 1D layout
- [ ] odgi layout + draw → visualisasi 2D (PCA-like)
- [ ] Hitung coverage path per assembly

---

## 🔄 Analisis — Tahap 4: Variant Calling (SV)

- [ ] Pilih reference (EG01 atau ASM167249v1)
- [ ] vg deconstruct → VCF dari pangenome graph
- [ ] Filter VCF: QUAL, DP
- [ ] Anotasi SV: insertions, deletions, inversions, translocations
- [ ] Bandingkan distribusi SV antar varietas (dura vs pisifera vs tenera)

---

## 🔄 Analisis — Tahap 5: Evaluasi Pipeline

- [ ] Benchmarking waktu & memori (lokal vs HPC)
- [ ] Bandingkan hasil dengan PGGB bash script biasa
- [ ] Dokumentasi parameter optimal untuk *E. guineensis*
- [ ] MultiQC report final

---

## 📝 Penulisan Skripsi

- [ ] BAB III: Metodologi — update sesuai implementasi nyata
- [ ] BAB IV: Hasil & Pembahasan
  - [ ] Statistik graph (node, edge, path)
  - [ ] Tabel SV per varietas
  - [ ] Gambar visualisasi graph 1D & 2D
- [ ] BAB V: Kesimpulan & Saran
- [ ] Daftar Pustaka (update dari Mendeley/Zotero)

---

## 🗓 Timeline

| Bulan | Target |
|-------|--------|
| Juni 2026 | ✅ Setup repo & struktur |
| Juli 2026 | Data preprocessing + stub pipeline |
| Agustus 2026 | Graph construction (data asli kecil dulu) |
| September 2026 | Graph analysis + SV detection |
| Oktober 2026 | Evaluasi & benchmarking |
| November 2026 | **DEADLINE ANALISIS** + draft BAB IV |
| Desember 2026 | **KOMPREHENSIF** |
