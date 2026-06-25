/*
========================================================================================
    WORKFLOW: PANGENOME
    Deskripsi: Workflow utama — orchestrates semua step dari input FASTA sampai output
========================================================================================
*/

// ─── Import Modules ──────────────────────────────────────────────────────────
include { VALIDATE_INPUT         } from '../subworkflows/local/validate_input'
include { PREPROCESSING          } from '../subworkflows/local/preprocessing'
include { GRAPH_CONSTRUCTION     } from '../subworkflows/local/graph_construction'
include { GRAPH_ANALYSIS         } from '../subworkflows/local/graph_analysis'
include { VARIANT_CALLING        } from '../subworkflows/local/variant_calling'

// ─────────────────────────────────────────────────────────────────────────────
workflow PANGENOME_WORKFLOW {

    main:
    // ── Step 0: Validasi input ────────────────────────────────────────────────
    VALIDATE_INPUT()
    ch_fasta = VALIDATE_INPUT.out.fasta   // channel: [ meta, fasta ]

    // ── Step 1: Preprocessing — cek format, nama, panjang sekuens ────────────
    PREPROCESSING(ch_fasta)
    ch_clean_fasta = PREPROCESSING.out.fasta

    // ── Step 2: Konstruksi Pangenome Graph ────────────────────────────────────
    //   wfmash (alignment) → seqwish (induction) → smoothxg (normalisasi)
    GRAPH_CONSTRUCTION(ch_clean_fasta)
    ch_graph = GRAPH_CONSTRUCTION.out.gfa

    // ── Step 3: Analisis Graph ────────────────────────────────────────────────
    //   odgi stats, paths, visualisasi 1D/2D
    GRAPH_ANALYSIS(ch_graph)

    // ── Step 4: Variant Calling (opsional) ───────────────────────────────────
    if (params.call_variants && params.reference) {
        VARIANT_CALLING(ch_graph)
    }

    emit:
    gfa       = ch_graph
    stats     = GRAPH_ANALYSIS.out.stats
}
