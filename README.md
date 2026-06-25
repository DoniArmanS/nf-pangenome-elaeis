# nf-pangenome-elaise

> **Pengembangan Pipeline Pangenome Berbasis Nextflow untuk Analisis Variasi Struktural pada *Elaeis guineensis* (Kelapa Sawit)**
>
> Skripsi — Doni Arman.S (2303126086)  
> Program Studi Informatika, Universitas Mulawarman

---

## 🌴 Tentang Project Ini

Pipeline berbasis **Nextflow DSL2** untuk membangun dan menganalisis **pangenome graph** dari beberapa assembly *Elaeis guineensis* (kelapa sawit), dengan tujuan mengidentifikasi **variasi struktural (SV)** antar varietas (Dura, Pisifera, Tenera).

Pipeline mengimplementasikan alur kerja **PGGB** (PanGenome Graph Builder):

```
FASTA Assembly × 5
      ↓
[wfmash]     — All-vs-All Alignment
      ↓
[seqwish]    — Graph Induction
      ↓
[smoothxg]   — Graph Normalization
      ↓
[gfaffix]    — Redundancy Reduction
      ↓
[odgi]       — Graph Analysis & Visualization
      ↓
[vg]         — Variant Calling (VCF)
      ↓
[MultiQC]    — QC Report
```

---

## 📁 Struktur Folder

```
nf-pangenome-elaise/
├── main.nf                    # Entry point
├── nextflow.config            # Config & profiles
├── PROGRESS.md                # ✅ Progress tracking
├── ERRORS.md                  # 🐛 Error log
├── modules/
│   └── local/
│       ├── alignment/         # wfmash
│       ├── graph_construction/# seqwish, smoothxg
│       ├── graph_analysis/    # odgi
│       ├── variant_calling/   # vg
│       ├── preprocessing/     # seqkit
│       └── visualization/     # plots
├── workflows/
│   └── pangenome.nf           # Main workflow
├── subworkflows/local/        # Step-step detail
├── conf/                      # Extra configs
├── bin/                       # Helper scripts
├── tests/
│   └── dummy_data/            # Data dummy untuk testing
├── notebooks/                 # Jupyter notebooks eksplorasi
├── scripts/                   # Script analisis tambahan
└── docs/
    └── NEXTFLOW_PRINCIPLES.md # Panduan coding
```

---

## 🚀 Cara Jalankan

### Testing (tanpa tool, tanpa HPC)
```bash
# Generate data dummy dulu
python3 tests/dummy_data/generate_dummy.py

# Jalankan stub mode
nextflow run main.nf -profile test --stub-run
```

### Lokal (tool sudah terinstall)
```bash
nextflow run main.nf \
    -profile local \
    --input tests/dummy_data/samplesheet.csv \
    --outdir results/test_run
```

### Resume setelah error
```bash
nextflow run main.nf -profile test -resume
```

---

## 📋 Data Input

Format samplesheet CSV (`tests/dummy_data/samplesheet.csv`):

```csv
sample,fasta,assembler
EG_ASM1,path/to/ASM1.fa,dura
EG_ASM2,path/to/ASM2.fa,pisifera
```

> ⚠️ Data asli ada di folder `DATA SKRIPSI/` yang di-gitignore.

---

## 📊 Output

```
results/
├── preprocessing/     # Seqkit stats
├── alignment/         # PAF files
├── graph/             # GFA files (raw & smooth)
├── analysis/          # ODGI stats, visualisasi 1D/2D
├── variants/          # VCF files (kalau call_variants aktif)
└── pipeline_info/     # Report, timeline, trace
```

---

## 🔧 Requirements

- **Nextflow** ≥ 23.04.0
- **Java** ≥ 11
- Salah satu: Docker / Singularity / Conda

Install Nextflow:
```bash
curl -s https://get.nextflow.io | bash
./nextflow self-update
```

---

## 📚 Referensi

- Garrison et al. (2023). *Building pangenome graphs*. Nature Methods.
- nf-core/pangenome: https://github.com/nf-core/pangenome
- PGGB: https://github.com/pangenome/pggb
- wfmash: https://github.com/waveygang/wfmash

---

## 👤 Author

**Doni Arman.S** | 2303126086 | Informatika UNMUL  
Pembimbing: [Nama Pembimbing]
