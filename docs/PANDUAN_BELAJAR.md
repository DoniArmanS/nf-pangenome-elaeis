# 📚 Panduan Belajar Lengkap — nf-pangenome-elaeis

> Dokumen ini adalah **buku saku** untuk memahami setiap file dan baris kode di proyek skripsi ini.
> Tujuannya: kamu bisa menjawab pertanyaan dosen penguji dan paham betul apa yang kamu buat.

---

## 🏭 Analogi Pabrik (Baca Ini Dulu!)

Bayangkan pipeline Nextflow kita adalah sebuah **Pabrik Pengolahan Genome**:

| Komponen Pabrik | Padanan di Nextflow | File Aslinya |
|---|---|---|
| Manajer Pabrik | Entry point pipeline | `main.nf` |
| Buku Aturan HRD & Anggaran | Konfigurasi resource & environment | `nextflow.config` |
| Kepala Divisi | Workflow utama (urutan besar) | `workflows/pangenome.nf` |
| Kepala Regu | Subworkflow (urutan detail) | `subworkflows/local/*.nf` |
| Mesin & Pekerja | Module (1 tool = 1 mesin) | `modules/local/**/*.nf` |
| Ban Berjalan (Conveyor) | Channel (aliran data antar proses) | Konsep di dalam kode |
| Bahan Baku | File FASTA genome kelapa sawit | `data/` |
| Resep Bahan | Daftar genome yang diproses | `samplesheet.csv` |

---

## 📂 Struktur Folder — Penjelasan Lengkap

```
nf-pangenome-elaeis/
│
├── 📄 main.nf                   ← PINTU GERBANG pipeline
├── 📄 nextflow.config           ← PENGATURAN resource & environment
├── 📄 samplesheet.csv           ← DAFTAR genome yang diproses
├── 📄 run_hpc.sh                ← SCRIPT untuk submit ke HPC
├── 📄 run_test.sh               ← SCRIPT untuk test di laptop
│
├── 📁 workflows/                ← ALUR BESAR pipeline
│   └── pangenome.nf
│
├── 📁 subworkflows/local/       ← ALUR DETAIL per tahap
│   ├── validate_input.nf
│   ├── preprocessing.nf
│   ├── qc.nf
│   ├── graph_construction.nf
│   ├── graph_analysis.nf
│   └── variant_calling.nf
│
├── 📁 modules/local/            ← MESIN ASLI (1 file = 1 tool bioinformatika)
│   ├── preprocessing/
│   │   ├── seqkit_stats.nf
│   │   └── seqkit_filter.nf
│   ├── qc/
│   │   └── quast.nf
│   ├── graph_construction/
│   │   ├── minigraph.nf
│   │   └── cactus_minigraph.nf
│   └── graph_analysis/
│       ├── odgi.nf
│       └── vg_stats.nf
│
├── 📁 conf/                     ← KONFIGURASI per lingkungan
│   ├── test.config              ← Aturan untuk laptop (resource kecil)
│   └── hpc.config               ← Aturan untuk HPC Mahameru (resource besar)
│
├── 📁 data/                     ← DATA GENOME asli (tidak masuk git)
│   ├── EG11/
│   ├── EGPMv6/
│   ├── ASM167249v1/
│   ├── Eg-DCM/
│   └── EG01/
│
├── 📁 bin/                      ← SCRIPT BUATAN SENDIRI
│   └── extract_core_var.sh
│
├── 📁 tests/                    ← DATA & SCRIPT UNTUK TESTING
│   ├── test_data/               ← Data kecil (~760 KB) untuk testing cepat
│   ├── subset_real_data.py      ← Script bikin subset kecil (3 assembly)
│   └── subset_medium.py         ← Script bikin subset medium (4 assembly, ~21 MB)
│
└── 📁 docs/                     ← DOKUMENTASI
    ├── PANDUAN_BELAJAR.md       ← File ini
    └── NEXTFLOW_PRINCIPLES.md
```

---

## 🔍 Penjelasan Setiap File Secara Detail

---

### 1. `main.nf` — Pintu Gerbang

**Ini file yang pertama dibaca saat kamu ketik `nextflow run main.nf`.**

