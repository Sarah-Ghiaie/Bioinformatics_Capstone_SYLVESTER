# Identifying Host-Cell Receptors on *Salmonella* Serovars Susceptible to STV Bacteriophage Through Pangenome Analysis

**Author:** Sarah Ghiaie  
**Institution:** Utah Valley University  
**Program:** B.S. Bioinformatics  
**Year:** 2026  

---

## Project Overview

This project aims to identify host-cell receptors on *Salmonella* serovars that are susceptible to STV bacteriophage through comparative pangenome analysis. Understanding which surface receptors bacteriophage STV recognizes has implications for phage therapy development and targeted antimicrobial strategies against *Salmonella*.

The workflow integrates genome quality control, structural annotation, and pangenome analysis across 13 *Salmonella enterica* genome assemblies sourced from NCBI RefSeq.

---

## Repository Structure

```
Bioinformatics_Capstone_SYLVESTER/
│
├── README.md                  # Project overview and usage guide
├── METHODS.md                 # Detailed methodology
├── RESULTS.md                 # QC results and findings summary
├── .gitignore                 # Prevents large files from being pushed
│
├── data/
│   └── accessions.txt         # NCBI RefSeq accession numbers for all 13 genomes
│
├── environment/
│   ├── busco_env.yml          # BUSCO conda environment
│   └── bakta_env.yml          # Bakta conda environment
│
├── scripts/
│   ├── genome_qc.R            # Assembly QC metrics (genome size, GC%, N50, etc.)
│   ├── busco_summary.R        # BUSCO completeness visualization
│   └── run_bakta.sh           # Bakta annotation loop script
│
└── results/
    ├── genome_qc_results.tsv  # Assembly QC metrics table
    ├── busco_summary.tsv      # BUSCO completeness scores
    └── figures/               # QC plots and visualizations
```

---

## Data Source and Sequence Generation

13 *Salmonella enterica* genome assemblies were provided as part of a course dataset and sourced from NCBI RefSeq. RefSeq assemblies undergo quality review before inclusion in the database. Sequencing methods vary by assembly but are documented on each assembly's NCBI page using the accessions listed in `data/accessions.txt`. Assemblies are provided in FASTA format (.fna) representing completed or draft whole genome sequences.

---

## Genome Dataset

13 *Salmonella enterica* genome assemblies were downloaded from NCBI RefSeq. Accession numbers are listed in `data/accessions.txt`. Raw `.fna` files are not included in this repository due to file size — they can be downloaded directly from NCBI using the accessions provided.

| Accession | Assembly | BUSCO Score | Status |
|-----------|----------|-------------|--------|
| GCF_000007545.1 | ASM754v1 | 100.0% | ✅ Pass |
| GCF_000020745.1 | ASM2074v1 | 98.4% | ✅ Pass |
| GCF_000020885.1 | ASM2088v1 | 98.4% | ✅ Pass |
| GCF_000020925.1 | ASM2092v1 | 98.4% | ✅ Pass |
| GCF_000022165.1 | ASM2216v1 | 98.4% | ✅ Pass |
| GCF_000170215.1 | ASM17021v1 | 99.2% | ✅ Pass |
| GCF_000170255.1 | ASM17025v1 | 69.4% | ❌ Excluded |
| GCF_000171255.1 | ASM17125v1 | 80.6% | ❌ Excluded |
| GCF_000171275.1 | ASM17127v1 | 67.7% | ❌ Excluded |
| GCF_000171315.1 | ASM17131v1 | 67.7% | ❌ Excluded |
| GCF_000171415.1 | ASM17141v1 | 98.4% | ✅ Pass |
| GCF_000171515.1 | ASM17151v1 | 93.5% | ⚠️ Borderline — included, flagged |
| GCF_000171535.2 | ASM17153v2 | 100.0% | ✅ Pass |

---

## Pipeline Overview

```
Raw Genomes (.fna)
       │
       ▼
Assembly QC (genome_qc.R)
  - Genome size, GC%, N50, contig count
       │
       ▼
Completeness QC (BUSCO v5, bacteria_odb10)
  - Threshold: ≥95% complete
  - 9 genomes pass, 4 excluded
       │
       ▼
Structural Annotation (Bakta)
  - Light database
  - 9 passing genomes annotated
       │
       ▼
Pangenome Analysis (Roary/Panaroo)
  - Core vs accessory genome
       │
       ▼
Phage Receptor Identification
  - STV susceptibility-associated surface proteins
```

---

## How to Reproduce Results

### 1. Clone this repository
```bash
git clone https://github.com/Sarah-Ghiaie/Bioinformatics_Capstone_SYLVESTER.git
cd Bioinformatics_Capstone_SYLVESTER
```

### 2. Download genome assemblies
Download the 13 genome assemblies from NCBI RefSeq using the accessions in `data/accessions.txt`. Place all `.fna` files in a local working directory (e.g. `raw_data/`).

### 3. Set up environments
```bash
conda env create -f environment/busco_env.yml
conda env create -f environment/bakta_env.yml
conda env create -f environment/quast_env.yml
```

### 4. Run assembly QC
```bash
conda activate busco
Rscript scripts/genome_qc.R /path/to/raw_data/
```

### 5. Run BUSCO
```bash
busco --download bacteria_odb10
for f in *.fna; do
    busco -i "$f" -m genome -l bacteria_odb10 -o "busco_${f%.fna}" --download_path busco_downloads -c 4
done
Rscript scripts/busco_summary.R
```

### 6. Run QUAST
```bash
conda activate quast
bash scripts/run_quast.sh
```

### 7. Run Bakta annotation
```bash
conda activate bakta
bash scripts/run_bakta.sh
```

---

## File Naming Conventions and Structure

- Raw genome files follow NCBI RefSeq naming: `GCF_XXXXXXXXX.X_ASMxxxxvX_genomic.fna`
- BUSCO output folders: `busco_GCF_XXXXXXXXX.X_ASMxxxxvX_genomic/`
- Bakta output folders: `bakta_GCF_XXXXXXXXX.X_ASMxxxxvX_genomic/`
- QUAST output: `quast_results/`
- Results files use descriptive names: `genome_qc_results.tsv`, `busco_summary.tsv`
- Figures use descriptive prefixes: `plot_genome_size.png`, `busco_completeness.png`

Raw data files (.fna, BUSCO outputs, Bakta outputs) are stored locally and not included in this repository due to file size. Only processed results, scripts, and documentation are tracked in Git.

---

## Dependencies

| Tool | Version | Purpose |
|------|---------|---------|
| R | 4.4.1 | QC scripting and visualization |
| ggplot2 | CRAN | Plotting |
| BUSCO | 5.x | Genome completeness assessment |
| Bakta | 1.12.0 | Structural annotation |
| QUAST | 4.6.3 | Assembly contiguity and correctness evaluation |
| Roary/Panaroo | TBD | Pangenome analysis |

---

## References

- Manni M, et al. (2021) BUSCO Update: Novel and Streamlined Workflows along with Broader and Deeper Phylogenetic Coverage. *Molecular Biology and Evolution*
- Schwengers O, et al. (2021) Bakta: rapid and standardized annotation of bacterial genomes via a comprehensive database. *Microbial Genomics*
- Page AJ, et al. (2015) Roary: Rapid large-scale prokaryote pan genome analysis. *Bioinformatics*
