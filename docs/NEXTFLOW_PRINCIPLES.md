# 📐 Nextflow Coding Principles — nf-pangenome-elaise

> Referensi cepat prinsip coding Nextflow (DSL2) yang dipakai di project ini.
> Baca ini dulu sebelum nulis process atau workflow baru.

---

## 1. Struktur File (nf-core Convention)

```
nf-pangenome-elaise/
├── main.nf                    # Entry point — HANYA berisi workflow call
├── nextflow.config            # Semua config, params, profiles
├── modules/
│   └── local/
│       ├── alignment/         # Satu folder per kategori tool
│       │   └── wfmash.nf      # Satu file per tool/proses
│       └── graph_analysis/
│           └── odgi.nf
├── workflows/
│   └── pangenome.nf           # Workflow utama — orchestrator
├── subworkflows/
│   └── local/
│       ├── validate_input.nf
│       └── graph_construction.nf
├── conf/                      # Config tambahan (base.config, hpc.config)
├── bin/                       # Script helper (Python/R/Bash) — wajib chmod +x
└── tests/
    └── dummy_data/            # Data kecil untuk testing
```

---

## 2. Anatomi Process yang Benar

```groovy
process NAMA_TOOL {
    // ── Metadata ─────────────────────────────────────
    tag "${meta.id}"           // Muncul di log → mudah debug
    label 'process_medium'    // Referensi ke resource di config

    // ── Container (uncomment kalau ready) ────────────
    // container 'quay.io/biocontainers/tool:versi'

    // ── Input ─────────────────────────────────────────
    input:
    tuple val(meta), path(input_file)    // meta = map ID + info

    // ── Output ────────────────────────────────────────
    output:
    tuple val(meta), path("*.output"),  emit: result
    path "versions.yml",                emit: versions   // WAJIB

    // ── Script ────────────────────────────────────────
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args   = task.ext.args   ?: ""
    """
    tool_command \\
        ${input_file} \\
        -o ${prefix}.output \\
        -t ${task.cpus} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        toolname: \$(tool --version 2>&1 | head -1)
    END_VERSIONS
    """

    // ── Stub (untuk testing tanpa install tool) ───────
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.output
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        toolname: "stub-0.0.0"
    END_VERSIONS
    """
}
```

---

## 3. Meta Map — Pattern Wajib

Selalu bawa metadata via `meta` map di channel. Ini yang bikin module reusable.

```groovy
// ✅ BENAR — meta map
Channel
    .fromPath("*.fa")
    .map { fasta -> [ [id: fasta.baseName, type: 'assembly'], fasta ] }

// ❌ SALAH — path mentah tanpa meta
Channel.fromPath("*.fa")
```

---

## 4. Channel Rules

```groovy
// ✅ Join channel dengan key yang sama
ch_fasta.join(ch_paf, by: 0)   // by: 0 = join by meta

// ✅ Combine all-vs-all
ch_fasta.combine(ch_ref)

// ✅ Simpan channel ke variable kalau mau dipakai 2×
ch_data = PROCESS_A.out.result
PROCESS_B(ch_data)
PROCESS_C(ch_data)   // aman, tidak conflict

// ❌ JANGAN consume channel 2× tanpa disimpan dulu
```

---

## 5. Konfigurasi yang Benar

```groovy
// Di nextflow.config:
process {
    withLabel: process_high {
        cpus   = { 8 * task.attempt }   // Scale dengan retry
        memory = { 16.GB * task.attempt }
        time   = { 8.h * task.attempt }
    }

    // Override untuk process spesifik
    withName: 'WFMASH' {
        ext.args = "--no-split"   // Extra args dari config, bukan hardcode
    }
}
```

---

## 6. Script Best Practices dalam Process

```bash
# ✅ Gunakan task.cpus untuk threading
tool -t ${task.cpus}

# ✅ Gunakan backslash untuk command panjang (readable)
wfmash \\
    ${fasta} \\
    -s ${params.segment_len} \\
    > output.paf

# ✅ Escape $ untuk variabel BASH (bukan Nextflow) dalam heredoc
cat <<-END_VERSIONS > versions.yml
"${task.process}":
    wfmash: \$(wfmash --version 2>&1)
END_VERSIONS

# ❌ JANGAN hardcode path absolut
# tool /home/doni/data/file.fa   → SALAH

# ✅ File selalu di-stage otomatis oleh Nextflow
# Cukup pakai nama file
tool ${fasta} -o output.gfa
```

---

## 7. Cara Test Tanpa HPC (Stub Mode)

```bash
# Jalankan dengan data dummy, semua process pakai stub
nextflow run main.nf -profile test --stub-run

# Resume setelah error
nextflow run main.nf -profile test -resume

# Debug — lihat apa yang dijalankan
nextflow run main.nf -profile test --stub-run -with-trace

# Generate data dummy baru
python3 tests/dummy_data/generate_dummy.py
```

---

## 8. Checklist Sebelum Push ke GitHub

- [ ] `nextflow run main.nf -profile test --stub-run` → tidak ada error
- [ ] Tidak ada path absolut di dalam `.nf` files
- [ ] Semua process punya `emit: versions` dengan `versions.yml`
- [ ] Tidak ada data asli/besar yang ter-commit (cek `.gitignore`)
- [ ] PROGRESS.md diupdate
- [ ] ERRORS.md dicatat kalau ada error baru yang solved

---

## 9. Tools yang Dipakai (Summary)

| Tool | Fungsi | Conda Package |
|------|--------|---------------|
| `wfmash` | All-vs-All alignment | `bioconda::wfmash` |
| `seqwish` | Graph induction | `bioconda::seqwish` |
| `smoothxg` | Graph normalization | `bioconda::smoothxg` |
| `gfaffix` | Redundancy reduction | `bioconda::gfaffix` |
| `odgi` | Graph analysis & viz | `bioconda::odgi` |
| `vg` | Variant calling | `bioconda::vg` |
| `seqkit` | FASTA stats & filter | `bioconda::seqkit` |
| `MultiQC` | Aggregate QC report | `bioconda::multiqc` |

---

## 10. Referensi Utama

- [Nextflow DSL2 Docs](https://www.nextflow.io/docs/latest/)
- [nf-core Guidelines](https://nf-co.re/docs/contributing/guidelines)
- [PGGB Paper (Garrison et al. 2023)](https://doi.org/10.1038/s41592-022-01755-1)
- [nf-core/pangenome](https://github.com/nf-core/pangenome)
- [PanSN-spec (naming convention)](https://github.com/pangenome/PanSN-spec)
