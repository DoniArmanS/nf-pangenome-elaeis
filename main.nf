#!/usr/bin/env nextflow

/*
========================================================================================
    nf-pangenome-elaeis
========================================================================================
    Nextflow DSL2 pipeline untuk konstruksi pangenome Elaeis guineensis
    menggunakan pendekatan Minigraph-Cactus (Hickey et al. 2024).

    Author  : Doni Arman.S (2303126086)
    Dept    : Informatika, Universitas Mulawarman
========================================================================================
*/

nextflow.enable.dsl = 2

// ─────────────────────────────────────────────────────────────────────────────
// IMPORT WORKFLOWS
// ─────────────────────────────────────────────────────────────────────────────
include { PANGENOME_WORKFLOW } from './workflows/pangenome'

// ─────────────────────────────────────────────────────────────────────────────
// MAIN ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
workflow {

    log.info """
    ╔══════════════════════════════════════════════════════════════════╗
    ║       nf-pangenome-elaeis  |  Elaeis guineensis Pangenome       ║
    ╚══════════════════════════════════════════════════════════════════╝
    Input    : ${params.input}
    Output   : ${params.outdir}
    Mode     : ${params.mode}
    Profile  : ${workflow.profile}
    """.stripIndent()

    PANGENOME_WORKFLOW()
}
