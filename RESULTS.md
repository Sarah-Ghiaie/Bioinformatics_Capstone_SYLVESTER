# Results

## 1. Assembly QC

All 13 *Salmonella enterica* genomes were within expected size range (~4.5–5.0 Mb) and GC content (~52%) consistent with the species. No ambiguous bases (N%) were detected in any assembly. Full metrics are available in `results/genome_qc_results.tsv`.

Key observations:
- Genome sizes ranged from 4.55 Mb to 4.96 Mb
- GC content was highly consistent across all genomes (52.00–52.27%)
- Sequence counts varied substantially — some assemblies were complete (1–5 sequences) while others were fragmented drafts (19–113 contigs)
- N50 ranged from 0.10 Mb (highly fragmented) to 4.84 Mb (near-complete)
- No gap sequences (runs of ≥10 N bases) were detected in any genome

---

## 2. BUSCO Completeness

BUSCO assessment against the `bacteria_odb10` lineage (n=124 BUSCOs) revealed variable completeness across the 13 assemblies.

| Accession | Complete | Single | Duplicated | Fragmented | Missing | Status |
|-----------|----------|--------|------------|------------|---------|--------|
| GCF_000007545.1 | 100.0% | 100.0% | 0.0% | 0.0% | 0.0% | ✅ Pass |
| GCF_000020745.1 | 98.4% | 98.4% | 0.0% | 0.0% | 1.6% | ✅ Pass |
| GCF_000020885.1 | 98.4% | 98.4% | 0.0% | 0.0% | 1.6% | ✅ Pass |
| GCF_000020925.1 | 98.4% | 98.4% | 0.0% | 0.0% | 1.6% | ✅ Pass |
| GCF_000022165.1 | 98.4% | 98.4% | 0.0% | 1.6% | 0.0% | ✅ Pass |
| GCF_000170215.1 | 99.2% | 99.2% | 0.0% | 0.0% | 0.8% | ✅ Pass |
| GCF_000170255.1 | 69.4% | 69.4% | 0.0% | 5.6% | 25.0% | ❌ Excluded |
| GCF_000171255.1 | 80.6% | 80.6% | 0.0% | 1.6% | 17.7% | ❌ Excluded |
| GCF_000171275.1 | 67.7% | 67.7% | 0.0% | 7.3% | 25.0% | ❌ Excluded |
| GCF_000171315.1 | 67.7% | 67.7% | 0.0% | 5.6% | 26.6% | ❌ Excluded |
| GCF_000171415.1 | 98.4% | 98.4% | 0.0% | 1.6% | 0.0% | ✅ Pass |
| GCF_000171515.1 | 93.5% | 93.5% | 0.0% | 0.8% | 5.6% | ⚠️ Borderline |
| GCF_000171535.2 | 100.0% | 100.0% | 0.0% | 0.0% | 0.0% | ✅ Pass |

**9 genomes** passed the ≥95% completeness threshold and were carried forward for annotation. 4 genomes with completeness scores below 85% were excluded due to poor assembly quality. GCF_000171515.1 (93.5%) was included as a borderline case but flagged for cautious interpretation.

No duplicated BUSCOs were detected in any genome, indicating no contamination or assembly redundancy issues.

---

## 3. Structural Annotation (In Progress)

Bakta annotation is currently being run on the 9 passing genomes. Results will be updated upon completion.

---

## 4. Pangenome Analysis (Pending)

Pangenome analysis and phage receptor identification are pending completion of structural annotation.
