/*
========================================================================================
    SUBWORKFLOW: VARIANT_CALLING
    vg deconstruct → VCF output

    Dipanggil hanya jika: params.call_variants = true DAN params.reference_name diisi.
    Kontrol dari nextflow.config, tidak perlu mengubah file ini.
========================================================================================
*/

include { VG_DECONSTRUCT } from '../../modules/local/variant_calling/vg_deconstruct'

workflow VARIANT_CALLING {

    take:
    ch_gfa  // [ meta, gfa ]

    main:

    // Cek reference_name terdefinisi (WAJIB untuk vg deconstruct)
    if (!params.reference_name) {
        error "ERROR: params.reference_name diperlukan untuk variant calling. Isi di nextflow.config."
    }

    // Ambil FASTA referensi dari channel input berdasarkan reference_name
    // (reference sudah ada di ch_gfa sebagai bagian dari graph yang dibangun dari referensi)
    ch_input = ch_gfa

    VG_DECONSTRUCT(ch_input)

    emit:
    vcf = VG_DECONSTRUCT.out.vcf
}
