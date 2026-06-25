/*
========================================================================================
    SUBWORKFLOW: VALIDATE_INPUT
    Validasi input: samplesheet CSV atau file FASTA tunggal
========================================================================================
*/

workflow VALIDATE_INPUT {

    main:

    // ── Mode 1: Input adalah CSV samplesheet ──────────────────────────────────
    if (params.input.endsWith('.csv')) {
        Channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header: true)
            .map { row ->
                def meta = [ id: row.sample, assembler: row.assembler ?: 'unknown' ]
                def fasta = file(row.fasta, checkIfExists: true)
                return [ meta, fasta ]
            }
            .set { ch_fasta }

    // ── Mode 2: Input adalah FASTA langsung ───────────────────────────────────
    } else {
        Channel
            .fromPath(params.input, checkIfExists: true)
            .map { fasta ->
                def meta = [ id: fasta.baseName ]
                return [ meta, fasta ]
            }
            .set { ch_fasta }
    }

    emit:
    fasta = ch_fasta   // [ meta, fasta ]
}
