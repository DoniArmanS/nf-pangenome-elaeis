#!/usr/bin/env nextflow

/*
========================================================================================
    nf-pangenome-elaise
========================================================================================
    Nextflow DSL2 pipeline for Elaeis guineensis pangenome construction
    and structural variant analysis using the PGGB approach.

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
    ║       nf-pangenome-elaise  |  Elaeis guineensis Pangenome       ║
    ╚══════════════════════════════════════════════════════════════════╝
    Input    : ${params.input}
    Output   : ${params.outdir}
    Mode     : ${params.mode}
    Profile  : ${workflow.profile}
    """.stripIndent()

    PANGENOME_WORKFLOW()
}
