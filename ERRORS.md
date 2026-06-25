# 🐛 Error Log — nf-pangenome-elaise

> File ini untuk mencatat error, bug, dan solusinya selama pengerjaan skripsi.
> Format: **tanggal | komponen | deskripsi error | status | solusi**

---

## Template Entry

```
### [YYYY-MM-DD] JUDUL ERROR SINGKAT
- **Komponen**: nama_module / workflow / tool
- **Command**:
  ```bash
  nextflow run ...
  ```
- **Error message**:
  ```
  paste error disini
  ```
- **Root Cause**: penjelasan kenapa error
- **Solusi**: apa yang dilakukan
- **Status**: ✅ Solved / ❌ Unsolved / ⏳ Investigating
```

---

## 🔴 Open Issues

### [2026-06-26] WFMASH: Process requirement exceeds available CPUs
- **Komponen**: `modules/local/alignment/wfmash.nf` — label `process_high`
- **Command**:
  ```bash
  nextflow run main.nf -profile test -stub
  ```
- **Error message**:
  ```
  Process requirement exceeds available CPUs -- req: 8; avail: 4
  ```
- **Root Cause**: Default `process_high` di `nextflow.config` set ke 8 CPU, tapi laptop hanya punya 4. Override di profile `test` belum terbaca dengan benar karena config di-load sebelum profile override diterapkan ke process block.
- **Solusi yang dicoba**: Menambahkan `process { withLabel: process_high { cpus = 4 } }` di dalam profile `test` — tapi override belum efektif saat `-resume`.
- **Langkah selanjutnya**: Pindahkan CPU cap ke `conf/test.config` terpisah, atau tambahkan `cpus = { Math.min(4, task.attempt * 4) }` di process_high default.
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
- **Root Cause**: Nextflow v26 DSL2 strict mode tidak mengizinkan `workflow.onComplete { }` atau `workflow.onComplete = { }` di top-level script di luar `workflow {}` block.
- **Solusi**: Hapus `workflow.onComplete` block dari `main.nf`. Completion log bisa ditambahkan nanti lewat `nextflow.config` atau operator `view` di dalam workflow jika diperlukan.
- **Status**: ✅ Solved

### [2026-06-26] `--stub-run` flag tidak dikenali di Nextflow v26
- **Komponen**: CLI / Nextflow v26.04.4
- **Error**: Pipeline berjalan dengan tool asli (bukan stub), `seqkit: command not found`
- **Root Cause**: Di Nextflow v26, flag stub adalah `-stub` (satu dash), bukan `--stub-run`.
- **Solusi**: Ganti `--stub-run` → `-stub`
- **Status**: ✅ Solved

---

## 📚 Common Nextflow Pitfalls (referensi cepat)

| Error | Kemungkinan Penyebab | Quick Fix |
|-------|---------------------|-----------|
| `No such file or directory` di process | Path relative dalam script | Gunakan `${projectDir}` atau pastikan file di-stage dengan benar |
| `Process terminated with an error exit status` | Tool crash / OOM | Tambah memory di `process.memory`, cek log di `work/` |
| `Channel was already consumed` | Channel dipakai 2× | Gunakan `.multiMap{}` atau simpan ke variable terpisah |
| `Missing value for parameter 'input'` | Lupa kasih `--input` | Cek `nextflow.config` bagian `params.input` |
| `WARN: Killing running tasks` | Pipeline di-cancel | Normal, bukan error. Resume dengan `-resume` |
| `Staging file error` | File tidak ada saat runtime | Pastikan path di samplesheet.csv valid & file ada |
| `Task exceeded max retries` | Tool butuh lebih banyak resource | Naikkan `maxRetries` atau `process_high` memory |

---

## 🛠 Debugging Tips

### Cek log process yang gagal
```bash
# Lihat .nextflow.log
tail -100 .nextflow.log

# Masuk ke work directory process yang gagal
# (cari hashnya dari output Nextflow, e.g. [ab/123456])
ls work/ab/123456*/
cat work/ab/123456*/.command.err
cat work/ab/123456*/.command.out
cat work/ab/123456*/.command.sh   # lihat script yang dijalankan
```

### Resume pipeline setelah error
```bash
nextflow run main.nf -profile test -resume
```

### Jalankan hanya 1 process (dry-run/stub)
```bash
nextflow run main.nf -profile test --stub-run
```

### Cek resource usage
```bash
# Setelah pipeline, buka:
open results/pipeline_info/report.html
```

---

## 📝 Catatan Khusus *Elaeis guineensis*

- Genome EG11 sangat besar (~1GB zip) — mungkin perlu HPC untuk proses ini
- EG01 lebih kecil, cocok untuk development/testing di lokal
- Header FASTA dari NCBI perlu di-rename ke format PanSN-spec sebelum masuk wfmash
- wfmash butuh setidaknya 2 sequences dalam 1 file atau all-vs-all dari multiple files
