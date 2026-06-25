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

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62?style=flat-square&logo=nextflow)](https://www.nextflow.io/)
![Status](https://img.shields.io/badge/status-in%20development-orange?style=flat-square)
[![Genome](https://img.shields.io/badge/spesies-Elaeis%20guineensis-green?style=flat-square)](https://www.ncbi.nlm.nih.gov/datasets/taxonomy/51953/)

</div>

---

## 🌴 Tentang Project Ini

Pipeline ini dibangun untuk mengkonstruksi dan menganalisis **pangenome graph** dari beberapa assembly *Elaeis guineensis* (kelapa sawit). Menggunakan pendekatan **Minigraph-Cactus** yang diimplementasikan lewat Nextflow DSL2, pipeline ini memungkinkan analisis variasi struktural (SV) antar varietas kelapa sawit secara reproducible dan scalable — dari laptop biasa hingga cluster HPC.

> *Kenapa pangenome?* Satu referensi tunggal tidak cukup untuk merepresentasikan keragaman genetik suatu spesies. Pangenome graph menyimpan **semua** variasi — bukan hanya yang cocok dengan referensi.

---

## ⚙️ Alur Pipeline

```
  Input: FASTA Assembly (EGPMv6, EG01, ASM167249v1, Eg-DCM, EG11)
         │
         ▼
  ┌──────────────────────────────────────┐
  │  Preprocessing                       │
  │  seqkit stats → seqkit filter       │
  └──────────────┬──────────────────────┘
                 │
                 ▼
  ┌─────────────────────────────────────┐
  │  Konstruksi Pangenome Graph         │
  │  wfmash   → All-vs-all alignment   │
  │  seqwish  → Graph induction        │
  │  smoothxg → Normalisasi graph      │
  └──────────────┬──────────────────────┘
                 │
                 ▼
  ┌─────────────────────────────────────┐
  │  Analisis Graph                     │
  │  odgi stats → Statistik graph      │
  │  odgi viz   → Visualisasi 1D/2D    │
  └──────────────┬──────────────────────┘
                 │
                 ▼
  ┌─────────────────────────────────────┐
  │  Variant Calling (opsional)         │
  │  vg deconstruct → VCF output       │
  └──────────────┬──────────────────────┘
                 │
                 ▼
  ┌─────────────────────────────────────┐
  │  MultiQC — Laporan QC teragregasi  │
  └─────────────────────────────────────┘
```

---

## 🚀 Cara Pakai

### Prasyarat

| Kebutuhan | Versi | Catatan |
|-----------|-------|---------|
| [Nextflow](https://www.nextflow.io/) | ≥ 23.04.0 | Wajib |
| Java | ≥ 11 | Wajib (dibutuhkan Nextflow) |
| Docker / Singularity / Conda | — | Salah satu untuk menjalankan tools |

### Install Nextflow (tanpa sudo)

```bash
# Download dan simpan ke ~/.local/bin
curl -s https://get.nextflow.io | bash
mkdir -p ~/.local/bin && mv nextflow ~/.local/bin/
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# Verifikasi
nextflow -version
```

### Test Cepat (Tanpa Tool, Tanpa HPC)

```bash
# Jalankan pipeline dalam stub mode — semua proses disimulasikan
nextflow run main.nf -profile test -stub
```

### Jalankan dengan Data Test Asli

```bash
# Regenerate subset dari genome asli (pertama kali saja)
python3 tests/subset_real_data.py

# Jalankan lokal
nextflow run main.nf \
    -profile local \
    --input tests/test_data/samplesheet.csv \
    --outdir results/
```

### Lanjut setelah Error

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
```

### Format Header FASTA (PanSN-spec)

Header FASTA **harus** menggunakan format PanSN-spec agar bisa dibaca pipeline:

```
>{sample}#{haplotype}#{nama_sekuens}

# Contoh:
>EGPMv6#1#GK000076.1
```

Lihat spesifikasi lengkapnya di [PanSN-spec](https://github.com/pangenome/PanSN-spec).

---

## 🎛️ Parameter

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `--input` | `null` | Path ke samplesheet CSV atau FASTA tunggal |
| `--outdir` | `./results` | Direktori output |
| `--mode` | `full` | `full` \| `graph_only` \| `variant_only` |
| `--segment_len` | `5000` | Panjang segmen wfmash (`-s`) |
| `--min_map_pct` | `90` | Persentase identitas minimum wfmash (`-p`) |
| `--n_haplotypes` | `5` | Jumlah haplotype wfmash (`-n`) |
| `--min_match_len` | `311` | Panjang match minimum seqwish (`-k`) |
| `--call_variants` | `false` | Aktifkan variant calling dengan vg |
| `--reference` | `null` | Referensi untuk VCF deconstruct |
| `--max_memory` | `16.GB` | Batas memori maksimum |
| `--max_cpus` | `8` | Batas CPU maksimum |

---

## 🖥️ Profile Eksekusi

| Profile | Deskripsi |
|---------|-----------|
| `local` | Jalankan di laptop/PC tanpa container |
| `docker` | Jalankan dengan Docker |
| `singularity` | Jalankan dengan Singularity (cocok untuk HPC) |
| `slurm` | Jalankan di cluster dengan SLURM scheduler |
| `test` | Pakai `tests/test_data/`, resource dikurangi untuk lokal |

---

## 🗂️ Struktur Project

```
nf-pangenome-elaise/
│
├── 📄 main.nf                        # Entry point pipeline
├── ⚙️ nextflow.config                 # Parameter, profile, resource
│
├── workflows/
│   └── pangenome.nf                  # Orkestrator workflow utama
│
├── subworkflows/local/
│   ├── validate_input.nf             # Parsing & validasi input
│   ├── preprocessing.nf              # QC & filter sekuens
│   ├── graph_construction.nf         # wfmash → seqwish → smoothxg
│   ├── graph_analysis.nf             # odgi stats & visualisasi
│   └── variant_calling.nf            # vg deconstruct → VCF
│
├── modules/local/
│   ├── preprocessing/                # seqkit_stats, seqkit_filter
│   ├── alignment/                    # wfmash
│   ├── graph_construction/           # seqwish, smoothxg
│   ├── graph_analysis/               # odgi
│   └── variant_calling/              # vg_deconstruct
│
├── tests/
│   ├── subset_real_data.py           # Buat subset dari genome asli
│   └── test_data/                    # Subset kecil (masuk git)
│       ├── EGPMv6.fa                 # 5 seq × 100kb — AVROS
│       ├── EG01.fa                   # 5 seq × 100kb — EG01
│       ├── ASM167249v1.fa            # 5 seq × 100kb — Dura
│       └── samplesheet.csv
│
├── docs/
│   └── NEXTFLOW_PRINCIPLES.md        # Panduan coding Nextflow project ini
│
├── 📊 PROGRESS.md                    # Checklist progress pengerjaan
└── 🐛 ERRORS.md                      # Log error & solusinya
```

---

## 📦 Output Pipeline

```
results/
├── preprocessing/      # Laporan seqkit stats
├── alignment/          # File PAF hasil alignment
├── graph/              # GFA pangenome graph (raw & smooth)
├── analysis/           # Statistik ODGI, visualisasi 1D & 2D
├── variants/           # File VCF (jika --call_variants aktif)
└── pipeline_info/      # Report, timeline, trace, DAG eksekusi
```

---

## 🛠️ Tools yang Digunakan

| Tool | Fungsi | Referensi |
|------|--------|-----------|
| [QUAST](https://quast.sourceforge.net/) | QC assembly (N50, GC%, contig count) | Gurevich et al. |
| [minigraph](https://github.com/lh3/minigraph) | SV-level pangenome graph | Li et al. |
| [cactus-minigraph](https://github.com/ComparativeGenomicsToolkit/cactus) | Base-level pangenome graph | Hickey et al. 2024 |
| [odgi](https://odgi.readthedocs.io) | Analisis & visualisasi graph | Guarracino et al. |
| [vg](https://github.com/vgteam/vg) | Variant calling & statistik | Garrison et al. |
| [seqkit](https://bioinf.shenwei.me/seqkit) | Statistik & filter FASTA | Shen et al. |

**Referensi utama:**
- Hickey et al. (2024). *Pangenome graph construction from genome alignments with Minigraph-Cactus*. [Nature Biotechnology](https://doi.org/10.1038/s41587-023-01793-w)
- [Cactus / Minigraph-Cactus](https://github.com/ComparativeGenomicsToolkit/cactus)
- [nf-core/pangenome](https://github.com/nf-core/pangenome)
- [PanSN-spec](https://github.com/pangenome/PanSN-spec)
- [nf-core guidelines](https://nf-co.re/docs/contributing/guidelines)

---

## 📖 Pengembangan

Baca [`docs/NEXTFLOW_PRINCIPLES.md`](docs/NEXTFLOW_PRINCIPLES.md) untuk panduan:
- Anatomi process Nextflow DSL2
- Pola Meta Map
- Aturan channel
- Konvensi stub & testing
- Checklist sebelum push

Pantau progres di [`PROGRESS.md`](PROGRESS.md) dan catat error di [`ERRORS.md`](ERRORS.md).

---

<div align="center">

---

*Made with 🤍 by **Doni Arman***

*Sistem Informasi · Universitas Riau · 2026*

</div>
