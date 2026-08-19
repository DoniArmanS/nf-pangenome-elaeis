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

Pipeline ini mengotomatisasi seluruh proses konstruksi dan analisis **pangenome graph** dari 3 assembly *Elaeis guineensis* (kelapa sawit) yang tersedia di database publik NCBI. Diimplementasikan menggunakan **Nextflow DSL2** dan berjalan di **HPC Mahameru (BRIN)** dengan sistem penjadwalan **SLURM**.

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
Pipeline Code   ████████████████████  100%  ✅ Tested
Test Data Run   ████████████████████  100%  ✅ 8/8 Steps
Real Data Run   ████░░░░░░░░░░░░░░░░   20%
HPC Deployment  ████████░░░░░░░░░░░░   40%
─────────────────────────────────────────
KESELURUHAN     ███████████░░░░░░░░░  ~55%
```

| Fase | Target Selesai | Status |
|------|----------------|--------|
| 🔧 Setup & Infrastruktur | Juni 2026 | ✅ Selesai |
| 🧬 Install Tools (conda + Docker) | Juli 2026 | ✅ Selesai |
| ✅ **Test Pipeline (sample data)** | **Juli 2026** | **✅ 8/8 Steps** |
| 📥 Preprocessing 5 Assembly | Juli-Agustus 2026 | 🔜 Berikutnya |
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
  │  samplesheet.csv — daftar 3 assembly FASTA kelapa sawit     │
  │  (EG11, EGPMv6, Eg-DCM)                                     │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  TAHAP 1: Preprocessing                                     │
  │  ├─ seqkit stats  → statistik dasar (jumlah seq, total bp) │
  │  └─ seqkit seq    → filter min length 500bp                │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  TAHAP 2: Quality Control                                   │
  │  └─ QUAST  → N50, jumlah contig, GC%, total bp             │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  TAHAP 3: Konstruksi Pangenome Graph (Minigraph-Cactus)     │
  │  ├─ minigraph     → SV-level graph (.gfa) dari referensi   │
  │  └─ cactus-minigraph → base-level graph (.full.gfa)        │
  │       Input: seqFile.txt + minigraph.gfa                    │
  │       Output: pangenome graph level basa (GFA final)        │
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
| `analysis/core_sequences.txt` | Daftar sekuens **inti** (ada di semua 3 assembly) |
| `analysis/variable_sequences.txt` | Daftar sekuens **variabel** (hanya sebagian assembly) |
| `analysis/pangenome_summary.tsv` | Laporan statistik pangenome final |

### ⚡ Laporan Eksekusi Pipeline (Nextflow)

| File | Keterangan |
|------|-----------|
| `pipeline_info/report.html` | Laporan eksekusi lengkap dengan runtime per proses |
| `pipeline_info/timeline.html` | Grafik timeline eksekusi visual |
| `pipeline_info/trace.tsv` | Tabel penggunaan CPU & memori per proses |
| `pipeline_info/dag.html` | Grafik alur pipeline (DAG — Directed Acyclic Graph) |

---

## 🚀 Cara Pakai

Pipeline ini dibagi menjadi **3 bagian utama**:

1. [📋 Bagian 1: Daftar Akun HPC Mahameru BRIN](#-bagian-1-daftar-akun-hpc-mahameru-brin)
2. [💻 Bagian 2: Menjalankan Pipeline](#-bagian-2-menjalankan-pipeline)
3. [🔄 Bagian 3: Mengganti Data untuk Organisme Lain](#-bagian-3-mengganti-data-untuk-organisme-lain)

---

### 📋 Bagian 1: Daftar Akun HPC Mahameru BRIN

Pipeline ini dirancang untuk dijalankan di **HPC Mahameru BRIN** dengan scheduler **SLURM**. Berikut langkah pendaftarannya:

> 📖 Referensi lengkap: [tmelialab/HPC](https://github.com/tmelialab/HPC)

**Langkah 1 — Daftar akun ELSA BRIN**
1. Buka [https://elsa.brin.go.id/akun](https://elsa.brin.go.id/akun)
2. Daftarkan akun dengan Nama Lengkap, Email, dan Identitas diri

**Langkah 2 — Ajukan layanan HPC untuk Bioinformatika**
1. Buka [halaman pengajuan layanan HPC Bioinformatika](https://elsa.brin.go.id/layanan/index/%20HPC%20untuk%20%20Bioinformatika%20/6393)
2. Isi formulir:
   - **Judul Proposal** — sesuai skripsi/penelitian
   - **Abstrak** — dari proposal skripsi
   - **Daftar Anggota** — nama kamu + nama dosen pembimbing (wajib untuk mahasiswa)
   - **Perangkat Lunak** — `SLURM, Conda, Singularity, Nextflow`
   - **Public Key** — upload SSH public key (lihat cara buat di bawah)
3. Tunggu email approval dari pengelola HPC

**Langkah 3 — Buat SSH Key**
```bash
# Di laptop (Linux/Mac)
ssh-keygen -t rsa -b 4096

