# nf-pangenome-elaise

A **Nextflow DSL2** pipeline for constructing and analyzing **pangenome graphs** from multiple *Elaeis guineensis* (oil palm) assemblies. Built following [nf-core](https://nf-co.re/) conventions.

---

## Overview

This pipeline implements the [PGGB](https://github.com/pangenome/pggb) (PanGenome Graph Builder) workflow:

```
Input FASTAs (multi-assembly)
        │
        ▼
 [wfmash]      ─── All-vs-all sequence alignment → .PAF
        │
        ▼
 [seqwish]     ─── Variation graph induction → .GFA
        │
        ▼
 [smoothxg]    ─── Graph normalization (local linearity)
        │
        ▼
 [gfaffix]     ─── Redundancy reduction
        │
        ▼
 [odgi]        ─── Graph statistics + 1D/2D visualization
        │
        ▼
 [vg]          ─── (optional) Variant calling → .VCF
        │
        ▼
 [MultiQC]     ─── Aggregated QC report
```

---

## Requirements

| Tool | Version | Notes |
|------|---------|-------|
| [Nextflow](https://www.nextflow.io/) | ≥ 23.04.0 | Required |
| Java | ≥ 11 | Required by Nextflow |
| Docker *or* Singularity *or* Conda | any | For software environments |

### Install Nextflow

```bash
# Install to ~/.local/bin (no sudo required)
curl -s https://get.nextflow.io | bash
mkdir -p ~/.local/bin && mv nextflow ~/.local/bin/
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc

# Verify
nextflow -version
```

---

## Quick Start

### 1. Test with real data subset (stub mode — no tools needed)

```bash
# Generate test subset from real assemblies (first time only)
# Requires: genome zips already extracted under DATA SKRIPSI/
python3 tests/subset_real_data.py

# Run pipeline in stub mode (simulates all processes without executing tools)
nextflow run main.nf \
    -profile test \
    --input tests/test_data/samplesheet.csv \
    --stub-run
```

### 2. Full local run (tools must be installed)

```bash
nextflow run main.nf \
    -profile local \
    --input tests/test_data/samplesheet.csv \
    --outdir results/
```

### 3. With Docker

```bash
nextflow run main.nf \
    -profile docker \
    --input path/to/samplesheet.csv \
    --outdir results/
```

### 4. Resume after failure

```bash
nextflow run main.nf -profile test -resume
```

---

## Input

### Samplesheet CSV

```csv
sample,fasta,cultivar
EGPMv6,path/to/EGPMv6.fa,AVROS
EG01,path/to/EG01.fa,Jacq
ASM167249v1,path/to/ASM167249v1.fa,Dura
```

- `sample` — unique sample ID
- `fasta` — path to FASTA file (PanSN-spec headers recommended)
- `cultivar` — metadata (variety/cultivar)

### FASTA Header Format (PanSN-spec)

Sequences must use the PanSN naming convention:

```
>{sample}#{haplotype}#{sequence_name}

# Example:
>EGPMv6#1#GK000076.1
```

See [PanSN-spec](https://github.com/pangenome/PanSN-spec) for details.

---

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--input` | `null` | Samplesheet CSV or single FASTA |
| `--outdir` | `./results` | Output directory |
| `--mode` | `full` | `full` \| `graph_only` \| `variant_only` |
| `--segment_len` | `5000` | wfmash segment length (`-s`) |
| `--min_map_pct` | `90` | wfmash min mapping identity % (`-p`) |
| `--n_haplotypes` | `5` | wfmash number of haplotypes (`-n`) |
| `--min_match_len` | `311` | seqwish min match length (`-k`) |
| `--call_variants` | `false` | Enable vg variant calling |
| `--reference` | `null` | Reference for VCF deconstruct |
| `--max_memory` | `16.GB` | Max memory cap |
| `--max_cpus` | `8` | Max CPU cap |

---

## Profiles

| Profile | Description |
|---------|-------------|
| `local` | Local execution, no container |
| `docker` | Docker containers |
| `singularity` | Singularity (HPC-compatible) |
| `slurm` | SLURM scheduler + Singularity |
| `test` | Uses `tests/test_data/`, reduced resources |

---

## Project Structure

```
nf-pangenome-elaise/
├── main.nf                        # Pipeline entry point
├── nextflow.config                # Parameters, profiles, resources
│
├── workflows/
│   └── pangenome.nf               # Top-level workflow orchestrator
│
├── subworkflows/local/
│   ├── validate_input.nf          # Input parsing & validation
│   ├── preprocessing.nf           # Sequence QC & filtering
│   ├── graph_construction.nf      # wfmash → seqwish → smoothxg
│   ├── graph_analysis.nf          # odgi stats & visualization
│   └── variant_calling.nf         # vg deconstruct → VCF
│
├── modules/local/
│   ├── alignment/wfmash.nf
│   ├── graph_construction/
│   │   ├── seqwish.nf
│   │   └── smoothxg.nf
│   └── graph_analysis/odgi.nf
│
├── tests/
│   ├── subset_real_data.py        # Extract test subset from real genomes
│   └── test_data/                 # Small real-data subsets (tracked in git)
│       ├── EGPMv6.fa              # 5 seqs × 100kb from AVROS assembly
│       ├── EG01.fa                # 5 seqs × 100kb from EG01 assembly
│       ├── ASM167249v1.fa         # 5 seqs × 100kb from Dura assembly
│       └── samplesheet.csv
│
├── conf/                          # Additional config files
├── bin/                           # Helper scripts (must be chmod +x)
├── notebooks/                     # Jupyter notebooks for exploration
├── scripts/                       # Standalone analysis scripts
│
├── PROGRESS.md                    # Task checklist & timeline
├── ERRORS.md                      # Bug log & debugging notes
└── docs/
    └── NEXTFLOW_PRINCIPLES.md     # Coding guidelines for this project
```

---

## Output

```
results/
├── preprocessing/         # seqkit stats reports
├── alignment/             # PAF alignment files
├── graph/                 # GFA pangenome graphs (raw & smoothed)
├── analysis/              # ODGI statistics, 1D & 2D visualizations
├── variants/              # VCF files (if --call_variants)
└── pipeline_info/         # Nextflow execution report, timeline, trace, DAG
```

---

## Development

### Coding principles

See [`docs/NEXTFLOW_PRINCIPLES.md`](docs/NEXTFLOW_PRINCIPLES.md) for:
- Module anatomy (process structure)
- Meta map pattern
- Channel rules
- Stub/test conventions
- Pre-push checklist

### Running stub mode

Every module in this pipeline has a `stub:` block — you can run the entire pipeline to validate logic without any bioinformatics tools installed:

```bash
nextflow run main.nf -profile test --stub-run
```

### Tracking progress & errors

- **[`PROGRESS.md`](PROGRESS.md)** — analysis checklist per phase
- **[`ERRORS.md`](ERRORS.md)** — error log with solutions & debugging tips

---

## Tools & References

| Tool | Purpose | Citation |
|------|---------|----------|
| [wfmash](https://github.com/waveygang/wfmash) | All-vs-all alignment | Garrison et al. |
| [seqwish](https://github.com/ekg/seqwish) | Graph induction | Garrison & Guarracino |
| [smoothxg](https://github.com/pangenome/smoothxg) | Graph normalization | — |
| [odgi](https://odgi.readthedocs.io) | Graph analysis & viz | Guarracino et al. |
| [vg](https://github.com/vgteam/vg) | Variant calling | Garrison et al. |

- Garrison et al. (2023). *Building pangenome graphs*. [Nature Methods](https://doi.org/10.1038/s41592-022-01755-1)
- [nf-core/pangenome](https://github.com/nf-core/pangenome)
- [PanSN-spec](https://github.com/pangenome/PanSN-spec)
- [nf-core guidelines](https://nf-co.re/docs/contributing/guidelines)

---

## License

MIT
