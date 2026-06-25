#!/usr/bin/env nextflow

/*
========================================================================================
    nf-pangenome-elaise
========================================================================================
    Pengembangan Pipeline Pangenome Berbasis Nextflow untuk Analisis Variasi Struktural
    pada Elaeis guineensis (Kelapa Sawit)

    Author  : Doni Arman.S (2303126086)
    Advisor : [Nama Pembimbing]
    Dept    : Informatika — Universitas Mulawarman
========================================================================================
*/

nextflow.enable.dsl = 2

// ─────────────────────────────────────────────────────────────────────────────
// BANNER
// ─────────────────────────────────────────────────────────────────────────────
def printBanner() {
    log.info """
    ╔══════════════════════════════════════════════════════════════════╗
    ║       nf-pangenome-elaise  |  Elaeis guineensis Pangenome       ║
    ╚══════════════════════════════════════════════════════════════════╝
    Input FASTA   : ${params.input}
    Output Dir    : ${params.outdir}
    Mode          : ${params.mode}
    Profile       : ${workflow.profile}
    """.stripIndent()
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPORT WORKFLOWS
// ─────────────────────────────────────────────────────────────────────────────
include { PANGENOME_WORKFLOW } from './workflows/pangenome'

// ─────────────────────────────────────────────────────────────────────────────
// MAIN ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
workflow {
    printBanner()
    PANGENOME_WORKFLOW()
}

// ─────────────────────────────────────────────────────────────────────────────
// ON COMPLETE
// ─────────────────────────────────────────────────────────────────────────────
workflow.onComplete {
    log.info ( workflow.success
        ? "\n✅ Pipeline selesai! Hasil ada di: ${params.outdir}"
        : "\n❌ Pipeline GAGAL — cek log di: ${workflow.launchDir}/.nextflow.log"
    )
}
