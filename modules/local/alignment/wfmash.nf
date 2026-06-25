/*
========================================================================================
    MODULE: WFMASH — All-vs-All Alignment
    Tool   : wfmash (https://github.com/waveygang/wfmash)
    Label  : process_high (komputasi berat)
========================================================================================
*/

process WFMASH {

    tag "${meta.id}"
    label 'process_high'

    // Kalau docker aktif, pakai container ini
    // container 'quay.io/biocontainers/wfmash:0.10.7--h43eeafb_0'

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.paf"), emit: paf
    path "versions.yml",            emit: versions

    script:
    def prefix   = task.ext.prefix ?: "${meta.id}"
    def args     = task.ext.args   ?: ""
    def seg_len  = params.segment_len
    def map_pct  = params.min_map_pct
    def n_hap    = params.n_haplotypes

    """
    wfmash \\
        ${fasta} \\
        -s ${seg_len} \\
        -p ${map_pct} \\
        -n ${n_hap} \\
        -t ${task.cpus} \\
        ${args} \\
        > ${prefix}.paf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wfmash: \$(wfmash --version 2>&1 | head -1)
    END_VERSIONS
    """

    stub:
    // ── DUMMY STUB — untuk testing tanpa install tool ─────────────────────────
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.paf
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wfmash: "stub-0.0.0"
    END_VERSIONS
    """
}
