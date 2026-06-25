/*
========================================================================================
    SUBWORKFLOW: VARIANT_CALLING
    vg deconstruct → VCF output
========================================================================================
*/

include { VG_DECONSTRUCT } from '../../modules/local/variant_calling/vg_deconstruct'

workflow VARIANT_CALLING {

    take:
    ch_gfa  // [ meta, gfa ]

    main:

    if (!params.reference) {
        error "ERROR: --reference diperlukan untuk variant calling"
    }

    ch_ref = Channel.fromPath(params.reference, checkIfExists: true)

    // Gabungkan graph dengan reference
    ch_input = ch_gfa.combine(ch_ref)
    VG_DECONSTRUCT(ch_input)

    emit:
    vcf = VG_DECONSTRUCT.out.vcf
}