# Windows (PowerShell)
ssh-keygen
```
Upload file `~/.ssh/id_rsa.pub` ke formulir ELSA BRIN.

**Langkah 4 — Login ke HPC Mahameru**
```bash
ssh <username>@login2.hpc.brin.go.id
```

> ⚠️ **Penting:**
> - Akun sivitas eksternal BRIN expired setiap **3 bulan** — kirim email ke `hpc@brin.go.id` untuk aktivasi ulang
> - Download data/aplikasi hanya bisa melalui **login node**, bukan worker node
> - Partisi yang tersedia: `interactive` (maks 2 jam), `short` (maks 24 jam), `medium-small` (maks 72 jam)

---

### 💻 Bagian 2: Menjalankan Pipeline

#### Prasyarat

| Kebutuhan | Versi | Catatan |
|-----------|-------|---------|
| [Nextflow](https://www.nextflow.io/) | ≥ 23.04.0 | Wajib |
| Java | ≥ 11 | Wajib |
| [Conda/Mamba](https://github.com/conda-forge/miniforge) | — | Untuk install tools lokal |
| Docker | — | Untuk cactus-minigraph |
| Singularity | — | Untuk HPC |

#### Step 1 — Install Nextflow

```bash
curl -s https://get.nextflow.io | bash
mkdir -p ~/.local/bin && mv nextflow ~/.local/bin/
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
nextflow -version
```

#### Step 2 — Install Tools via Conda

```bash
# Install Miniforge (conda + mamba)
curl -L -o miniforge.sh \
  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash miniforge.sh -b -p $HOME/miniforge3
$HOME/miniforge3/bin/conda init bash
source ~/.bashrc

# Buat environment khusus pangenome
mamba create -y -n pangenome python=3.12
conda activate pangenome

# Install semua tools bioinformatika
mamba install -y -c bioconda -c conda-forge seqkit quast minigraph odgi vg
```

#### Step 3 — Install Cactus (Docker)

```bash
# Cactus hanya tersedia via Docker image (~1GB)
sudo usermod -aG docker $USER   # pertama kali saja, lalu restart/logout
docker pull quay.io/comparative-genomics-toolkit/cactus:v2.9.0
```

#### Step 4 — Clone Repository

```bash
git clone https://github.com/DoniArmanS/nf-pangenome-elaise.git
cd nf-pangenome-elaise
```

#### Step 5 — Siapkan Data

Taruh file FASTA assembly ke folder `data/`:

```
data/
├── EG11/           ← taruh EG11.fa di sini (referensi backbone)
├── EGPMv6/         ← taruh EGPMv6.fa di sini
└── Eg-DCM/         ← taruh EgDCM.fa di sini
```

Lalu buat file `samplesheet.csv`:

```csv
sample,fasta,cultivar
EG11,data/EG11/EG11.fa,Tenera
EGPMv6,data/EGPMv6/EGPMv6.fa,AVROS
Eg-DCM,data/Eg-DCM/EgDCM.fa,DCM
```

> ⚠️ Nilai `sample` untuk backbone referensi **harus sama persis** dengan `--reference_name`

#### Step 6 — Jalankan Pipeline

```bash
# ═══════════════════════════════════════════════════
# Opsi A: Test lokal (data subset kecil, di laptop)
# ═══════════════════════════════════════════════════
conda activate pangenome
nextflow run main.nf -profile test,conda

# ═══════════════════════════════════════════════════
# Opsi B: Data asli di laptop
# ═══════════════════════════════════════════════════
nextflow run main.nf \
    -profile conda \
    --input samplesheet.csv \
    --reference_name EGPMv6 \
    --outdir results/

# ═══════════════════════════════════════════════════
# Opsi C: HPC Mahameru (SLURM + Singularity)
# ═══════════════════════════════════════════════════
nextflow run main.nf \
    -profile slurm \
    --input /path/to/samplesheet.csv \
    --reference_name EGPMv6 \
    --outdir /scratch/results/ \
    -resume
