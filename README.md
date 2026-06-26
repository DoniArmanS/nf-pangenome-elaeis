<div align="center">

```
███╗   ██╗███████╗    ██████╗  █████╗ ███╗   ██╗ ██████╗ ███████╗███╗   ██╗ ██████╗ ███╗   ███╗███████╗
████╗  ██║██╔════╝    ██╔══██╗██╔══██╗████╗  ██║██╔════╝ ██╔════╝████╗  ██║██╔═══██╗████╗ ████║██╔════╝
██╔██╗ ██║█████╗      ██████╔╝███████║██╔██╗ ██║██║  ███╗█████╗  ██╔██╗ ██║██║   ██║██╔████╔██║█████╗  
██║╚██╗██║██╔══╝      ██╔═══╝ ██╔══██║██║╚██╗██║██║   ██║██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══╝  
██║ ╚████║██║         ██║     ██║  ██║██║ ╚████║╚██████╔╝███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║███████╗
╚═╝  ╚═══╝╚═╝         ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
```

### `nf-pangenome-elaise`

**Pipeline Nextflow DSL2 untuk konstruksi pangenome graph *Elaeis guineensis* (Kelapa Sawit)**  
**menggunakan Minigraph-Cactus pada infrastruktur HPC**

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62?style=flat-square&logo=nextflow)](https://www.nextflow.io/)
![Status](https://img.shields.io/badge/status-in%20development-orange?style=flat-square)
[![Genome](https://img.shields.io/badge/spesies-Elaeis%20guineensis-green?style=flat-square)](https://www.ncbi.nlm.nih.gov/datasets/taxonomy/51953/)

</div>

---

## 🌴 Tentang Project Ini

Pipeline ini mengotomatisasi seluruh proses konstruksi dan analisis **pangenome graph** dari 5 assembly *Elaeis guineensis* (kelapa sawit) yang tersedia di database publik NCBI. Diimplementasikan menggunakan **Nextflow DSL2** dan berjalan di **HPC Mahameru (BRIN)** dengan sistem penjadwalan **SLURM**.

Pendekatan utama yang digunakan adalah **Minigraph-Cactus** (Hickey et al., 2024) — metode konstruksi pangenome yang menggunakan satu genom berkualitas tinggi (level kromosom) sebagai backbone referensi, kemudian mensejajarkan seluruh assembly lainnya terhadap graf tersebut untuk menangkap seluruh variasi genetik.

> **Tujuan penelitian:**
> 1. Merancang arsitektur pipeline pangenome kelapa sawit yang terotomatisasi dengan Nextflow
> 2. Mengimplementasikan pipeline di HPC Mahameru dengan optimasi alokasi sumber daya Slurm
> 3. Mengevaluasi efisiensi pipeline berdasarkan runtime, penggunaan CPU, dan memori

---

## 📊 Progress & Timeline

```
Infrastructure  ████████████████████  100%
Tool Install    ████████████████████  100%
Pipeline Code   ██████████████████░░   90%
Real Data Run   ████░░░░░░░░░░░░░░░░   20%
HPC Deployment  ████████░░░░░░░░░░░░   40%
─────────────────────────────────────────
KESELURUHAN     ████████░░░░░░░░░░░░  ~40%
```

| Fase | Target Selesai | Status |
|------|----------------|--------|
| 🔧 Setup & Infrastruktur | Juni 2026 | ✅ Selesai |
| 🧬 Install Tools (conda) | Juni 2026 | ✅ Selesai |
| 📥 Preprocessing 5 Assembly | Juli 2026 | 🔜 Berikutnya |
| 📊 QC (QUAST) + Graph Construction | Agustus 2026 | ⏳ |
| 📈 Graph Analysis & Evaluasi | September 2026 | ⏳ |
| 🖥️ HPC Mahameru Benchmarking | Oktober 2026 | ⏳ |
| 📝 **DEADLINE ANALISIS** + BAB IV | **November 2026** | ⏳ |
| 🎓 **KOMPREHENSIF** | **Desember 2026** | ⏳ |

> Lihat detail progress lengkap di [`PROGRESS.md`](PROGRESS.md)

---

## ⚙️ Alur Pipeline

> Setiap tahap merupakan satu `process` Nextflow yang terhubung via `channel`. Semua tahap dieksekusi secara otomatis dan dapat di-*resume* dari titik kegagalan terakhir (`-resume`).

```
  ┌─────────────────────────────────────────────────────────────┐
  │  INPUT                                                      │
  │  5 Assembly Elaeis guineensis (FASTA dari NCBI)            │
  │  EGPMv6 · EG01 · ASM167249v1 · Eg-DCM · EG11             │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  TAHAP 1: Preprocessing                                     │
  │  ├─ seqkit stats  → statistik awal tiap assembly           │
  │  └─ seqkit filter → hapus sekuens < 500bp                  │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  TAHAP 2: Quality Control — QUAST                           │
  │  ├─ Input  : 5 file FASTA                                  │
  │  ├─ Output : laporan per assembly (N50, jumlah contig,     │
  │  │           total panjang basa, GC content %)             │
  │  └─ Tujuan : menentukan backbone referensi terbaik         │
  │              (kromosom-level = N50 tertinggi)              │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  TAHAP 3: Konstruksi Pangenome Graph — Minigraph-Cactus    │
  │  ├─ minigraph       → SV-level graph dari backbone + others│
  │  │                    output: pangenome.gfa (awal)         │
  │  └─ cactus-minigraph → base-level alignment                │
  │                         output: pangenome.full.gfa (final) │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  TAHAP 4: Evaluasi & Statistik Pangenome                    │
  │  ├─ odgi stats → node, edge, path count                    │
  │  ├─ vg stats   → statistik graph level vg                  │
  │  ├─ odgi viz   → visualisasi 1D layout                     │
  │  └─ extract_core_var.sh (Bash Script)                      │
  │       → core sequences   (ada di semua individu)           │
  │       → variable sequences (hanya sebagian individu)       │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  OUTPUT AKHIR                                               │
  │  Laporan statistik pangenome kelapa sawit lengkap          │
  └─────────────────────────────────────────────────────────────┘
```

---

## 📦 Output yang Diharapkan

Sesuai proposal penelitian, output yang dihasilkan pipeline ini adalah:

### 📊 Tahap QC (QUAST)

| File | Keterangan |
|------|-----------|
| `qc/{sample}/report.tsv` | Statistik per assembly: N50, jumlah contig, total bp, GC% |
| `qc/{sample}/report.html` | Laporan visual QUAST per assembly |

### 🔗 Tahap Konstruksi Graph (Minigraph-Cactus)

| File | Keterangan |
|------|-----------|
| `graph/pangenome.gfa` | SV-level pangenome graph (dari minigraph) |
| `graph/pangenome.full.gfa` | Base-level pangenome graph (output final Cactus) |

### 📈 Tahap Evaluasi & Statistik

| File | Keterangan |
|------|-----------|
| `analysis/pangenome.stats.yaml` | Statistik graph: jumlah **node, edge, path** (odgi stats) |
| `analysis/pangenome.vg_stats.txt` | Statistik graph via **vg stats** |
| `analysis/pangenome.1D.png` | Visualisasi 1D layout pangenome (odgi viz) |
| `analysis/core_sequences.txt` | Daftar sekuens **inti** (ada di semua 5 assembly) |
| `analysis/variable_sequences.txt` | Daftar sekuens **variabel** (hanya sebagian assembly) |
| `analysis/pangenome_summary.tsv` | Laporan statistik pangenome final |

### ⚡ Laporan Eksekusi Pipeline (Nextflow)

| File | Keterangan |
|------|-----------|
| `pipeline_info/report.html` | Laporan eksekusi lengkap dengan runtime per proses |
| `pipeline_info/timeline.html` | Grafik timeline eksekusi visual |
| `pipeline_info/trace.tsv` | Tabel penggunaan CPU & memori per proses |
| `pipeline_info/dag.html` | Grafik alur pipeline (DAG — Directed Acyclic Graph) |

> **Catatan:** `report.html`, `timeline.html`, `trace.tsv`, dan `dag.html` digunakan untuk evaluasi performa pipeline (runtime, CPU usage, memory usage) sebagaimana disebutkan di proposal Bab Pengujian & Evaluasi.

---

## 🚀 Cara Pakai

### Prasyarat

| Kebutuhan | Versi | Catatan |
|-----------|-------|---------|
| [Nextflow](https://www.nextflow.io/) | ≥ 23.04.0 | Wajib |
| Java | ≥ 11 | Wajib |
| Singularity | — | Untuk HPC (Mahameru) |
| Docker | — | Untuk pengembangan lokal |

### Install Nextflow (tanpa sudo)

```bash
curl -s https://get.nextflow.io | bash
mkdir -p ~/.local/bin && mv nextflow ~/.local/bin/
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
nextflow -version
```

### Test Cepat — Stub Mode (Tanpa Tool, Tanpa HPC)

```bash
# Pipeline disimulasikan penuh tanpa menjalankan tool apapun
nextflow run main.nf -profile test -stub
```

### Lokal — Data Test (Subset Asli)

```bash
# Generate subset dari genome asli (pertama kali saja)
python3 tests/subset_real_data.py

# Jalankan dengan referensi EGPMv6 (kromosom-level)
nextflow run main.nf \
    -profile local \
    --input tests/test_data/samplesheet.csv \
    --reference_name EGPMv6 \
    --outdir results/
```

### HPC Mahameru (SLURM)

```bash
nextflow run main.nf \
    -profile slurm \
    --input /path/to/samplesheet.csv \
    --reference_name EGPMv6 \
    --outdir /scratch/results/ \
    -resume
```

### Resume setelah Error

```bash
nextflow run main.nf -profile test -stub -resume
```

---

## 📋 Format Input

### Samplesheet CSV

```csv
sample,fasta,cultivar
EGPMv6,path/to/EGPMv6.fa,AVROS
EG01,path/to/EG01.fa,Jacq
ASM167249v1,path/to/ASM167249v1.fa,Dura
Eg-DCM,path/to/EgDCM.fa,DCM
EG11,path/to/EG11.fa,Tenera
```

> ⚠️ Nilai `sample` untuk backbone referensi harus sama persis dengan `--reference_name`

### Format Header FASTA (PanSN-spec)

```
>{sample}#{haplotype}#{nama_sekuens}

# Contoh:
>EGPMv6#1#GK000076.1
```

---

## 🎛️ Parameter

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `--input` | `null` | Path ke samplesheet CSV |
| `--outdir` | `./results` | Direktori output |
| `--reference_name` | `null` | **Wajib** — nama sample backbone referensi |
| `--min_seq_len` | `500` | Panjang minimum sekuens (filter seqkit) |
| `--min_contig` | `500` | Panjang minimum contig untuk QUAST |
| `--mg_preset` | `ggs` | Minigraph preset (`ggs` = genome-to-graph) |
| `--cactus_cores` | `8` | Jumlah CPU untuk cactus-minigraph |
| `--call_variants` | `false` | Aktifkan variant calling (vg deconstruct) |
| `--max_memory` | `16.GB` | Batas memori maksimum |
| `--max_cpus` | `8` | Batas CPU maksimum |
| `--max_time` | `24.h` | Batas waktu eksekusi |

---

## 🖥️ Profile Eksekusi

| Profile | Executor | Container | Deskripsi |
|---------|----------|-----------|-----------|
| `local` | local | — | Laptop/PC tanpa container |
| `conda` | local | Conda env | **Direkomendasikan** — pakai env `pangenome` |
| `docker` | local | Docker | Pengembangan lokal dengan container |
| `singularity` | local | Singularity | HPC-compatible |
| `slurm` | Slurm | Singularity | **HPC Mahameru BRIN** |
| `test` | local | — | Data subset real, resource dikurangi |

---

## 🗂️ Struktur Project

```
nf-pangenome-elaise/
│
├── 📄 main.nf                           # Entry point pipeline
├── ⚙️ nextflow.config                    # Parameter, profile, resource
│
├── workflows/
│   └── pangenome.nf                     # Orkestrator utama (5 tahap)
│
├── subworkflows/local/
│   ├── validate_input.nf                # Parsing & validasi samplesheet
│   ├── preprocessing.nf                 # seqkit stats + filter
│   ├── qc.nf                            # QUAST — QC assembly
│   ├── graph_construction.nf            # Minigraph + Cactus
│   ├── graph_analysis.nf                # odgi stats, vg stats, visualisasi
│   └── variant_calling.nf              # vg deconstruct (opsional)
│
├── modules/local/
│   ├── preprocessing/
│   │   ├── seqkit_stats.nf
│   │   └── seqkit_filter.nf
│   ├── qc/
│   │   └── quast.nf                     # QUAST — output laporan kualitas
│   ├── graph_construction/
│   │   ├── minigraph.nf                 # SV-level graph
│   │   └── cactus_minigraph.nf          # Base-level graph (output final)
│   ├── graph_analysis/
│   │   ├── odgi.nf                      # odgi stats + odgi viz (1D layout)
│   │   └── vg_stats.nf                  # vg stats — node, edge, length
│   └── variant_calling/
│       └── vg_deconstruct.nf
│
├── bin/
│   └── extract_core_var.sh              # Bash script: core vs variable sequences
│
├── conf/                                # Konfigurasi HPC/Slurm terpisah
│
├── tests/
│   ├── subset_real_data.py              # Buat subset dari genome asli
│   └── test_data/                       # Subset kecil (masuk git)
│       ├── EGPMv6.fa                    # 5 seq × 100kb — AVROS (kromosom-level)
│       ├── EG01.fa                      # 5 seq × 100kb — EG01
│       ├── ASM167249v1.fa               # 5 seq × 100kb — Dura
│       └── samplesheet.csv
│
├── 📊 PROGRESS.md                       # Checklist progress per tahap
├── 🐛 ERRORS.md                         # Log error & debugging notes
└── docs/
    └── NEXTFLOW_PRINCIPLES.md           # Panduan coding Nextflow
```

---

## 🛠️ Tools yang Digunakan

| Tool | Fungsi | Referensi |
|------|--------|-----------|
| [QUAST](https://quast.sourceforge.net/) | QC assembly — N50, contig count, GC%, total bp | Gurevich et al. 2013 |
| [minigraph](https://github.com/lh3/minigraph) | Konstruksi SV-level pangenome graph | Li et al. 2020 |
| [cactus-minigraph](https://github.com/ComparativeGenomicsToolkit/cactus) | Base-level pangenome graph | Hickey et al. 2024 |
| [odgi](https://odgi.readthedocs.io) | Statistik & visualisasi graph (odgi stats, odgi viz) | Guarracino et al. |
| [vg](https://github.com/vgteam/vg) | Statistik graph (vg stats) & variant calling | Garrison et al. |
| [seqkit](https://bioinf.shenwei.me/seqkit) | Preprocessing FASTA (stats & filter) | Shen et al. |

**Referensi utama:**
- Hickey et al. (2024). *Pangenome graph construction from genome alignments with Minigraph-Cactus*. [Nature Biotechnology](https://doi.org/10.1038/s41587-023-01793-w)
- [Cactus — Comparative Genomics Toolkit](https://github.com/ComparativeGenomicsToolkit/cactus)
- [nf-core guidelines](https://nf-co.re/docs/contributing/guidelines)
- [PanSN-spec](https://github.com/pangenome/PanSN-spec)

---

## 📖 Pengembangan

Baca [`docs/NEXTFLOW_PRINCIPLES.md`](docs/NEXTFLOW_PRINCIPLES.md) untuk panduan coding.

Pantau progres di [`PROGRESS.md`](PROGRESS.md) dan catat error di [`ERRORS.md`](ERRORS.md).

---

<div align="center">

---

*Made with 🤍 by **Doni Arman***

*Sistem Informasi · Universitas Riau · 2026*

</div>
