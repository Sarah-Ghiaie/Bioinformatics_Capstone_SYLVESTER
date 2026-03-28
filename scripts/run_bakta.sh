#!/bin/bash
# Run Bakta annotation on QC-passing genomes only
# Usage: bash scripts/run_bakta.sh
# Run from raw_data directory with bakta environment activated

for f in GCF_000007545.1_ASM754v1_genomic.fna \
          GCF_000020745.1_ASM2074v1_genomic.fna \
          GCF_000020885.1_ASM2088v1_genomic.fna \
          GCF_000020925.1_ASM2092v1_genomic.fna \
          GCF_000022165.1_ASM2216v1_genomic.fna \
          GCF_000170215.1_ASM17021v1_genomic.fna \
          GCF_000171415.1_ASM17141v1_genomic.fna \
          GCF_000171515.1_ASM17151v1_genomic.fna \
          GCF_000171535.2_ASM17153v2_genomic.fna; do
    bakta --db bakta_db/db-light --output "bakta_${f%.fna}" --threads 4 "$f"
done
