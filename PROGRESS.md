# 📋 Progress Skripsi — nf-pangenome-elaise
> Terakhir diupdate: **2026-07-11**
> **Deadline Analisis: November 2026 | Komprehensif: Desember 2026**

---

## 📊 Persentase Kesiapan Keseluruhan

```
Infrastructure  ████████████████████  100%
Tool Install    ████████████████████  100%  ✅ SEMUA (termasuk Cactus Docker)
Preprocessing   ████████████████████  100%  ✅ Tested dengan sample data
QC (QUAST)      ████████████████████  100%  ✅ Tested dengan sample data
Graph Construct ████████████████████  100%  ✅ Minigraph + Cactus BERHASIL
Graph Analysis  ████████████████████  100%  ✅ odgi stats/viz + vg stats BERHASIL
HPC/Slurm       ████████░░░░░░░░░░░░   40%  (config ada, belum implement di Mahameru)
Testing & Eval  ██████████████░░░░░░   65%  ✅ Test data OK, belum full data
Penulisan BAB   ██░░░░░░░░░░░░░░░░░░   10%  (metodologi draft)
─────────────────────────────────────────────
TOTAL ANALISIS  ███████████░░░░░░░░░  ~55%
```

> **Catatan:** Naik dari ~40% → ~55% setelah pipeline berhasil dijalankan end-to-end
> dengan sample data (3 assembly subset). Semua 8 step completed tanpa error.

---

## ✅ Setup & Infrastruktur — 100% SELESAI

- [x] Inisiasi repository `nf-pangenome-elaise` di GitHub
- [x] Struktur folder nf-core convention
- [x] `.gitignore` — eksklusikan DATA SKRIPSI, PROPOSAL, logs, genome besar
- [x] `main.nf` — entry point Nextflow DSL2
- [x] `nextflow.config` — profiles: local, docker, singularity, slurm, test, **conda**
- [x] Install Nextflow v26.04.4 di `~/.local/bin`
- [x] SSH key GitHub terhubung (DoniArmanS)
- [x] Git + GitHub push sukses

---

## ✅ Tool Installation — 100% SELESAI

| Tool | Versi | Metode Install | Status |
|------|-------|---------------|--------|
| Nextflow | v25.10.4 | system install (`/usr/local/bin`) | ✅ |
| Java (OpenJDK) | 21.0.11 | apt | ✅ |
| Miniforge3 (conda) | latest | installer script | ✅ |
| seqkit | v2.13.0 | `conda install -c bioconda` | ✅ |
| QUAST | v5.3.0 | `conda install -c bioconda` | ✅ |
| minigraph | 0.21-r606 | `conda install -c bioconda` | ✅ |
| odgi | v0.9.4 | `conda install -c bioconda` | ✅ |
| vg | v1.73.0 | `conda install -c bioconda` | ✅ |
| samtools | 1.24 | `conda install -c bioconda` | ✅ |
| cactus-minigraph | v2.9.0 | Docker image (1.07 GB) | ✅ |
| Docker | v29.1.3 | apt | ✅ |

> **Conda environment:** `pangenome` → `~/miniforge3/envs/pangenome/` (2.4 GB)
> **Cara aktivasi:** `conda activate pangenome`
> **Nextflow profile:** `-profile conda` (sudah dikonfigurasi di `nextflow.config`)

---

## ✅ Kode Pipeline — Selesai & Tested dengan Sample Data

### Modules
- [x] `modules/local/preprocessing/seqkit_stats.nf`
- [x] `modules/local/preprocessing/seqkit_filter.nf`
- [x] `modules/local/qc/quast.nf`
- [x] `modules/local/graph_construction/minigraph.nf`
- [x] `modules/local/graph_construction/cactus_minigraph.nf`
- [x] `modules/local/graph_analysis/odgi.nf` (ODGI_STATS + ODGI_VIZ)
- [x] `modules/local/graph_analysis/vg_stats.nf`

