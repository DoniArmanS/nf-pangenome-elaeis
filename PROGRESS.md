# 📋 Progress Skripsi — nf-pangenome-elaise
> Terakhir diupdate: **2026-06-26**
> **Deadline Analisis: November 2026 | Komprehensif: Desember 2026**

---

## 📊 Persentase Kesiapan Keseluruhan

```
Infrastructure  ████████████████████  100%
Preprocessing   ██████████████████░░   90%  (code ada, belum ditest dengan tool asli)
QC (QUAST)      ████████████████░░░░   80%  (module ada, belum ditest)
Graph Construct ██████████████░░░░░░   70%  (module ada, stub OK, tool belum install)
Graph Analysis  ████████████░░░░░░░░   60%  (odgi+vg module ada, belum ditest)
HPC/Slurm       ████████░░░░░░░░░░░░   40%  (config ada, belum implement di Mahameru)
Testing & Eval  ████░░░░░░░░░░░░░░░░   20%  (stub OK, real run belum)
Penulisan BAB   ██░░░░░░░░░░░░░░░░░░   10%  (metodologi draft)
─────────────────────────────────────────────
TOTAL ANALISIS  ██████░░░░░░░░░░░░░░  ~34%
```

> **Catatan:** Kode pipeline sudah ~70% lengkap. Analisis biologis (data asli, hasil nyata) baru ~34%.

---

## ✅ Setup & Infrastruktur — 100% SELESAI

- [x] Inisiasi repository `nf-pangenome-elaise` di GitHub
- [x] Struktur folder nf-core convention
- [x] `.gitignore` — eksklusikan DATA SKRIPSI, PROPOSAL, logs, genome besar
- [x] `main.nf` — entry point Nextflow DSL2
- [x] `nextflow.config` — profiles: local, docker, singularity, slurm, test
- [x] Install Nextflow v26.04.4 di `~/.local/bin`
- [x] SSH key GitHub terhubung (DoniArmanS)
- [x] Git + GitHub push sukses

---

## ✅ Kode Pipeline — Selesai (Belum Ditest dengan Tool Asli)

### Modules
- [x] `modules/local/preprocessing/seqkit_stats.nf`
- [x] `modules/local/preprocessing/seqkit_filter.nf`
- [x] `modules/local/qc/quast.nf`
- [x] `modules/local/graph_construction/minigraph.nf`
- [x] `modules/local/graph_construction/cactus_minigraph.nf`
- [x] `modules/local/graph_analysis/odgi.nf` (ODGI_STATS + ODGI_VIZ)
- [x] `modules/local/graph_analysis/vg_stats.nf` ← **baru ditambah**
- [x] `modules/local/variant_calling/vg_deconstruct.nf`

### Subworkflows
- [x] `subworkflows/local/validate_input.nf`
- [x] `subworkflows/local/preprocessing.nf`
- [x] `subworkflows/local/qc.nf`
- [x] `subworkflows/local/graph_construction.nf` (Minigraph-Cactus)
- [x] `subworkflows/local/graph_analysis.nf` (odgi + vg stats)
- [x] `subworkflows/local/variant_calling.nf`

### Workflow Utama
- [x] `workflows/pangenome.nf` — 5 tahap sesuai proposal

### Scripts & Dokumentasi
- [x] `bin/extract_core_var.sh` — core vs variable sequences
- [x] `tests/subset_real_data.py` — subset genome asli
- [x] `tests/test_data/` — 3 assembly subset (EGPMv6, EG01, ASM167249v1)
- [x] `docs/NEXTFLOW_PRINCIPLES.md`
- [x] README.md (Bahasa Indonesia, alur sesuai proposal)

---

## 🔄 Analisis — Tahap 1: Preprocessing

- [ ] Ekstrak semua 5 zip genome dari DATA SKRIPSI
  - [x] EG01 — sudah diekstrak
  - [x] ASM167249v1 — sudah diekstrak
  - [x] EGPMv6 — sudah diekstrak
  - [ ] EG11 — belum diekstrak (989MB zip)
  - [ ] Eg-DCM — belum diekstrak
- [ ] Rename header FASTA ke PanSN-spec (`sample#hap#seq`)
- [ ] Buat samplesheet.csv dari 5 assembly asli

---

## 🔄 Analisis — Tahap 2: Quality Control (QUAST)

- [ ] Install QUAST (`conda install -c bioconda quast`)
- [ ] Jalankan QUAST pada 5 assembly asli
- [ ] Catat: N50, jumlah contig, total bp, GC% per assembly
- [ ] Tentukan backbone referensi (N50 tertinggi / kromosom-level)
  - Kandidat: EGPMv6 (kromosom-level, 165 scaffolds)

---

## 🔄 Analisis — Tahap 3: Konstruksi Pangenome Graph (Minigraph-Cactus)

- [ ] Install minigraph (`conda install -c bioconda minigraph`)
- [ ] Install cactus (`singularity pull cactus.sif`)
- [ ] Test stub-run fix (lihat ERRORS.md — WFMASH CPU limit)
- [ ] Jalankan minigraph dengan data test_data subset
- [ ] Jalankan cactus-minigraph dengan data test_data subset
- [ ] Verifikasi output GFA valid

---

## 🔄 Analisis — Tahap 4: Evaluasi & Statistik

- [ ] Install odgi (`conda install -c bioconda odgi`)
- [ ] Install vg (`conda install -c bioconda vg`)
- [ ] Jalankan `odgi stats` → node, edge, path count
- [ ] Jalankan `vg stats` → statistik graph
- [ ] Jalankan `odgi viz` → visualisasi 1D
- [ ] Jalankan `bin/extract_core_var.sh` → core & variable sequences
- [ ] Dokumentasi hasil di BAB IV

---

## 🔄 Tahap 5: Implementasi & Evaluasi HPC Mahameru

- [ ] Akses HPC Mahameru BRIN
- [ ] Upload data dan pipeline ke HPC
- [ ] Jalankan pipeline dengan profile `slurm`
- [ ] Ukur runtime per tahap (QC, graph, evaluasi)
- [ ] Ukur penggunaan CPU dan memori (dari `trace.tsv`)
- [ ] Test `auto-resume` (simulasi kegagalan dan lanjut)
- [ ] Dokumentasi: `report.html`, `timeline.html`, `dag.html`

---

## 📝 Penulisan Skripsi

- [ ] BAB I — Pendahuluan (dari proposal)
- [ ] BAB II — Landasan Teori (dari proposal)
- [ ] BAB III — Metodologi (update sesuai implementasi)
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

---

## 🗓 Timeline Target

| Bulan | Target |
|-------|--------|
| Juni 2026 | ✅ Setup repo, infrastruktur, kode pipeline lengkap |
| Juli 2026 | Install tools, preprocessing 5 assembly asli |
| Agustus 2026 | QC QUAST + Minigraph-Cactus (data asli kecil dulu) |
| September 2026 | Graph analysis + evaluasi statistik |
| Oktober 2026 | Implementasi & benchmarking di HPC Mahameru |
| November 2026 | **DEADLINE ANALISIS** + draft BAB IV |
| Desember 2026 | **KOMPREHENSIF** |