```groovy
#!/usr/bin/env nextflow
nextflow.enable.dsl = 2
```
> `dsl = 2` artinya kita pakai Nextflow versi modern (DSL2). Perbedaannya dengan DSL1: di DSL2, semua proses harus didefinisikan di module terpisah, tidak boleh dicampur di satu file. Ini yang membuat kode kita rapi dan modular.

```groovy
include { PANGENOME_WORKFLOW } from './workflows/pangenome'
```
> `include` = impor. Artinya: "ambil fungsi bernama `PANGENOME_WORKFLOW` dari file `workflows/pangenome.nf`". Konsepnya mirip `import` di Python.

```groovy
workflow {
    log.info """...""".stripIndent()
    PANGENOME_WORKFLOW()
}
```
> Blok `workflow {}` tanpa nama = blok utama yang dijalankan. Isinya cuma 2 hal:
> 1. Cetak banner info ke terminal
> 2. Panggil `PANGENOME_WORKFLOW()` — semua proses sesungguhnya ada di sana

**Kesimpulan:** `main.nf` itu tipis dan simpel dengan sengaja. Dia hanya menjadi "wajah depan" pipeline.

---

### 2. `nextflow.config` — Buku Aturan

File ini mengatur **siapa boleh pakai apa dan berapa banyak**. Dibagi menjadi beberapa bagian:

#### Bagian `params` — Variabel Default
```groovy
params {
    input          = null        // path ke samplesheet.csv
    outdir         = 'results'   // folder output
    reference_name = 'EG11'      // nama assembly yang jadi referensi backbone
    max_cpus       = 8           // maksimal CPU yang boleh dipakai
    max_memory     = '15.GB'     // maksimal RAM
}
```
> `params` adalah variabel yang bisa kamu **override** dari command line. Contoh: `--max_cpus 32` saat run di HPC akan mengganti nilai 8 menjadi 32.

#### Bagian `profiles` — Pilihan Lingkungan
```groovy
profiles {
    conda  { ... }    // pakai Conda environment di laptop
    docker { ... }    // pakai Docker container
    slurm  { ... }    // pakai SLURM di HPC
    test   { ... }    // mode testing (resource sangat kecil)
}
```
> Profile = "baju kerja" pipeline. Saat kamu tambahkan `-profile conda` di command, Nextflow tahu: "oke, pakai Conda dan juga enable Docker untuk Cactus".

#### Bagian `process` — Label Ukuran Mesin
```groovy
withLabel: process_high {
    cpus   = 8     // pakai 8 CPU
    memory = 16.GB // pakai 16 GB RAM
    time   = 8.h   // batas waktu 8 jam
}
```
> Label ini ditempel ke setiap module. Misalnya, `cactus_minigraph.nf` punya label `process_high`, artinya dia boleh pakai sampai 8 CPU dan 16 GB RAM. Di HPC, batas ini bisa dinaikkan lewat `hpc.config`.

---

### 3. `workflows/pangenome.nf` — Kepala Divisi

**File ini menentukan URUTAN BESAR pipeline dari awal sampai akhir.**

```groovy
include { VALIDATE_INPUT     } from '../subworkflows/local/validate_input'
include { PREPROCESSING      } from '../subworkflows/local/preprocessing'
include { QC                 } from '../subworkflows/local/qc'
include { GRAPH_CONSTRUCTION } from '../subworkflows/local/graph_construction'
include { GRAPH_ANALYSIS     } from '../subworkflows/local/graph_analysis'
```
> Import semua "kepala regu" (subworkflow). Mereka yang akan mengeksekusi pekerjaan detail.

```groovy
workflow PANGENOME_WORKFLOW {
    main:

    VALIDATE_INPUT()
    ch_fasta = VALIDATE_INPUT.out.fasta   // ambil output berupa channel fasta
```
> `VALIDATE_INPUT.out.fasta` = hasil keluaran (output) dari VALIDATE_INPUT, yaitu channel berisi file FASTA yang sudah divalidasi. Ini adalah **ban berjalan** yang membawa data ke proses selanjutnya.

```groovy
    PREPROCESSING(ch_fasta)
    ch_clean = PREPROCESSING.out.fasta
```
> Kirim `ch_fasta` ke PREPROCESSING. Hasilnya disimpan di `ch_clean` (fasta yang sudah dibersihkan/difilter).

