# Methods

## 1. Genome Assembly Acquisition

Thirteen *Salmonella enterica* genome assemblies were retrieved from NCBI RefSeq (accessions in `data/accessions.txt`). Assemblies were selected to represent multiple serovars with known or suspected differential susceptibility to STV bacteriophage. All assemblies are in FASTA format (.fna).

---

## 2. Assembly Quality Control

Assembly-level QC metrics were computed for all 13 genomes using a custom R script (`scripts/genome_qc.R`). Metrics calculated include:

- Total genome length (bp)
- Number of sequences (chromosomes + plasmids)
- Largest and smallest sequence length
- N50 and L50
- N90 and L90
- GC content (%)
- Ambiguous base count and percentage (N%)
- Gap detection (runs of ≥10 consecutive N bases)
- Sequence count by size threshold (≥1kb, ≥10kb, ≥1Mb)

Results are output to `results/genome_qc_results.tsv`.

---

## 3. Genome Completeness Assessment (BUSCO)

Genome completeness was assessed using BUSCO v5 against the `bacteria_odb10` lineage dataset (n=124 conserved single-copy orthologs). BUSCO was run in genome mode (`-m genome`) with 4 threads per genome.

**Inclusion threshold:** ≥95% complete BUSCOs

**Results:**

| Category | Count |
|----------|-------|
| Pass (≥95%) | 8 genomes |
| Borderline (93.5%) | 1 genome — GCF_000171515.1, included with flag |
| Fail (<85%) | 4 genomes — excluded from downstream analysis |

**Excluded genomes:**
- GCF_000170255.1 — 69.4% complete
- GCF_000171255.1 — 80.6% complete
- GCF_000171275.1 — 67.7% complete
- GCF_000171315.1 — 67.7% complete

**Borderline genome:**
- GCF_000171515.1 — 93.5% complete. Included in downstream analysis but flagged. Results involving this genome should be interpreted with caution.

BUSCO results were summarized and visualized using `scripts/busco_summary.R`.

---

## 4. Structural Annotation (Bakta)

The 9 genomes passing QC were annotated using Bakta v1.12.0 with the light reference database. Annotation was performed with 4 threads per genome.

```bash
bakta --db bakta_db/db-light --output "bakta_${genome}" --threads 4 "${genome}.fna"
```

Bakta identifies and annotates:
- Coding sequences (CDS) with functional assignment
- Ribosomal RNA genes (5S, 16S, 23S)
- Transfer RNA genes
- Non-coding RNA elements
- Oriention of replication (oriC/oriT)

Output files per genome:
- `.gff3` — genome feature format annotation
- `.gbff` — GenBank flat file format
- `.faa` — annotated protein sequences
- `.ffn` — annotated nucleotide sequences
- `.tsv` — tab-separated annotation table
- `.txt` — annotation summary

---

## 5. Pangenome Analysis (In Progress)

Pangenome analysis will be performed using Roary or Panaroo on the Bakta-annotated GFF3 files from all 9 passing genomes. The pangenome will be partitioned into:

- **Core genome** — genes present in ≥99% of strains
- **Accessory genome** — genes present in <99% of strains
- **Unique genes** — genes present in only one strain

Results will be used to identify surface-exposed proteins and known phage receptors associated with STV susceptibility.

---

## Software and Versions

| Tool | Version | Conda Environment |
|------|---------|------------------|
| BUSCO | 5.x | busco |
| Bakta | 1.12.0 | bakta |
| R | 4.4.1 | base |
| ggplot2 | CRAN latest | base |

All conda environments are reproducible using the `.yml` files in the `environment/` directory.