### Subworkflows
- [x] `subworkflows/local/validate_input.nf`
- [x] `subworkflows/local/preprocessing.nf`
- [x] `subworkflows/local/qc.nf`
- [x] `subworkflows/local/graph_construction.nf` (Minigraph-Cactus)
- [x] `subworkflows/local/graph_analysis.nf` (odgi + vg stats)

### Workflow Utama
- [x] `workflows/pangenome.nf` — 5 tahap sesuai proposal

### Scripts & Dokumentasi
- [x] `bin/extract_core_var.sh` — core vs variable sequences
- [x] `tests/subset_real_data.py` — subset genome asli
- [x] `tests/test_data/` — 3 assembly subset (EGPMv6, EG01, ASM167249v1)
- [x] `docs/NEXTFLOW_PRINCIPLES.md`
- [x] README.md (Bahasa Indonesia, alur sesuai proposal)

---

## ✅ Test Run — Sample Data (3 Assembly Subset) — BERHASIL

> **Tanggal:** 2026-07-11
> **Profile:** `-profile conda,test`
> **Data:** 3 assembly subset (EGPMv6 495K, ASM167249v1 237K, EG01 29K)
> **Hasil:** Semua 8 step/14 tasks berhasil, exit code 0

| Step | Tasks | Status | Duration | Peak RAM |
|------|-------|--------|----------|----------|
| SEQKIT_STATS | 3/3 | ✅ | ~100ms | 25 MB |
| SEQKIT_FILTER | 3/3 | ✅ | ~150ms | 43 MB |
| QUAST | 3/3 | ✅ | 2.5s | 109 MB |
| MINIGRAPH | 1/1 | ✅ | 81ms | 4 MB |
| CACTUS_MINIGRAPH | 1/1 | ✅ | 19s | 227 MB |
| VG_STATS | 1/1 | ✅ | 94ms | 4 MB |
| ODGI_STATS | 1/1 | ✅ | 94ms | 4 MB |
| ODGI_VIZ | 1/1 | ✅ | 107ms | 4 MB |

**ODGI Stats output:**
```yaml
length: 500000
nodes: 5
edges: 0
paths: 5
steps: 5
```

### Bug Fix Applied:
- **ODGI assertion error** (`number < 2^63`): Cactus GFA node ID terlalu besar untuk odgi.
  Fix: tambah `vg ids -s` untuk compact node ID sebelum `odgi build`.
  File: `modules/local/graph_analysis/odgi.nf`

---

## 🔄 Analisis — Tahap 1: Preprocessing (Data Asli)

- [x] Ekstrak semua 5 zip genome dari DATA SKRIPSI
  - [x] EG01 — sudah diekstrak (150M .fna)
  - [x] ASM167249v1 — sudah diekstrak (503M .fna)
  - [x] EGPMv6 — sudah diekstrak (1.2G .fna)
  - [x] EG11 — sudah diekstrak (1.8G .fna)
  - [x] Eg-DCM — sudah diekstrak (1.5G .fna)
- [ ] Rename header FASTA ke PanSN-spec (`sample#hap#seq`)
- [ ] Buat samplesheet.csv dari 5 assembly asli (path ke .fna)

---

## 🔄 Analisis — Tahap 2: Quality Control (QUAST)

- [x] Install QUAST v5.3.0 ✅
- [x] Test QUAST pada sample data ✅
- [ ] Jalankan QUAST pada 5 assembly asli
- [ ] Catat: N50, jumlah contig, total bp, GC% per assembly
- [ ] Tentukan backbone referensi (N50 tertinggi / kromosom-level)

---

## 🔄 Analisis — Tahap 3: Konstruksi Pangenome Graph (Minigraph-Cactus)

- [x] Install minigraph 0.21-r606 ✅
- [x] Install cactus-minigraph via Docker (v2.9.0, 1.07 GB) ✅
- [x] Jalankan minigraph dengan data test_data subset ✅
- [x] Jalankan cactus-minigraph (via Docker) dengan data test_data subset ✅
- [x] Verifikasi output GFA valid ✅
- [ ] Jalankan dengan data asli (5 assembly)

---

