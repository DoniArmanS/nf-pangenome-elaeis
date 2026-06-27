# 📚 Panduan Belajar Arsitektur Nextflow Pangenome

Dokumen ini dibuat khusus untuk membantumu **memahami** keseluruhan isi kode proyek skripsimu. Anggap dokumen ini sebagai "buku saku" yang bisa kamu baca saat bingung "file ini buat apa sih?". 

Arsitektur yang kita pakai di sini mengikuti standar **nf-core (Nextflow Core)**, yaitu standar industri bioinformatika dunia. Karena itu, kodenya sengaja dipecah-pecah ke banyak folder agar rapi, modular (bisa dipakai ulang), dan mudah diperbaiki.

---

## 🏭 Analogi Pabrik (Biar Gampang Paham!)

Bayangkan pipeline Nextflow kita ini adalah sebuah **Pabrik Pembuatan Roti**:
- **`main.nf` (Sang Manajer Pabrik):** Dia yang membuka pabrik, membaca pesanan (`samplesheet.csv`), lalu menyuruh kepala divisi bekerja.
- **`nextflow.config` (Manajer HRD & Keuangan):** Dia yang menentukan berapa banyak orang (CPU) dan berapa banyak dana/bahan (RAM) yang boleh dipakai untuk tiap tugas, serta baju kerja apa yang dipakai (Conda / Docker / Slurm).
- **`workflows/` (Kepala Divisi):** Dia mengatur alur pesanan secara garis besar (Bahan Masuk → Adonan → Panggang → Packing).
- **`subworkflows/` (Kepala Regu):** Dia mengatur detail pekerjaan. Misalnya, Kepala Regu "Panggang" akan mengatur suhu oven, berapa lama dipanggang.
- **`modules/` (Mesin / Pekerja Pabrik):** Ini adalah mesin aslinya! Di sinilah *command line* asli (bash script) seperti `quast` atau `cactus-minigraph` dieksekusi. Pekerja ini hanya tahu "Saya dikasih bahan A, saya harus jadikan barang B".
- **`Channel` (Ban Berjalan / Conveyor Belt):** Ini adalah pipa tempat data mengalir dari satu pekerja ke pekerja lain.

---

## 📂 Penjelasan Detail Per Folder & File

### 1. File Utama di Luar Folder
- **`main.nf`**
  - **Fungsi:** Ini adalah pintu gerbang. Saat kamu ketik `nextflow run main.nf`, file inilah yang pertama kali dibaca.
  - **Isi:** Hanya berisi perintah sederhana untuk mengimpor dan memanggil workflow utama (`PANGENOME_WORKFLOW`).
- **`nextflow.config`**
  - **Fungsi:** Menyimpan semua pengaturan (konfigurasi).
  - **Isi:** 
    - `params`: Variabel default (seperti `--max_cpus 8`).
    - `process`: Label untuk ukuran mesin (misal `process_high` butuh RAM besar).
    - `profiles`: Menghubungkan ke file config spesifik (contoh: jika user ketik `-profile slurm`, maka ia akan membaca `conf/hpc.config`).

### 2. Folder `conf/` (Konfigurasi Lingkungan)
- **Fungsi:** Memisahkan settingan komputer lokal vs superkomputer HPC.
- **Isi:**
  - `test.config`: Aturan ketat untuk komputermu (misal max CPU 2, RAM 4GB) supaya laptopmu tidak hang saat *testing*.
  - `hpc.config`: Aturan sultan untuk Mahameru (maksimal 128 CPU, 64GB RAM) yang menggunakan executor Slurm.

### 3. Folder `workflows/`
- **`workflows/pangenome.nf`**
  - **Fungsi:** Merangkai seluruh *subworkflows* menjadi satu alur cerita penuh sesuai proposal skripsimu.
  - **Isi:** Di sini kamu bisa melihat jelas urutan kerjanya: 
    1. `VALIDATE_INPUT()` (Baca CSV)
    2. `PREPROCESSING()` (Filter sekuens)
    3. `QC()` (QUAST)
    4. `GRAPH_CONSTRUCTION()` (Minigraph-Cactus)
    5. `GRAPH_ANALYSIS()` (Statistik odgi & vg).

