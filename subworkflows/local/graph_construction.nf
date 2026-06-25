/*
========================================================================================
    SUBWORKFLOW: GRAPH_CONSTRUCTION — Minigraph-Cactus Pipeline
    Hickey et al. (2024) Nature Biotechnology

    Alur:
      1. Buat seqFile dari semua assembly (format Cactus)
      2. Minigraph   → initial structural graph (.gfa)
      3. Cactus      → base-level pangenome graph (.full.gfa)
========================================================================================
*/

include { MINIGRAPH       } from '../../modules/local/graph_construction/minigraph'
include { CACTUS_MINIGRAPH } from '../../modules/local/graph_construction/cactus_minigraph'

workflow GRAPH_CONSTRUCTION {

    take:
    ch_fasta   // [ meta, fasta ] — sudah dipreprocessing

    main:

    // ── Step 1: Tentukan referensi backbone ───────────────────────────────────
    // Referensi = sample dengan params.reference_name (default: sample pertama)
    // atau yang punya N50 tertinggi dari hasil QUAST
    ch_ref = ch_fasta
        .filter { meta, fasta -> meta.id == params.reference_name }
        .first()

    ch_others = ch_fasta
        .filter { meta, fasta -> meta.id != params.reference_name }

    // ── Step 2: Build seqFile untuk Cactus ───────────────────────────────────
    // Format: <sample_name>\t<path_fasta>  (referensi di baris pertama)
    ch_all_fasta = ch_fasta.collect { meta, fasta -> "${meta.id}\t${fasta}" }

    ch_seqfile = ch_all_fasta.map { lines ->
        def content = lines.join('\n')
        def seqfile = file("seqfile.txt")
        seqfile.text = content + '\n'
        return seqfile
    }

    // ── Step 3: Minigraph — initial SV-level graph ────────────────────────────
    ch_assemblies = ch_others.map { meta, fasta -> fasta }.collect()

    ch_minigraph_input = ch_ref.combine(ch_assemblies)
        .map { ref_meta, ref_fasta, other_fastas ->
            def meta = [ id: 'pangenome' ]
            return [ meta, ref_fasta, other_fastas ]
        }

    MINIGRAPH(ch_minigraph_input)

    // ── Step 4: Cactus-Minigraph — base-level graph ───────────────────────────
    ch_cactus_input = ch_seqfile.combine(MINIGRAPH.out.gfa)
        .map { seqfile, meta, gfa ->
            return [ meta, seqfile, gfa ]
        }

    CACTUS_MINIGRAPH(ch_cactus_input)

    emit:
    gfa        = CACTUS_MINIGRAPH.out.gfa       // [ meta, full.gfa ]
    sv_gfa     = CACTUS_MINIGRAPH.out.sv_gfa    // [ meta, sv.gfa ]
    raw_gfa    = MINIGRAPH.out.gfa              // [ meta, minigraph.gfa ]
}
