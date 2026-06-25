/*
========================================================================================
    SUBWORKFLOW: GRAPH_ANALYSIS
    odgi stats + visualisasi
========================================================================================
*/

include { ODGI_STATS } from '../../modules/local/graph_analysis/odgi'
include { ODGI_VIZ   } from '../../modules/local/graph_analysis/odgi'

workflow GRAPH_ANALYSIS {

    take:
    ch_gfa  // [ meta, gfa ]

    main:

    ODGI_STATS(ch_gfa)
    ODGI_VIZ(ch_gfa)

    emit:
    stats = ODGI_STATS.out.stats
    viz   = ODGI_VIZ.out.png
}