```groovy
    QC(ch_clean)
    GRAPH_CONSTRUCTION(ch_clean)
    ch_graph = GRAPH_CONSTRUCTION.out.gfa
    GRAPH_ANALYSIS(ch_graph)
```
> QC dan GRAPH_CONSTRUCTION keduanya menerima `ch_clean`. Keduanya akan **berjalan paralel** secara otomatis karena tidak saling bergantung! Ini keunggulan Nextflow.

```groovy
    if (params.call_variants && params.reference_name) {
        VARIANT_CALLING(ch_graph)
    }
```
> Variant Calling bersifat opsional — hanya jalan kalau kamu set parameter `--call_variants`.

---

### 4. `subworkflows/local/` — Kepala Regu

#### `preprocessing.nf`
```groovy
workflow PREPROCESSING {
    take:
    ch_fasta   // menerima input: channel berisi [meta, fasta]

    main:
    SEQKIT_STATS(ch_fasta)    // hitung statistik (jumlah seq, panjang rata-rata, dll)
    SEQKIT_FILTER(ch_fasta)   // filter: buang sekuens terlalu pendek

    emit:
    fasta = SEQKIT_FILTER.out.fasta   // kirim fasta bersih ke luar
    stats = SEQKIT_STATS.out.tsv      // kirim tabel statistik ke luar
}
```
> **Kenapa perlu filter?** Sekuens yang terlalu pendek (< 1000 bp) biasanya adalah contig sisa/artefak yang bisa merusak kualitas pangenome graph. Seqkit membuangnya.

#### `graph_construction.nf` — Yang Paling Kompleks

```groovy
// Pisahkan genome referensi dari genome lain
ch_ref = ch_fasta
    .filter { meta, fasta -> meta.id == params.reference_name }
    .first()
```
> Filter channel: ambil hanya genome yang namanya sama dengan `reference_name` (EG11). Genome ini akan jadi **backbone/tulang punggung** pangenome graph. Kenapa EG11? Karena N50-nya paling tinggi = kualitas assembly terbaik.

```groovy
ch_other_fastas = ch_fasta
    .filter { meta, fasta -> meta.id != params.reference_name }
    .map { meta, fasta -> fasta }
    .collect()
```
> Kumpulkan semua genome selain EG11 menjadi satu list. `.collect()` menunggu sampai **semua** genome sudah selesai dipreprocessing sebelum dikumpulkan.

```groovy
MINIGRAPH(ch_minigraph_input)    // Step 1: bangun graph kasar (SV-level)
// ...
CACTUS_MINIGRAPH(ch_cactus_input)  // Step 2: refinement ke level basa
```
> Dua tahap ini adalah inti Minigraph-Cactus (metode dari paper Hickey et al. 2024):
> - **Minigraph**: cepat, bangun graph struktural (SV = Structural Variant, perbedaan besar)
> - **Cactus**: lambat tapi akurat, refinement sampai level basa (satu huruf DNA)

---

### 5. `modules/local/` — Mesin Aslinya

Setiap module punya struktur yang **selalu sama**:

```groovy
process NAMA_PROSES {
    tag    "..."        // nama yang muncul di log (untuk debugging)
    label  'process_X' // ukuran resource yang dibutuhkan

    input:
    // bahan baku apa yang diterima

    output:
    // hasil apa yang dikeluarkan

    script:
    // BASH COMMAND yang sesungguhnya dijalankan

    stub:
    // versi palsu untuk testing cepat tanpa jalankan tool beneran
}
```

#### Module `minigraph.nf`
```bash
# Di dalam script:
minigraph \
    -cx ggs \         # mode "genome graph construction"
    -t ${task.cpus} \ # pakai sekian thread (CPU)
    ${reference} \    # genome referensi (EG11) duluan
    ${assemblies} \   # lalu genome lainnya
    > ${prefix}.gfa   # simpan ke file GFA
```
> `-cx ggs` adalah flag khusus minigraph untuk mode **pangenome graph**. GFA (Graphical Fragment Assembly) adalah format file yang menyimpan graph genomik — seperti peta jalan tapi untuk DNA.