## 🔄 Analisis — Tahap 4: Evaluasi & Statistik

- [x] Install odgi v0.9.4 ✅
- [x] Install vg v1.73.0 ✅
- [x] Jalankan `odgi stats` → node, edge, path count ✅ (sample data)
- [x] Jalankan `vg stats` → statistik graph ✅ (sample data)
- [x] Jalankan `odgi viz` → visualisasi 1D ✅ (sample data)
- [ ] Jalankan `bin/extract_core_var.sh` → core & variable sequences
- [ ] Jalankan semua dengan data asli (5 assembly)

---

## 🔄 Tahap 5: Implementasi & Evaluasi HPC Mahameru

- [ ] Akses HPC Mahameru BRIN
- [ ] Upload data dan pipeline ke HPC
- [ ] Jalankan pipeline dengan profile `slurm`
- [ ] Ukur runtime per tahap (dari `trace.tsv`)
- [ ] Test `auto-resume` (simulasi kegagalan)
- [ ] Dokumentasi: `report.html`, `timeline.html`, `dag.html`

---

## 📝 Penulisan Skripsi

- [ ] BAB I — Pendahuluan (dari proposal)
- [ ] BAB II — Landasan Teori (dari proposal)
- [ ] BAB III — Metodologi (update sesuai implementasi nyata)
- [ ] BAB IV — Hasil & Pembahasan
  - [ ] Tabel QC QUAST per assembly
  - [ ] Statistik pangenome (node, edge, path)
  - [ ] Tabel core vs variable sequences
  - [ ] Grafik timeline & runtime
  - [ ] Perbandingan konfigurasi sumber daya
- [ ] BAB V — Kesimpulan & Saran
- [ ] Daftar Pustaka

---

## 🗂️ Riwayat Perubahan Besar

| Tanggal | Perubahan |
|---------|-----------|
| 2026-06-26 | Init repo, setup infrastruktur, push ke GitHub |
| 2026-06-26 | Ganti PGGB → Minigraph-Cactus (sesuai proposal) |
| 2026-06-26 | Tambah QUAST module & subworkflow |
| 2026-06-26 | Tambah `vg_stats.nf` module |
| 2026-06-26 | Tambah `bin/extract_core_var.sh` (core vs variable sequences) |
| 2026-06-26 | README ditulis ulang Bahasa Indonesia + alur sesuai proposal |
| 2026-06-26 | Hapus dummy data generator → ganti dengan real genome subset |
| 2026-06-26 | **Install semua tools via conda**: seqkit, QUAST, minigraph, odgi, vg |
| 2026-06-26 | Tambah profile `conda` di `nextflow.config` |
| 2026-07-11 | **Setup ulang di sistem baru** (dual-boot Linux) |
| 2026-07-11 | Re-install Miniforge3 + conda env `pangenome` + samtools |
| 2026-07-11 | Pull Docker image `cactus:v2.9.0` (1.07 GB) |
| 2026-07-11 | **Fix ODGI assertion error**: tambah `vg ids -s` di `odgi.nf` |
| 2026-07-11 | **🎉 Pipeline test run 100% berhasil** (8/8 step, exit 0) |
| 2026-08-19 | **Hapus Variant Calling** — module, subworkflow, param `call_variants` dihapus total dari pipeline |

---

## 🗓 Timeline Target

| Bulan | Target | Status |
|-------|--------|--------|
| Juni 2026 | ✅ Setup repo, kode pipeline, install tools | ✅ SELESAI |
| Juli 2026 | ✅ Setup sistem baru + test pipeline sample data | ✅ SELESAI (11 Juli) |
| Agustus 2026 | QC QUAST + Minigraph-Cactus (data asli) | ⏳ |
| September 2026 | Graph analysis + evaluasi statistik | ⏳ |
| Oktober 2026 | Implementasi & benchmarking di HPC Mahameru | ⏳ |
| November 2026 | **DEADLINE ANALISIS** + draft BAB IV | ⏳ |
| Desember 2026 | **KOMPREHENSIF** | ⏳ |
