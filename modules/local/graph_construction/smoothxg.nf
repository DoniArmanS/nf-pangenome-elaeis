/*
========================================================================================
    MODULE: SMOOTHXG — Normalisasi / Smoothing Pangenome Graph
    Tool   : smoothxg (https://github.com/pangenome/smoothxg)
    Label  : process_high
========================================================================================
*/

process SMOOTHXG {

    tag "${meta.id}"
    label 'process_high'

    // container 'quay.io/biocontainers/smoothxg:0.7.1--h43eeafb_0'

    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("*smooth.gfa"), emit: gfa
    path "versions.yml",                  emit: versions

    script:
    def prefix     = task.ext.prefix ?: "${meta.id}"
    def args       = task.ext.args   ?: ""
    def poa_length = params.poa_length

    """
    smoothxg \\
        -g ${gfa} \\
        -o ${prefix}.smooth.gfa \\
        -p ${poa_length} \\
        -t ${task.cpus} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        smoothxg: \$(smoothxg --version 2>&1 | head -1)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.smooth.gfa
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        smoothxg: "stub-0.0.0"
    END_VERSIONS
    """
}