#### Module `cactus_minigraph.nf`
```groovy
container 'quay.io/comparative-genomics-toolkit/cactus:v2.9.0'
```
> Baris ini berarti: **Cactus hanya tersedia sebagai Docker image**, tidak bisa diinstall via Conda. Jadi Nextflow akan otomatis menjalankan Docker container saat proses ini berjalan.

```bash
cactus-minigraph \
    ${jobstore} \           # folder sementara untuk menyimpan progress Cactus
    ${seqfile} \            # daftar nama + path semua genome (format TSV)
    ${prefix}.full.gfa \    # output: pangenome graph final
    --reference ${ref_name} # genome mana yang jadi backbone
    --mgCores ${task.cpus}  # pakai berapa CPU
```
> `jobstore` itu folder khusus Cactus untuk menyimpan checkpoint. Kalau Cactus gagal di tengah jalan, dia bisa lanjut dari sini tanpa mengulang dari awal.

#### Module `odgi.nf` — Yang Paling Kompleks (Ada Bug Fix di Sini!)

```bash
# STEP 1: Konversi format
vg convert -g ${gfa} -p > ${prefix}.temp.vg
```
> Output Cactus adalah **rGFA** (reference-based GFA), tapi ODGI hanya menerima **GFA1 standard**. Jadi kita perlu konversi dulu lewat `vg` (variation graph tools).

```bash
# STEP 2: Fix node ID (INI ADALAH BUG FIX YANG KITA BUAT!)
vg ids -s ${prefix}.temp.vg
```
> **Kenapa ini ada?** Cactus kadang menghasilkan node ID yang sangat besar (> 2^63). ODGI punya batas internal dan akan crash dengan `Assertion Error 134` kalau node ID terlalu besar. Perintah `vg ids -s` (sort/compact IDs) mengubah semua node ID menjadi urutan angka kecil 1, 2, 3, dst. **Ini fix bug yang kita temukan dan perbaiki sendiri selama pengembangan.**

```bash
# STEP 3: Build & sort graph binary
odgi build -g ${prefix}.std.gfa -o ${prefix}.og   # GFA → binary .og
odgi sort  -i ${prefix}.og -o ${prefix}.sorted.og  # urutkan node
odgi stats -i ${prefix}.og -S -y > ${prefix}.stats.yaml  # hitung statistik
```
> ODGI punya format biner sendiri (`.og`) yang jauh lebih cepat diproses. `-S` = summary stats, `-y` = output format YAML.

```bash
# Visualisasi 1D
odgi viz -i ${prefix}.sorted.og -o ${prefix}.1D.png -x 1500 -y 500
```
> Menghasilkan gambar PNG 1500×500 piksel yang menunjukkan semua path (genome) dalam pangenome graph secara linear. Setiap warna = satu node/segmen unik.

---

### 6. `conf/hpc.config` — Aturan HPC Mahameru

```groovy
executor {
    name = 'slurm'        // pakai SLURM job scheduler
    queueSize = 50        // maksimal 50 job paralel sekaligus
}

process {
    withLabel: process_high {
        cpus   = 32       // di HPC bisa pakai 32 CPU
        memory = 64.GB    // dan 64 GB RAM!
        time   = 72.h     // batas waktu 3 hari
        queue  = 'medium-small'  // partisi SLURM yang dipakai
    }
}
```
> Di laptop kamu `process_high` = 8 CPU, 16 GB RAM. Di HPC dengan config ini = 32 CPU, 64 GB RAM. **Kode pipeline-nya sama persis**, hanya config-nya yang berbeda. Inilah keunggulan Nextflow.

---

### 7. `samplesheet.csv` — Resep Bahan Baku

```csv
sample,fasta,cultivar
EG11,data/EG11/ncbi_dataset/.../GCA_000442705.2_EG11_genomic.fna,Tenera
EGPMv6,data/EGPMv6/.../GCA_015461965.1_EGPMv6_genomic.fna,AVROS
ASM167249v1,data/ASM167249v1/.../GCA_001672495.1_ASM167249v1_genomic.fna,Dura
Eg-DCM,data/Eg-DCM/.../GCA_966131455.1_Eg-DCM_assembly_v1_genomic.fna,DCM
EG01,data/EG01/.../GCA_002146295.1_EG01_genomic.fna,Jacq
```
> File CSV sederhana ini adalah **satu-satunya hal yang perlu kamu ubah** kalau mau menambah atau mengurangi genome. Pipeline akan otomatis menyesuaikan jumlah proses.

