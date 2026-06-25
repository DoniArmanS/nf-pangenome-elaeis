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

> Belum ada error yang tercatat.

---

## ✅ Solved Issues

> Kosong dulu — isi saat ada error yang berhasil dipecahkan.

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
