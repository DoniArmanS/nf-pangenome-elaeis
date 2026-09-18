<div align="center">

```
███╗   ██╗███████╗    ██████╗  █████╗ ███╗   ██╗ ██████╗ ███████╗███╗   ██╗ ██████╗ ███╗   ███╗███████╗
████╗  ██║██╔════╝    ██╔══██╗██╔══██╗████╗  ██║██╔════╝ ██╔════╝████╗  ██║██╔═══██╗████╗ ████║██╔════╝
██╔██╗ ██║█████╗      ██████╔╝███████║██╔██╗ ██║██║  ███╗█████╗  ██╔██╗ ██║██║   ██║██╔████╔██║█████╗  
██║╚██╗██║██╔══╝      ██╔═══╝ ██╔══██║██║╚██╗██║██║   ██║██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══╝  
██║ ╚████║██║         ██║     ██║  ██║██║ ╚████║╚██████╔╝███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║███████╗
╚═╝  ╚═══╝╚═╝         ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
```

### `nf-pangenome-elaeis`

**Pipeline Nextflow DSL2 untuk konstruksi pangenome graph *Elaeis guineensis* (Kelapa Sawit)**  
**menggunakan Minigraph-Cactus pada infrastruktur HPC**

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62?style=flat-square&logo=nextflow)](https://www.nextflow.io/)
![Status](https://img.shields.io/badge/status-produksi%20%26%20benchmark%20selesai-brightgreen?style=flat-square)
[![Genome](https://img.shields.io/badge/spesies-Elaeis%20guineensis-green?style=flat-square)](https://www.ncbi.nlm.nih.gov/datasets/taxonomy/51953/)

</div>

---

## 🌴 Tentang Project Ini

Pipeline ini mengotomatisasi seluruh proses konstruksi dan analisis **pangenome graph** dari 3 assembly *Elaeis guineensis* (kelapa sawit) yang tersedia di database publik NCBI. Diimplementasikan menggunakan **Nextflow DSL2** dan berjalan di **HPC Mahameru (BRIN)** dengan sistem penjadwalan **SLURM**.

Pendekatan utama yang digunakan adalah **Minigraph-Cactus** (Hickey et al., 2024) — metode konstruksi pangenome yang menggunakan satu genom berkualitas tinggi (level kromosom) sebagai backbone referensi, kemudian mensejajarkan seluruh assembly lainnya terhadap graf tersebut untuk menangkap seluruh variasi genetik.

> **Tujuan penelitian:**
> 1. Merancang arsitektur pipeline pangenome kelapa sawit yang terotomatisasi dengan Nextflow
> 2. Mengimplementasikan pipeline di HPC Mahameru dengan optimasi alokasi sumber daya Slurm
> 3. Mengevaluasi efisiensi pipeline berdasarkan runtime, penggunaan CPU, dan memori, serta merekomendasikan alokasi sumber daya yang optimal berdasarkan data empiris (bukan sekadar over-provisioning)

---

## 📊 Progress & Timeline

```
Infrastructure     ████████████████████  100%
Tool Install       ████████████████████  100%  ✅ (Cactus: native binary di HPC)
Pipeline Code      ████████████████████  100%  ✅ Tested end-to-end
Real Data Run      ████████████████████  100%  ✅ Produksi penuh (32 core / 64GB)
HPC Deployment     ████████████████████  100%  ✅ SLURM + native Cactus
Resource Benchmark ████████████████████  100%  ✅ 7 titik ukuran, 3x pengulangan
Penulisan BAB IV   ████████████████████  100%  ✅
─────────────────────────────────────────────────
KESELURUHAN        ███████████████████░   ~90%
```

| Fase | Target Selesai | Status |
|------|----------------|--------|
| 🔧 Setup & Infrastruktur | Juni 2026 | ✅ Selesai |
| 🧬 Install Tools (conda + Cactus) | Juli 2026 | ✅ Selesai |
| ✅ **Test Pipeline (sample data)** | **Juli 2026** | **✅ 8/8 Steps** |
| 🖥️ Deployment & Eksekusi Produksi di HPC Mahameru | Agustus 2026 | ✅ Selesai |
| 📊 Benchmark Resource-Aware & Modul Rekomendasi | Agustus 2026 | ✅ Selesai |
| 📝 Penulisan BAB IV | Agustus 2026 | ✅ Selesai |
| 📝 **DEADLINE ANALISIS** + Penulisan Lengkap | **November 2026** | ⏳ |
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
  │  ├─ odgi stats → node, edge, path, step count               │
  │  ├─ vg stats   → statistik graph level vg                  │
  │  └─ odgi viz   → visualisasi 1D layout                     │
  └──────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  OUTPUT AKHIR                                               │
  │  Statistik pangenome + trace.tsv → rekomendasi alokasi      │
  │  sumber daya (bin/recommend_resources.sh)                   │
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
| `analysis/pangenome.stats.yaml` | Statistik graph: **length, node, edge, path, step** (odgi stats) |
| `analysis/pangenome.vg_stats.txt` | Statistik graph via **vg stats** (node & edge count) |
| `analysis/pangenome.1D.png` | Visualisasi 1D layout pangenome (odgi viz) |

### ⚡ Laporan Eksekusi Pipeline (Nextflow)

| File | Keterangan |
|------|-----------|
| `pipeline_info/report.html` | Laporan eksekusi lengkap dengan runtime per proses |
| `pipeline_info/timeline.html` | Grafik timeline eksekusi visual |
| `pipeline_info/trace.tsv` | Tabel penggunaan CPU & memori per proses |
| `pipeline_info/dag.html` | Grafik alur pipeline (DAG — Directed Acyclic Graph) |

### 🎯 Rekomendasi Alokasi Sumber Daya

Setelah pipeline selesai, `bin/recommend_resources.sh` bisa dijalankan terhadap `trace.tsv` hasil eksekusi untuk menghasilkan rekomendasi jumlah CPU core dan RAM untuk run berikutnya, berdasarkan penggunaan aktual (bukan tebakan):

```bash
bin/recommend_resources.sh results/pipeline_info/trace.tsv
```

Rekomendasi dihitung dari nilai `%cpu` dan `peak_rss` tertinggi di seluruh task pada trace, ditambah margin keamanan 20% untuk RAM.

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
| [Nextflow](https://www.nextflow.io/) | ≥ 23.04.0 (teruji 26.04.6) | dipasang di `~/bin` |
| Java | 21 (teruji 21.0.4-tem) | dipasang lewat [SDKMAN](https://sdkman.io/) |
| [Miniforge](https://github.com/conda-forge/miniforge) (Conda + Mamba) | — | dipasang di `~/miniforge3`, environment `pangenome` |
| [Cactus](https://github.com/ComparativeGenomicsToolkit/cactus) | 2.9.0 | HPC: biner *native* di `~/cactus-bin-v2.9.0`; laptop: Docker |
| SLURM | — | tersedia di HPC Mahameru |

> 💡 Semua komponen dipasang di direktori akun (`~/`), jadi **tidak perlu akses root** — cukup akun HPC bertipe *student*.
> Lokasi di atas adalah lokasi yang dibaca `run_hpc.sh` dan `conf/hpc.config`. Kalau dipasang di tempat lain, sesuaikan kedua berkas itu.

#### Step 1 — Clone Repository

```bash
git clone https://github.com/DoniArmanS/nf-pangenome-elaeis.git
cd nf-pangenome-elaeis
```

#### Step 2 — Pasang Komponen (sekali saja, di login node)

**2a. Java 21 (SDKMAN)**

```bash
curl -s https://get.sdkman.io | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.4-tem        # atau versi 21 lain: sdk list java
java -version
```

**2b. Nextflow**

```bash
curl -s https://get.nextflow.io | bash
mkdir -p ~/bin && mv nextflow ~/bin/
~/bin/nextflow -version
```

**2c. Tools bioinformatika (Conda)**

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

**2d. Cactus 2.9.0**

Di **HPC Mahameru**, Cactus dipasang sebagai **biner native** (bukan container). Container Singularity gagal di sejumlah node dengan galat `unknown userid` (cache SSSD/LDAP yang tidak konsisten), dan Docker tidak diizinkan di HPC. Langkah berikut mengikuti `BIN-INSTALL.md` resmi Cactus:

```bash
cd ~
wget https://github.com/ComparativeGenomicsToolkit/cactus/releases/download/v2.9.0/cactus-bin-v2.9.0.tar.gz
tar -xzf cactus-bin-v2.9.0.tar.gz
cd cactus-bin-v2.9.0
virtualenv -p python3 venv-cactus-v2.9.0
printf "export PATH=$(pwd)/bin:\$PATH\nexport PYTHONPATH=$(pwd)/lib:\$PYTHONPATH\n" >> venv-cactus-v2.9.0/bin/activate
source venv-cactus-v2.9.0/bin/activate
python3 -m pip install -U setuptools pip wheel
python3 -m pip install -U .
python3 -m pip install -U -r ./toil-requirement.txt
deactivate
```

`conf/hpc.config` mengaktifkan environment ini otomatis lewat `beforeScript`, jadi tidak perlu diaktifkan manual saat menjalankan pipeline.

Di **laptop** (profile `local`/`docker`/`conda`), Cactus cukup memakai image Docker:

```bash
sudo usermod -aG docker $USER   # pertama kali saja, lalu logout/login
docker pull quay.io/comparative-genomics-toolkit/cactus:v2.9.0
```

#### Step 3 — Siapkan Data & Samplesheet

Data yang dipakai adalah 3 assembly *Elaeis guineensis* dari NCBI:

| Sample | Kultivar | Aksesi NCBI | Peran |
|--------|----------|-------------|-------|
| EG11 | Tenera | [GCA_000442705.2](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000442705.2/) | backbone referensi |
| EGPMv6 | AVROS | [GCA_015461965.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_015461965.1/) | — |
| Eg-DCM | DCM | [GCA_966131455.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_966131455.1/) | — |

Unduh lewat halaman NCBI di atas, atau dengan [NCBI Datasets CLI](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/) (`mamba install -c conda-forge ncbi-datasets-cli`):

```bash
for x in EG11:GCA_000442705.2 EGPMv6:GCA_015461965.1 Eg-DCM:GCA_966131455.1; do
  s=${x%%:*}; acc=${x##*:}
  datasets download genome accession $acc --include genome --filename $s.zip
  unzip -o $s.zip -d data/$s && rm $s.zip
done
```

Berkas `samplesheet.csv` di repo sudah menunjuk ke lokasi hasil unduhan tersebut:

```csv
sample,fasta,cultivar
EG11,data/EG11/ncbi_dataset/data/GCA_000442705.2/GCA_000442705.2_EG11_genomic.fna,Tenera
EGPMv6,data/EGPMv6/ncbi_dataset/data/GCA_015461965.1/GCA_015461965.1_EGPMv6_genomic.fna,AVROS
Eg-DCM,data/Eg-DCM/ncbi_dataset/data/GCA_966131455.1/GCA_966131455.1_Eg-DCM_assembly_v1_genomic.fna,DCM
```

> ⚠️ Nilai `sample` untuk backbone referensi **harus sama persis** dengan `--reference_name` (default: `EG11`)

#### Step 4 — Jalankan Pipeline

```bash
# ═══════════════════════════════════════════════════
# HPC Mahameru (SLURM + Cactus native) — DIREKOMENDASIKAN
# ═══════════════════════════════════════════════════
# run_hpc.sh sudah membawa -with-report/-with-timeline/-with-trace
# dan alokasi #SBATCH 32 core / 64 GB / 72 jam
sbatch run_hpc.sh                                    # samplesheet.csv → results/
sbatch run_hpc.sh samplesheet_lain.csv hasil_lain/   # masukan & keluaran lain
sbatch run_hpc.sh samplesheet.csv results/ noresume  # ulang dari awal tanpa cache

# Atau manual:
nextflow run main.nf \
    -profile conda,slurm \
    --input samplesheet.csv \
    --reference_name EG11 \
    --outdir results/ \
    -resume

# ═══════════════════════════════════════════════════
# Laptop
# ═══════════════════════════════════════════════════
conda activate pangenome
nextflow run main.nf -profile test,conda          # data subset kecil

nextflow run main.nf \
    -profile conda \
    --input samplesheet.csv \
    --reference_name EG11 \
    --outdir results/
```

#### Step 5 — Hitung Rekomendasi Alokasi

```bash
bin/recommend_resources.sh results/pipeline_info/trace.tsv
```

Keluarannya berupa `--cpus-per-task=N` dan `--mem=NG` yang bisa langsung ditulis ke baris `#SBATCH` di `run_hpc.sh` untuk eksekusi berikutnya.

#### Resume Setelah Error

```bash
# Nextflow otomatis melanjutkan dari proses yang gagal
sbatch run_hpc.sh          # di HPC: -resume aktif secara bawaan
nextflow run main.nf -profile test,conda -resume   # di laptop
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

#### 2. Periksa Nama Sekuens

Header FASTA **tidak perlu diubah** selama nama sekuens antar-assembly tidak kembar — misalnya nomor aksesi NCBI seperti `CM002081.2` dan `GK000076.1`. Nama *path* pada graf diberikan otomatis oleh Cactus berdasarkan nama `sample` di samplesheet.

Kalau ada nama yang kembar (misalnya `Chr01` di semua assembly), ubah header ke format [PanSN-spec](https://github.com/pangenome/PanSN-spec) `>{sample}#{haplotype}#{nama_sekuens}`:

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
> - Assembly minimum yang dibutuhkan: **2** (1 referensi + 1 atau lebih non-referensi)
> - Nama sample di samplesheet harus **unik** dan **tanpa spasi/karakter khusus**
> - Pastikan nama sekuens antar-assembly **tidak kembar** (lihat langkah 2)

---

## 🎛️ Parameter

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `--input` | `null` | Path ke samplesheet CSV |
| `--outdir` | `./results` | Direktori output |
| `--reference_name` | `EG11` | **Wajib** — nama sample backbone referensi |
| `--min_seq_len` | `500` | Panjang minimum sekuens (filter seqkit) |
| `--min_contig` | `500` | Panjang minimum contig untuk QUAST |
| `--mg_preset` | `ggs` | Minigraph preset (`ggs` = genome-to-graph) |
| `--mg_min_mapq` | `5` | Ambang batas kualitas pemetaan minimum minigraph |
| `--cactus_cores` | `8` | Jumlah CPU untuk cactus-minigraph (override via `run_hpc.sh`: 16) |
| `--max_memory` | `16.GB` | Batas memori maksimum |
| `--max_cpus` | `8` | Batas CPU maksimum |
| `--max_time` | `24.h` | Batas waktu eksekusi |

> Nilai `max_*` di atas berlaku untuk profil lokal. Profil `slurm` (`conf/hpc.config`) menaikkannya menjadi **32 CPU, 64 GB, 72 jam**.

---

## 🖥️ Profile Eksekusi

| Profile | Executor | Container | Deskripsi |
|---------|----------|-----------|-----------|
| `local` | local | — | Laptop/PC tanpa container |
| `conda` | local | Conda env | **Direkomendasikan** — pakai env `pangenome` |
| `docker` | local | Docker | Pengembangan lokal dengan container |
| `singularity` | local | Singularity | HPC-compatible |
| `slurm` | Slurm | Conda (Cactus: native binary, bukan container) | **HPC Mahameru BRIN** — pakai `-profile conda,slurm` |
| `test` | local | — | Data subset real, resource dikurangi |

---

## 🗂️ Struktur Project

```
nf-pangenome-elaeis/
│
├── 📄 main.nf                           # Entry point pipeline
├── ⚙️ nextflow.config                    # Parameter, profile, resource
├── 📋 samplesheet.csv                   # 3 assembly: EG11, EGPMv6, Eg-DCM
├── 🚀 run_hpc.sh                        # Submit ke SLURM (produksi & benchmark)
├── ✂️ subset_chromosome1.py              # Potong kromosom 1–16 untuk data uji benchmark
├── 🧪 run_test.sh                       # Uji cepat dengan data subset
│
├── workflows/
│   └── pangenome.nf                     # Orkestrator utama (5 subworkflow)
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
│   │   └── cactus_minigraph.nf          # Base-level graph (Docker; native binary di HPC)
│   └── graph_analysis/
│       ├── odgi.nf                      # odgi stats + odgi viz (1D layout)
│       └── vg_stats.nf                  # vg stats — node, edge count
│
├── bin/
│   └── recommend_resources.sh           # Rekomendasi alokasi CPU/RAM dari trace.tsv
│
├── conf/
│   ├── test.config                      # Config laptop (2 CPU, 4GB RAM)
│   └── hpc.config                       # Config HPC Mahameru (SLURM, 32 core / 64GB)
│
├── data/                                # ← TARUH DATA ASSEMBLY DI SINI
│   ├── EG11/                            #   Assembly referensi (kromosom-level)
│   ├── EGPMv6/                          #   Assembly EGPMv6
│   └── Eg-DCM/                          #   Assembly DCM
│
├── tests/
│   ├── subset_real_data.py              # Buat subset dari genome asli
│   └── test_data/                       # Subset kecil (masuk git)
│       ├── EG11.fa, EGPMv6.fa, EG01.fa, ASM167249v1.fa
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
