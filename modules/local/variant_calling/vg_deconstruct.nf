/*
========================================================================================
    MODULE: VG_DECONSTRUCT — Variant Calling dari Pangenome Graph
    Tool   : vg deconstruct (https://github.com/vgteam/vg)
    Label  : process_high
========================================================================================
*/

process VG_DECONSTRUCT {

    tag "${meta.id}"
    label 'process_high'

    // container 'quay.io/biocontainers/vg:1.54.0--h607a9b5_0'

    input:
    tuple val(meta), path(gfa), path(reference)

    output:
    tuple val(meta), path("*.vcf.gz"),     emit: vcf
    tuple val(meta), path("*.vcf.gz.tbi"), emit: tbi
    path "versions.yml",                   emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args   = task.ext.args   ?: ""

    """
    # Konversi GFA ke vg format
    vg convert -g ${gfa} -p > ${prefix}.vg

    # Deconstruct variants relatif ke reference
    vg deconstruct \\
        -p ${reference.baseName} \\
        -a ${args} \\
        ${prefix}.vg \\
        | bgzip > ${prefix}.vcf.gz

    tabix -p vcf ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | grep -oP 'v[0-9.]+')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz ${prefix}.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: "stub-0.0.0"
    END_VERSIONS
    """
}
