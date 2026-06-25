/*
========================================================================================
    SUBWORKFLOW: GRAPH_CONSTRUCTION
    wfmash → seqwish → smoothxg → gfaffix
========================================================================================
*/

include { WFMASH   } from '../../modules/local/alignment/wfmash'
include { SEQWISH  } from '../../modules/local/graph_construction/seqwish'
include { SMOOTHXG } from '../../modules/local/graph_construction/smoothxg'

workflow GRAPH_CONSTRUCTION {

    take:
    ch_fasta  // [ meta, fasta ]

    main:

    // Step 1: All-vs-All Alignment
    WFMASH(ch_fasta)

    // Step 2: Gabungkan FASTA + PAF untuk induction
    ch_fasta_paf = ch_fasta.join(WFMASH.out.paf, by: 0)
    SEQWISH(ch_fasta_paf)

    // Step 3: Normalisasi graph
    SMOOTHXG(SEQWISH.out.gfa)

    emit:
    gfa = SMOOTHXG.out.gfa   // [ meta, gfa ]
    raw_gfa = SEQWISH.out.gfa
}
