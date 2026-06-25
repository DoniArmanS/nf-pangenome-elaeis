/*
========================================================================================
    MODULE: ODGI_STATS — Statistik Pangenome Graph
    Tool   : odgi stats (https://odgi.readthedocs.io)
    Label  : process_medium
========================================================================================
*/

process ODGI_STATS {

    tag "${meta.id}"
    label 'process_medium'

    // container 'quay.io/biocontainers/odgi:0.8.3--py310h6cc9453_0'

    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("*.stats.yaml"), emit: stats
    path "versions.yml",                   emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    # Convert GFA → ODGI binary format
    odgi build -g ${gfa} -o ${prefix}.og -t ${task.cpus}

    # Hitung statistik dasar
    odgi stats -i ${prefix}.og -S -y > ${prefix}.stats.yaml

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        odgi: \$(odgi --version 2>&1 | head -1)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "length: 0\\nnodes: 0\\nedges: 0\\npaths: 0" > ${prefix}.stats.yaml
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        odgi: "stub-0.0.0"
    END_VERSIONS
    """
}

/*
========================================================================================
    MODULE: ODGI_VIZ — Visualisasi 1D Layout
========================================================================================
*/

process ODGI_VIZ {

    tag "${meta.id}"
    label 'process_medium'

    // container 'quay.io/biocontainers/odgi:0.8.3--py310h6cc9453_0'

    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("*.png"), emit: png
    path "versions.yml",            emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    odgi build -g ${gfa} -o ${prefix}.og -t ${task.cpus}
    odgi sort  -i ${prefix}.og -o ${prefix}.sorted.og -t ${task.cpus}
    odgi viz   -i ${prefix}.sorted.og -o ${prefix}.1D.png -x 1500 -y 500

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        odgi: \$(odgi --version 2>&1 | head -1)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.1D.png
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        odgi: "stub-0.0.0"
    END_VERSIONS
    """
}