---

## 🌊 Konsep Channel — "Ban Berjalan" Nextflow

Nextflow **tidak** bekerja seperti Python (baris per baris dari atas ke bawah). Nextflow bekerja seperti **pabrik dengan banyak ban berjalan paralel**.

```
ch_fasta = Channel berisi [EG11.fa, EGPMv6.fa, Eg-DCM.fa, ASM167249v1.fa, EG01.fa]

Saat SEQKIT_FILTER(ch_fasta) dipanggil:
  → EG11.fa langsung diproses (tidak perlu tunggu yang lain)
  → EGPMv6.fa diproses paralel
  → Eg-DCM.fa diproses paralel
  → Semua 5 berjalan BERSAMAAN di waktu yang sama!
```

Ini kenapa kalau kamu lihat log Nextflow, kamu lihat banyak proses berjalan sekaligus — bukan satu per satu.

---

## 💬 Pertanyaan Dosen Penguji & Jawabannya

**Q: "Kenapa kamu pakai Nextflow, bukan script bash biasa?"**
> A: "Nextflow memungkinkan eksekusi paralel otomatis, resume jika gagal (-resume), dan portabilitas ke HPC hanya dengan mengganti config file. Script bash biasa harus ditulis ulang untuk setiap lingkungan."

**Q: "Kenapa genome EG11 dipilih sebagai referensi?"**
> A: "EG11 memiliki N50 tertinggi (level kromosom), artinya assembly-nya paling lengkap dan minim fragmentasi. Dalam Minigraph-Cactus, kualitas referensi backbone sangat menentukan kualitas graph akhir."

**Q: "Kenapa Cactus dijalankan via Docker, bukan Conda?"**
> A: "Cactus adalah software yang sangat kompleks dengan banyak dependensi spesifik. Tim pengembangnya (Comparative Genomics Toolkit, UC Santa Cruz) hanya menyediakan distribusi resmi via Docker. Ini memastikan reproducibility — siapapun yang menjalankan pipeline ini akan mendapat hasil yang identik."

**Q: "Apa yang dimaksud dengan 'pangenome graph' dan formatnya?"**
> A: "Pangenome graph adalah representasi variasi genetik dari banyak genome sekaligus. Formatnya adalah GFA (Graphical Fragment Assembly) — sebuah file teks yang berisi node (segmen DNA unik) dan edge (koneksi antar segmen). Genome yang berbeda direpresentasikan sebagai 'path' berbeda yang melewati node-node yang sama atau berbeda."

**Q: "Apa yang kamu lakukan saat menemukan error odgi assertion 134?"**
> A: "Saya menemukan bahwa Cactus menghasilkan node ID yang melebihi batas internal ODGI (2^63). Solusinya adalah menambahkan langkah konversi menggunakan `vg ids -s` untuk melakukan kompaksi node ID sebelum data masuk ke ODGI. Fix ini saya implementasikan di `modules/local/graph_analysis/odgi.nf`."

---

## 🔬 Detail Setiap Subworkflow — Baris per Baris

### `validate_input.nf` — Penjaga Pintu

Subworkflow ini adalah yang **pertama jalan**. Tugasnya membaca `samplesheet.csv` dan memastikan semua file FASTA benar-benar ada di disk.

```groovy
Channel
    .fromPath(params.input)       // baca path samplesheet.csv dari params
    .splitCsv(header: true)       // baca sebagai CSV, baris pertama = header
    .map { row ->
        def meta  = [id: row.sample, cultivar: row.cultivar]
        def fasta = file(row.fasta)
        if (!fasta.exists()) error "File tidak ditemukan: ${fasta}"
        return tuple(meta, fasta)
    }
```

- `meta` adalah map (seperti dict Python) berisi `id` dan `cultivar`
- `meta.id` dipakai sebagai nama di semua output — contoh: `EG11_quast/`, `EG11.stats.tsv`
- Kalau file FASTA tidak ada → pipeline **error** sebelum mulai, tidak buang waktu

