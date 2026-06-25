#!/usr/bin/env bash
# =============================================================================
# extract_core_var.sh
# =============================================================================
# Bash script untuk mengekstraksi core sequences dan variable sequences
# dari pangenome graph odgi/GFA.
#
# Sesuai proposal:
#   - Core sequences    = path yang ada di SEMUA individu/assembly
#   - Variable sequences = path yang hanya ada di SEBAGIAN individu
#
# Penggunaan:
#   extract_core_var.sh <graph.og> <n_samples> <output_prefix>
#
# Contoh:
#   extract_core_var.sh pangenome.og 5 pangenome
#
# Output:
#   {prefix}_core_sequences.txt      — path/node core
#   {prefix}_variable_sequences.txt  — path/node variabel
#   {prefix}_pangenome_summary.tsv   — ringkasan statistik
# =============================================================================

set -euo pipefail

# ── Argumen ──────────────────────────────────────────────────────────────────
GRAPH_OG="${1:?Usage: $0 <graph.og> <n_samples> <output_prefix>}"
N_SAMPLES="${2:?Missing n_samples argument}"
OUT_PREFIX="${3:?Missing output_prefix argument}"

echo "=============================================="
echo "  Pangenome Core & Variable Sequence Extractor"
echo "=============================================="
echo "  Graph     : ${GRAPH_OG}"
echo "  N samples : ${N_SAMPLES}"
echo "  Output    : ${OUT_PREFIX}_*.txt"
echo "----------------------------------------------"

# ── Cek tools ─────────────────────────────────────────────────────────────────
for tool in odgi; do
    if ! command -v "${tool}" &>/dev/null; then
        echo "ERROR: '${tool}' tidak ditemukan di PATH" >&2
        exit 1
    fi
done

# ── Step 1: Dapatkan daftar semua path dalam graph ─────────────────────────
echo "[1/4] Mengambil daftar path dari graph..."
odgi paths -i "${GRAPH_OG}" -L > "${OUT_PREFIX}_all_paths.txt"
TOTAL_PATHS=$(wc -l < "${OUT_PREFIX}_all_paths.txt")
echo "      Total path: ${TOTAL_PATHS}"

# ── Step 2: Hitung coverage setiap path (ada di berapa sample) ──────────────
# Gunakan odgi paths -D untuk mendapat info depth per path
echo "[2/4] Menghitung coverage per path..."
odgi paths -i "${GRAPH_OG}" -D '\t' > "${OUT_PREFIX}_path_coverage.tsv"

# ── Step 3: Klasifikasikan core vs variable ───────────────────────────────
echo "[3/4] Mengklasifikasikan core vs variable sequences..."

# Core = path yang muncul di semua N_SAMPLES individu
# Pendekatan: ekstrak nama sample dari path name (PanSN-spec: sample#hap#seq)
# kemudian hitung berapa unique sample yang punya tiap segment

# Ekstrak unique sample per node menggunakan odgi view + awk
odgi view -i "${GRAPH_OG}" -g | \
    awk -v n="${N_SAMPLES}" '
    BEGIN { print "path\tsamples_count\ttype" }
    /^P/ {
        split($2, parts, "#")
        sample = parts[1]
        path_samples[$2][sample] = 1
    }
    END {
        for (path in path_samples) {
            count = 0
            for (s in path_samples[path]) count++
            type = (count == n) ? "core" : "variable"
            print path "\t" count "\t" type
        }
    }
' > "${OUT_PREFIX}_path_classification.tsv"

# Pisahkan core dan variable
awk -F'\t' '$3 == "core" {print $1}' "${OUT_PREFIX}_path_classification.tsv" \
    > "${OUT_PREFIX}_core_sequences.txt"

awk -F'\t' '$3 == "variable" {print $1}' "${OUT_PREFIX}_path_classification.tsv" \
    > "${OUT_PREFIX}_variable_sequences.txt"

N_CORE=$(wc -l < "${OUT_PREFIX}_core_sequences.txt")
N_VAR=$(wc -l < "${OUT_PREFIX}_variable_sequences.txt")

# ── Step 4: Buat summary TSV ─────────────────────────────────────────────────
echo "[4/4] Membuat laporan statistik..."

cat > "${OUT_PREFIX}_pangenome_summary.tsv" << EOF
metric	value
graph_file	${GRAPH_OG}
n_samples	${N_SAMPLES}
total_paths	${TOTAL_PATHS}
core_sequences	${N_CORE}
variable_sequences	${N_VAR}
core_pct	$(awk "BEGIN {printf \"%.2f\", ${N_CORE}/${TOTAL_PATHS}*100}")
variable_pct	$(awk "BEGIN {printf \"%.2f\", ${N_VAR}/${TOTAL_PATHS}*100}")
EOF

# ── Tampilkan ringkasan ──────────────────────────────────────────────────────
echo ""
echo "=============================================="
echo "  HASIL"
echo "----------------------------------------------"
echo "  Total path      : ${TOTAL_PATHS}"
echo "  Core sequences  : ${N_CORE}"
echo "  Var. sequences  : ${N_VAR}"
echo ""
echo "  Output files:"
echo "    ${OUT_PREFIX}_core_sequences.txt"
echo "    ${OUT_PREFIX}_variable_sequences.txt"
echo "    ${OUT_PREFIX}_pangenome_summary.tsv"
echo "=============================================="
