# bam-to-fastq

This repository provides a **BAM processing pipeline** for the bam files that include other things alongside the primary chromosomes. The script enables the conversion of filtered BAM file to FASTQ for the downstream analyses.

## 📂 Overview  

The script processes BAM files by:  

✅ Filtering to keep only primary chromosomes  

✅ Sorting BAM files

✅ Removing secondary alignments, unmapped reads, and supplementary

✅ Removing duplicates using Picard

✅ Indexing BAM files

✅ Converting processed BAMs to FASTQ  

---

## Usage Instructions  

### 1️⃣ **Clone the Repository & Navigate to It**  
Download the repository to your local machine:  
```bash
git clone https://github.com/Atakannl/bam-to-fastq.git
cd bam-to-fastq 
```
### 2️⃣ **Install required dependencies**
```bash
sudo apt update && sudo apt install -y samtools==1.9 picard==2.20
```
### 3️⃣ **Prepare your sample list**
Prepare a txt sample list that includes the name for the corresponding bam file. You can check the example sample list in the repo.

### 4️⃣ **Run the script**
```bash
bash bam_to_fq.sh samples_to_process.txt
```