### 4. Folder `subworkflows/local/`
Subworkflow bertugas menghubungkan beberapa *modules* (pekerja tunggal) agar bekerja sama.
- **`validate_input.nf`**: Membaca file `samplesheet.csv`, mengecek apakah file FASTA-nya benar-benar ada, dan mengirimkannya ke ban berjalan (*channel*).
- **`preprocessing.nf`**: Menjalankan `seqkit_stats`, lalu setelah selesai, hasilnya dikirim ke `seqkit_filter`.
- **`qc.nf`**: Menyuruh modul `quast` menganalisis FASTA yang sudah bersih.
- **`graph_construction.nf`**: **Ini jantungnya!** Di sini ada logika rumit untuk memisahkan genom referensi (backbone) dari genom lain. Referensi dikirim duluan ke `minigraph`, lalu hasil grafnya digabungkan lagi dengan sisa genom untuk dikerjakan oleh `cactus_minigraph`.
- **`graph_analysis.nf`**: Menyuruh modul `odgi` dan `vg_stats` menganalisis graf final dari Cactus.

### 5. Folder `modules/local/`
Modul adalah **tempat kerja aslinya**. Di sinilah kode bioinformatika sungguhan (bash command) berada.
Format setiap modul selalu sama:
1. `input:` Bahan baku apa yang diterima.
2. `output:` Barang jadi apa yang dihasilkan.
3. `script:` Command terminal (bash) yang dieksekusi.

Contoh file di dalamnya:
- **`graph_construction/cactus_minigraph.nf`**: 
  - **Fungsi:** Menjalankan tools `cactus-minigraph`.
  - **Isinya:** Di bagian `script:` kamu akan melihat tulisan `cactus-minigraph ${jobstore} ${seqfile} ...`. Inilah perintah asli yang akan dijalankan oleh Docker.
- **`qc/quast.nf`**:
  - **Isinya:** Menjalankan perintah `quast.py ${fasta} -o .`

### 6. Folder `data/`
- **Fungsi:** Tempat kamu menaruh input file FASTA yang asli. Dipisah per subfolder agar rapi (EGPMv6, EG01, dll).

### 7. Folder `bin/`
- **Fungsi:** Tempat menaruh script buatan sendiri yang bukan bawaan Nextflow. Script di folder `bin/` otomatis dikenali oleh Nextflow sebagai perintah terminal.
- **`extract_core_var.sh`**: Script Bash yang kita buat sendiri untuk mengekstrak sekuens yang *core* (inti) dan *variable* dari output odgi.

---

## 🌊 Konsep Paling Penting: "Dataflow" & "Channel"

Nextflow tidak bekerja seperti program Python atau PHP yang membaca dari atas ke bawah baris per baris. Nextflow bekerja secara **reaktif** menggunakan **Channel** (Ban Berjalan).

Contoh: 
Di `workflows/pangenome.nf` kamu menulis:
```groovy
PREPROCESSING(ch_fasta)
QC(PREPROCESSING.out.fasta)
```

Artinya:
- Proses QC **tidak akan jalan** sampai proses PREPROCESSING selesai.
- Kalau kamu punya 5 data, dan data ke-1 selesai PREPROCESSING lebih cepat, data ke-1 akan **langsung** masuk ke QC tanpa menunggu ke-4 data lainnya selesai! Inilah yang membuat Nextflow sangat cepat dan otomatis paralel (multi-tasking).

## 💡 Pesan untuk Pembelajaran
Saat kamu nanti ditanya oleh dosen penguji: *"Bagaimana caramu menjalankan Cactus?"*
**Jawaban terbaik:** 
*"Saya merangkum eksekusi Cactus di dalam modul `modules/local/graph_construction/cactus_minigraph.nf`. Modul ini didefinisikan untuk mengambil input berupa file sekunes dan GFA referensi, lalu mengeksekusi `cactus-minigraph` di dalam container Docker. Nextflow otomatis mengatur bahwa modul ini baru akan dieksekusi setelah modul `minigraph` selesai membentuk SV-level graph."*

Dengan struktur ini, kode kamu terlihat sangat profesional, setara dengan proyek-proyek bioinformatika skala internasional! 🚀
