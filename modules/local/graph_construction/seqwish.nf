/*
========================================================================================
    MODULE: SEQWISH — Graph Induction dari Alignments
    Tool   : seqwish (https://github.com/ekg/seqwish)
    Label  : process_high
========================================================================================
*/

process SEQWISH {

    tag "${meta.id}"
    label 'process_high'

    // container 'quay.io/biocontainers/seqwish:0.7.9--h43eeafb_0'

    input:
    tuple val(meta), path(fasta), path(paf)

    output:
    tuple val(meta), path("*.gfa"), emit: gfa
    path "versions.yml",            emit: versions

    script:
    def prefix    = task.ext.prefix ?: "${meta.id}"
    def args      = task.ext.args   ?: ""
    def min_match = params.min_match_len

    """
    seqwish \\
        -s ${fasta} \\
        -p ${paf} \\
        -g ${prefix}.gfa \\
        -k ${min_match} \\
        -t ${task.cpus} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqwish: \$(seqwish --version 2>&1 | head -1)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.gfa
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqwish: "stub-0.0.0"
    END_VERSIONS
    """
}
