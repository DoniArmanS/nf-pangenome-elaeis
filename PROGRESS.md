# 📋 Progress Skripsi — nf-pangenome-elaise
> Terakhir diupdate: **2026-08-28**
> **Deadline Analisis: November 2026 | Komprehensif: Desember 2026**

---

## 📊 Persentase Kesiapan Keseluruhan

```
Infrastructure  ████████████████████  100%
Tool Install    ████████████████████  100%  ✅ SEMUA (Cactus: native binary di HPC)
Preprocessing   ████████████████████  100%  ✅ Data produksi (3 assembly asli)
QC (QUAST)      ████████████████████  100%  ✅ Data produksi (3 assembly asli)
Graph Construct ████████████████████  100%  ✅ Minigraph + Cactus BERHASIL (produksi)
Graph Analysis  ████████████████████  100%  ✅ odgi stats/viz + vg stats, 7 titik ukuran
HPC/Slurm       ████████████████████  100%  ✅ Deployment & eksekusi produksi selesai
Resource Bench  ████████████████████  100%  ✅ 7 titik ukuran x 3 pengulangan, modul rekomendasi jadi
Penulisan BAB   ██████████████████░░   90%  ✅ BAB I-IV selesai, BAB V & Abstrak menyusul
─────────────────────────────────────────────
TOTAL ANALISIS  ██████████████████░░  ~90%
```

> **Catatan:** Naik dari ~55% (Juli) setelah eksekusi produksi penuh berhasil di HPC
> Mahameru (32 core/64GB), migrasi Cactus dari Singularity ke native binary install,
> rangkaian benchmark resource-aware selesai untuk seluruh titik ukuran, dan BAB IV
> selesai ditulis lengkap (4.1–4.6, mengikuti kerangka Evolutionary Prototyping).

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
| cactus-minigraph | v2.9.0 | Docker image (lokal) / **native binary di HPC** (`~/cactus-bin-v2.9.0/`) | ✅ |
| Docker | v29.1.3 | apt (lokal saja, tidak dipakai di HPC) | ✅ |

> **Conda environment:** `pangenome` → `~/miniforge3/envs/pangenome/` (2.4 GB)
> **Cara aktivasi:** `conda activate pangenome`
> **Nextflow profile lokal:** `-profile conda` — **profile HPC:** `-profile conda,slurm`
> **Catatan migrasi:** Cactus di HPC awalnya dicoba via Singularity, tapi gagal konsisten
> di sejumlah node (galat `unknown userid`, akibat cache SSSD/LDAP). Solusi permanen:
> instalasi biner native (bukan container) — lihat `conf/hpc.config`.

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
- [x] `workflows/pangenome.nf` — 5 subworkflow (variant calling sudah dihapus total dari scope)

### Scripts & Dokumentasi
- [x] `bin/recommend_resources.sh` — rekomendasi alokasi CPU/RAM dari `trace.tsv`
- [x] `run_hpc.sh` — submit SLURM, generik untuk run produksi & benchmark
- [x] `tests/subset_real_data.py` — subset genome asli (fixture test lama)
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

## ✅ Analisis Data Produksi (3 Assembly Asli: EG11, EGPMv6, Eg-DCM)

> Cakupan riset difinalkan ke **3 assembly** (bukan 5) atas arahan dosen pembimbing —
> lebih sedikit assembly berarti lebih sedikit node graph, sehingga eksekusi tidak
> memakan waktu berlebihan pada klaster HPC bersama.

- [x] Header FASTA di-rename ke PanSN-spec, `samplesheet.csv` produksi dibuat
- [x] QUAST dijalankan pada seluruh 3 assembly asli — N50, jumlah contig, GC% tercatat
- [x] Minigraph + Cactus-Minigraph dijalankan pada data produksi penuh — **BERHASIL, exit 0**
- [x] ODGI stats/viz + VG stats dijalankan — statistik graph final tercatat
  (lihat `pangenome_results/analysis/pangenome.stats.yaml`)
- [x] Eksekusi produksi penuh di HPC Mahameru (32 core / 64GB, partisi `medium-small`)
- [x] Rangkaian benchmark resource-aware pada 7 titik ukuran data (progresif, hingga
  genom penuh), masing-masing 3x pengulangan independen (mode `noresume`)