---

### `graph_construction.nf` — Jantung Pipeline

```groovy
// Pisahkan EG11 dari yang lain
ch_ref = ch_fasta
    .filter { meta, fasta -> meta.id == params.reference_name }
    .first()

// Kumpulkan semua non-referensi jadi 1 list
ch_other_fastas = ch_fasta
    .filter { meta, fasta -> meta.id != params.reference_name }
    .map    { meta, fasta -> fasta }
    .collect()   // ← titik sinkronisasi: tunggu SEMUA genome masuk dulu
```

- `.collect()` adalah kunci — tanpanya Minigraph tidak bisa menerima semua genome sekaligus
- setelah collect, semua 4 genome non-referensi dikumpulkan jadi `[EGPMv6.fa, Eg-DCM.fa, ASM167249v1.fa, EG01.fa]`

```groovy
// Buat seqFile untuk Cactus (format: nama TAB path)
ch_seqfile = ch_fasta
    .map { meta, fasta -> "${meta.id}\t${fasta}" }
    .collect()
    .map { lines ->
        def f = file("${workDir}/seqfile.txt")
        f.text = lines.join('\n') + '\n'
        return f
    }
```

Isi `seqfile.txt` yang dihasilkan:
```
EG11    /path/to/EG11.filtered.fa
EGPMv6  /path/to/EGPMv6.filtered.fa
Eg-DCM  /path/to/Eg-DCM.filtered.fa
ASM167249v1  /path/to/ASM167249v1.filtered.fa
EG01    /path/to/EG01.filtered.fa
```

---

## 🔧 Detail Module — Setiap Flag Dijelaskan

### `minigraph.nf`

```bash
minigraph -cx ggs -t 8 ${reference} ${assemblies} > pangenome.gfa
```

| Flag | Artinya |
|------|---------|
| `-c` | output format GFA (bukan PAF) |
| `-x ggs` | preset "genome graph" — mode khusus pangenome |
| `-t 8` | pakai 8 CPU thread |
| `${reference}` | EG11 harus **pertama** — jadi tulang punggung graph |
| `${assemblies}` | 4 genome lain ditambahkan ke atas graph EG11 |

**Output GFA:**
```
S  1  ATCGATCG     ← S = segment/node (ID, urutan DNA)
L  1 + 2 + 0M      ← L = link/edge (sambungan antar node)
P  EG11#1#chr1 1+,2+  ← P = path (jalur genome ini di graph)
```

### `cactus_minigraph.nf`

```bash
cactus-minigraph ${jobstore} ${seqfile} output.full.gfa \
    --reference EG11 --mgCores 16 --binariesMode local \
    2>&1 | tee pangenome.cactus.log
```

| Argumen | Artinya |
|---------|---------|
| `${jobstore}` | folder checkpoint — kalau gagal, bisa lanjut dari sini |
| `${seqfile}` | file TSV berisi nama + path semua genome |
| `--reference EG11` | genome backbone |
| `--binariesMode local` | jalankan semua binary lokal (bukan cluster internal) |
| `2>&1 \| tee *.log` | tampilkan di terminal DAN simpan ke log file |

### `odgi.nf` — Kenapa 3 Langkah Konversi?

```bash
# 1. rGFA → vg PackedGraph
vg convert -g ${gfa} -p > temp.vg

# 2. Kompaksi node ID (BUG FIX yang kita buat!)
vg ids -s temp.vg

# 3. vg → GFA1 standard
vg convert -f temp.vg > std.gfa
```

**Kenapa perlu ini?** Cactus output = rGFA (reference-based) dengan node ID bisa miliaran. ODGI crash jika node ID > 2^63. `vg ids -s` mengubah ID menjadi 1,2,3,4... yang kecil.

```bash
odgi build -g std.gfa -o graph.og      # GFA teks → binary (lebih cepat)
odgi sort  -i graph.og -o sorted.og    # urutkan node untuk visualisasi optimal
odgi stats -i graph.og -S -y > stats.yaml  # -S=summary, -y=YAML output
odgi viz   -i sorted.og -o 1D.png -x 1500 -y 500  # gambar 1500x500px
```

---

## 🖥️ Memahami SLURM di HPC Mahameru

