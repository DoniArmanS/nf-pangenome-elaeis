# 🐛 Error Log — nf-pangenome-elaise

> Catat **setiap error** di sini lengkap dengan solusinya.
> Format: tanggal | komponen | error | status | solusi

---

## Template Entry

```
### [YYYY-MM-DD] JUDUL ERROR SINGKAT
- **Komponen**: nama_module / subworkflow / CLI
- **Command**:
  ```bash
  nextflow run ...
  ```
- **Error message**:
  ```
  paste error di sini
  ```
- **Root Cause**: penjelasan kenapa error
- **Solusi**: apa yang dilakukan untuk menyelesaikan
- **Status**: ✅ Solved / ❌ Unsolved / ⏳ Investigating
```

---

## 🔴 Open Issues

### [2026-06-26] Stub run — WFMASH CPU limit (sudah diganti Minigraph-Cactus, tapi pola sama)
- **Komponen**: `process_high` label di `nextflow.config`
- **Command**:
  ```bash
  nextflow run main.nf -profile test -stub -resume
  ```
- **Error message**:
  ```
  Process requirement exceeds available CPUs -- req: 8; avail: 4
  ```
- **Root Cause**: Label `process_high` default ke 8 CPU di config global. Profile `test` mendefinisikan override di dalam `process {}` block, tapi saat `-resume` override belum terbaca karena cache dari run sebelumnya.
- **Solusi yang dicoba**: Menambahkan `withLabel: process_high { cpus = 4 }` di dalam profile `test` — override ada tapi cache lama masih terbawa.
- **Langkah selanjutnya**: Buat `conf/test.config` terpisah dan gunakan `includeConfig` di profile test. Atau hapus folder `work/` sebelum test ulang.
- **Status**: ⏳ Investigating

---

## ✅ Solved Issues

### [2026-06-26] `workflow.onComplete` — Statements cannot be mixed with script declarations
- **Komponen**: `main.nf`
- **Error message**:
  ```
  Error main.nf:49:1: Statements cannot be mixed with script declarations
  -- move statements into a process, workflow, or function
  ```
- **Root Cause**: Nextflow **v26** DSL2 strict mode — `workflow.onComplete {}` tidak boleh di top-level script di luar `workflow {}` block. Berbeda dari Nextflow v22/v23.
- **Solusi**: Hapus `workflow.onComplete` block dari `main.nf`. Log completion bisa ditambahkan nanti via event handler di `nextflow.config` jika dibutuhkan.
- **Status**: ✅ Solved

---

### [2026-06-26] `--stub-run` flag tidak dikenali di Nextflow v26
- **Komponen**: CLI / Nextflow v26.04.4
- **Error**: Pipeline berjalan dengan tool asli (bukan stub), `seqkit: command not found`
- **Root Cause**: Di Nextflow **v26**, flag stub mode adalah `-stub` (single dash, bukan double dash). Flag `--stub-run` sudah deprecated.
- **Solusi**:
  ```bash
  # ❌ Salah (lama)
  nextflow run main.nf --stub-run
  # ✅ Benar (v26)
  nextflow run main.nf -stub
  ```
- **Status**: ✅ Solved

---

### [2026-06-26] Pipeline pakai PGGB bukan Minigraph-Cactus (tool salah)
- **Komponen**: `modules/local/alignment/`, `graph_construction/seqwish`, `graph_construction/smoothxg`
- **Root Cause**: Pipeline awal dibangun menggunakan PGGB (wfmash → seqwish → smoothxg), padahal proposal menyebutkan **Minigraph-Cactus** (Hickey et al. 2024).
- **Solusi**: Refactor total — hapus semua modul PGGB, ganti dengan:
  - `modules/local/qc/quast.nf`
  - `modules/local/graph_construction/minigraph.nf`
  - `modules/local/graph_construction/cactus_minigraph.nf`
  - `modules/local/graph_analysis/vg_stats.nf`
  - `subworkflows/local/qc.nf`
- **Status**: ✅ Solved

---

## 📚 Quick Reference — Debugging Nextflow

### Lihat log process yang gagal
```bash
# Log utama
tail -100 .nextflow.log

# Masuk work directory process gagal (cari hash dari output)
cat work/ab/123456*/.command.err
cat work/ab/123456*/.command.out
cat work/ab/123456*/.command.sh
```

### Reset dan test ulang
```bash
# Hapus cache lama (solusi untuk error CPU limit di atas)
rm -rf work/ results/ .nextflow/
nextflow run main.nf -profile test -stub
```

### Resume dari titik kegagalan
```bash
nextflow run main.nf -profile test -stub -resume
```

### Cek versi Nextflow
```bash
nextflow -version
# Harus ≥ 23.04.0, saat ini: v26.04.4
```

---

## 📝 Catatan Tool-Specific

| Tool | Catatan Penting |
|------|----------------|
| **cactus-minigraph** | Butuh `jobstore` directory — jangan taruh di `/tmp` saat di HPC |
| **odgi** | File input harus `.og` (binary), bukan `.gfa` langsung — perlu `odgi build` dulu |
| **vg** | Format GFA dari Cactus kadang perlu di-validate dulu dengan `vg validate` |
| **QUAST** | Opsi `--no-html` untuk mode headless di HPC (tanpa browser) |
| **Nextflow di HPC** | Jalankan `nextflow` dari `screen` atau `tmux` agar tidak putus saat SSH disconnect |