- [x] Modul `bin/recommend_resources.sh` — rekomendasi alokasi CPU/RAM dari trace.tsv real
- [x] Instrumentasi `-with-report`/`-with-timeline`/`-with-trace` aktif di setiap eksekusi

**Temuan utama (ringkas):**
- Peak RAM proporsional terhadap ukuran data (0,45GB → 61,6GB); Peak %CPU **tidak**
  proporsional (baru efektif memanfaatkan multi-core di skala genom penuh)
- Rekomendasi sistem untuk eksekusi produksi berikutnya: **8 core, 74GB** (vs alokasi
  aktual 32 core/64GB) — penghematan ~75% CPU, koreksi +15,6% RAM untuk margin aman

### Bug Fix Applied:
- **ODGI assertion error** (`number < 2^63`): Cactus GFA node ID terlalu besar untuk odgi.
  Fix: tambah `vg ids -s` untuk compact node ID sebelum `odgi build`.
  File: `modules/local/graph_analysis/odgi.nf`
- **Singularity gagal di HPC** (`unknown userid`): akar masalah cache SSSD/LDAP tidak
  konsisten per-node. Fix permanen: migrasi Cactus ke instalasi biner native.

---

## 📝 Penulisan Skripsi

- [x] BAB I — Pendahuluan
- [x] BAB II — Landasan Teori
- [x] BAB III — Metodologi (Evolutionary Prototyping, desain eksperimen benchmark)
- [x] BAB IV — Hasil & Pembahasan (4.1–4.6, dikunci ke 6 tahap Evolutionary Prototyping)
  - [x] Tabel QC QUAST, statistik pangenome (node/edge/path/step)
  - [x] Grafik skalabilitas RAM/CPU/durasi vs ukuran data (rata-rata 3x eksekusi)
  - [x] Rekomendasi & estimasi penghematan alokasi sumber daya
- [ ] BAB V — Kesimpulan & Saran (masih draf lama, perlu ditulis ulang)
- [ ] Abstrak — perlu angka final (rekomendasi 8 core/74GB, dll.)
- [ ] Daftar Pustaka — cek kelengkapan sitasi

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
| 2026-08-19 | **Pivot fokus riset ke resource-aware** — dari sekadar "pipeline otomatis" menjadi "pipeline yang merekomendasikan alokasi sumber daya optimal", dipicu temuan kesenjangan alokasi vs penggunaan aktual (61GB terpakai dari 64GB, 7 core efektif dari 32 core) |
| 2026-08-20 | **Migrasi Cactus dari Singularity ke native binary install** di HPC — mengatasi galat `unknown userid` (cache SSSD/LDAP tidak konsisten) |
| 2026-08-24 | Tambah mode `noresume` di `run_hpc.sh` + `bin/recommend_resources.sh` — modul rekomendasi alokasi CPU/RAM dari trace.tsv |
| 2026-08-20 s.d. 08-27 | Eksekusi produksi penuh & rangkaian benchmark resource-aware — 7 titik ukuran data, masing-masing 3x pengulangan independen — **selesai seluruhnya** |
| 2026-08-28 | **BAB IV selesai ditulis lengkap** (4.1–4.6), struktur dikunci ke 6 tahap Evolutionary Prototyping |

---

## 🗓 Timeline Target

| Bulan | Target | Status |
|-------|--------|--------|
| Juni 2026 | ✅ Setup repo, kode pipeline, install tools | ✅ SELESAI |
| Juli 2026 | ✅ Setup sistem baru + test pipeline sample data | ✅ SELESAI (11 Juli) |
| Agustus 2026 | QC QUAST + Minigraph-Cactus (data asli), deployment & benchmark di HPC, penulisan BAB IV | ✅ SELESAI |
| September–Oktober 2026 | *(dipercepat — sudah tercapai di Agustus)* | ✅ |
| November 2026 | **DEADLINE ANALISIS** — BAB V, Abstrak, finalisasi naskah lengkap | ⏳ |
| Desember 2026 | **KOMPREHENSIF** | ⏳ |