```bash
#SBATCH --partition=medium-small  # antrian yang dipakai
#SBATCH --cpus-per-task=32        # minta 32 CPU
#SBATCH --mem=64G                 # minta 64 GB RAM
#SBATCH --time=72:00:00           # batas waktu 3 hari
```

**Perintah SLURM penting:**
```bash
sbatch run_hpc.sh          # submit job
squeue -u darman           # lihat status job
scancel 12345              # batalkan job
tail -f slurm-*.out        # pantau output live
```

---

## 📁 Panduan Output — Apa yang Ada di `results/`

```
results/
├── qc/{sample}_quast/
│   ├── report.txt         ← statistik lengkap (N50, contig, GC%)
│   ├── report.pdf         ← untuk skripsi BAB IV Tabel 4.1
│   └── basic_stats/
│       ├── Nx_plot.pdf    ← grafik N50
│       └── GC_content_plot.pdf
├── analysis/
│   ├── pangenome.stats.yaml  ← nodes, edges, paths (Tabel 4.2)
│   └── pangenome.1D.png      ← GAMBAR visualisasi (Gambar 4.1)
└── pipeline_info/
    ├── report.html        ← grafik CPU & RAM per proses (buka di browser)
    ├── timeline.html      ← Gantt chart eksekusi
    ├── dag.html           ← diagram alur pipeline
    └── trace.tsv          ← data benchmarking (import ke Excel, Tabel 4.4)
```

**Cara baca N50:** Kalau N50 = 500,000 bp, artinya 50% total panjang genome tersusun dari contig yang panjangnya ≥ 500,000 bp. Makin besar N50, makin baik kualitas assembly.

---

## 💬 Pertanyaan Dosen Penguji — Lengkap

**Q: "Kenapa Minigraph-Cactus, bukan PGGB?"**
> A: "PGGB melakukan all-vs-all alignment — untuk 5 genome kelapa sawit (~750 MB × 5) bisa memakan waktu berminggu-minggu bahkan di HPC. Minigraph-Cactus menggunakan pendekatan reference-guided yang jauh lebih cepat (beberapa jam) dengan akurasi yang hampir setara, sesuai penelitian Hickey et al. 2024 di Nature Biotechnology."

**Q: "Apa itu core dan variable genome?"**
> A: "Core genome adalah segmen DNA yang ada di semua 5 kultivar — bagian 'wajib' kelapa sawit. Variable genome hanya ada di sebagian kultivar — mencerminkan variasi genetik unik tiap kultivar. Variable genome sering mengandung gen yang bertanggung jawab atas perbedaan fenotip seperti kandungan minyak."

**Q: "Bagaimana menjamin reproducibility hasil?"**
> A: "Tiga cara: pertama, semua tool dikunci pada versi spesifik di conda dan Docker. Kedua, semua parameter tersimpan di nextflow.config dan versions.yml. Ketiga, mekanisme -resume Nextflow memastikan kalau pipeline dijalankan ulang dengan input yang sama, hasilnya identik."

**Q: "Kenapa ada dua tahap graph construction?"**
> A: "Minigraph membangun SV-level graph dengan cepat — mendeteksi perbedaan struktural besar (>50 bp). Cactus lalu melakukan base-level alignment akurat menggunakan graph Minigraph sebagai panduan. Dua tahap ini adalah kontribusi utama paper Hickey et al. 2024 — lebih cepat dari all-vs-all tapi tetap akurat sampai level single nucleotide."

**Q: "Apa yang terjadi kalau pipeline gagal di tengah?"**
> A: "Nextflow punya mekanisme -resume. Semua hasil tersimpan di folder work/ dengan hash unik per proses. Saat dijalankan ulang, Nextflow cek cache — proses yang sudah selesai di-skip, hanya yang gagal diulang. Di HPC dengan Cactus yang butuh 6+ jam, fitur ini sangat kritis."

**Q: "Bisa dipakai untuk organisme lain?"**
> A: "Ya. Pipeline ini generik — yang perlu diubah hanya samplesheet.csv dan --reference_name. Tidak ada nama organisme yang hardcoded di kode pipeline. Ini keunggulan arsitektur modular nf-core yang kami terapkan."