```

#### Resume Setelah Error

```bash
# Nextflow otomatis melanjutkan dari proses yang gagal
nextflow run main.nf -profile test,conda -resume
```

---

### 🔄 Bagian 3: Mengganti Data untuk Organisme Lain

Pipeline ini **tidak terbatas untuk kelapa sawit** — bisa dipakai untuk organisme apapun yang punya beberapa assembly genome. Berikut caranya:

#### 1. Siapkan Assembly Genome

Download assembly dari [NCBI Datasets](https://www.ncbi.nlm.nih.gov/datasets/) atau sumber lain. Contoh untuk **padi** (*Oryza sativa*):

```bash
# Contoh: buat folder untuk 3 assembly padi
mkdir -p data/Nipponbare data/IR64 data/Kasalath
# Taruh file .fa / .fna / .fasta ke masing-masing folder
```

#### 2. Rename Header FASTA ke PanSN-spec

Semua header FASTA **wajib** mengikuti format [PanSN-spec](https://github.com/pangenome/PanSN-spec):

```
>{sample}#{haplotype}#{nama_sekuens}

# Contoh kelapa sawit:
>EGPMv6#1#GK000076.1

# Contoh padi:
>Nipponbare#1#Chr01
```

Script untuk rename header:
```bash
# Contoh: rename header untuk sample "Nipponbare"
sed -i 's/^>\(.*\)/>Nipponbare#1#\1/' data/Nipponbare/Nipponbare.fa
```

#### 3. Buat Samplesheet Baru

Buat file `samplesheet_padi.csv`:

```csv
sample,fasta,cultivar
Nipponbare,data/Nipponbare/Nipponbare.fa,Japonica
IR64,data/IR64/IR64.fa,Indica
Kasalath,data/Kasalath/Kasalath.fa,Aus
```

#### 4. Jalankan dengan Parameter Baru

```bash
nextflow run main.nf \
    -profile conda \
    --input samplesheet_padi.csv \
    --reference_name Nipponbare \
    --outdir results_padi/
```

> 💡 **Tips:**
> - `--reference_name` harus diisi dengan assembly **terbaik** (level kromosom, N50 tertinggi)
> - Assembly minimum yang dibutuhkan: **3** (1 referensi + 2 non-referensi)
> - Nama sample di samplesheet harus **unik** dan **tanpa spasi/karakter khusus**
> - Jangan lupa rename header FASTA ke PanSN-spec **sebelum** menjalankan pipeline

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
│   └── pangenome.nf                     # Orkestrator utama (4 tahap)
│
├── subworkflows/local/
│   ├── validate_input.nf                # Parsing & validasi samplesheet
│   ├── preprocessing.nf                 # seqkit stats + filter
│   ├── qc.nf                            # QUAST — QC assembly
│   ├── graph_construction.nf            # Minigraph + Cactus
│   └── graph_analysis.nf                # odgi stats, vg stats, visualisasi
│
├── modules/local/
│   ├── preprocessing/
│   │   ├── seqkit_stats.nf
│   │   └── seqkit_filter.nf
│   ├── qc/
│   │   └── quast.nf                     # QUAST — output laporan kualitas
│   ├── graph_construction/
│   │   ├── minigraph.nf                 # SV-level graph
│   │   └── cactus_minigraph.nf          # Base-level graph (Docker container)
│   └── graph_analysis/
│       ├── odgi.nf                      # odgi stats + odgi viz (1D layout)
│       └── vg_stats.nf                  # vg stats — node, edge, length
│
├── bin/
│   └── extract_core_var.sh              # Bash script: core vs variable sequences
│
├── conf/
│   ├── test.config                      # Config laptop (2 CPU, 4GB RAM)
│   └── hpc.config                       # Config HPC Mahameru (SLURM, 128 CPU)
│
├── data/                                # ← TARUH DATA ASSEMBLY DI SINI
│   ├── EG11/                            #   Assembly referensi (kromosom-level)
│   ├── EGPMv6/                          #   Assembly EGPMv6
│   └── Eg-DCM/                          #   Assembly DCM
│
├── tests/
│   ├── subset_real_data.py              # Buat subset dari genome asli
│   └── test_data/                       # Subset kecil (masuk git)
│       ├── EGPMv6.fa, EG01.fa, ASM167249v1.fa
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
| [vg](https://github.com/vgteam/vg) | Statistik graph (vg stats) | Garrison et al. |
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
