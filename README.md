A cross-platform and automated pipeline for **metagenomic classification and visualization** using **Kraken2, Bracken, and Krona**.  

# Advit  
A cross-platform and automated pipeline for **metagenomic classification and visualization** using **Kraken2, Bracken, and Krona**.  

---

## ✨ Features
- **Easy to install**: statically managed via conda/mamba, no compilation required  
- **Automated pipeline**: runs **Kraken2 + Bracken + Krona** end-to-end  
- **Database management**:  
  - Option to use an existing Kraken2 database  
  - Automated download of Kraken2 standard databases (⚠️ always prefer the **large/standard database**)  
- **FASTQ and FASTA input support**: handles paired-end FASTQ files
- **Species-level abundance**: integrates Bracken for accurate read assignment  
- **Interactive visualization**: generates Krona plots (HTML)  
- **Custom plotting**: auto-creates Python script for stacked bar plots  

---

# Advit  
A cross-platform and automated pipeline for **metagenomic classification and visualization** using **Kraken2, Bracken, and Krona**.  

---

## 📦 Installation  

### Method 1: Clone GitHub repository  
```bash
git clone https://github.com/Ronykumawat/Advit.git
cd Advit
chmod +x Advit.sh
```

Method 2: Install requirements

.Install conda or mamba
.Install aria2 before running:
```bash
pip install aria2
```
---
🚀 Usage
Run Advit directly:
```bash
./Advit [options]
```
| Option           | Description                                            |                                                |
| ---------------- | ------------------------------------------------------ | ---------------------------------------------- |
| `--threads N`    | Number of threads (default: 4)                         |                                                |
| `--db PATH`      | Path to Kraken2 database (required if `--have-db yes`) |                                                |
| `--fastq PATH`   | Path to folder containing FASTQ files                  |                                                |
| `--fasta PATH`   | Path to folder containing FASTA files                  |                                                |
| `--have-db yes no\`| Specify if you already have a Kraken2 database       |                                                |
| `--skip-krona`   | Skip Krona visualization                               |                                                |
| `--bracken-level L`   | Taxonomic level for Bracken -l (e.g. S, G, P, etc.)|                                               |
| `--skip-bracken` | Skip Bracken abundance estimation                      |                                                |
| `-h, --help`     | Show help message                                      |                                                |

---

📂 Example Commands

1. Using an existing database
```bash
  ./Advit.sh --threads 8 --have-db yes --db /path/to/db --fastq fastq_files/ --bracken-level G
```
2. Downloading the standard (large) database
```bash
./Advit --threads 8 --have-db no --fastq fastq_files/
```
📊 Outputs

.Kraken2 reports → results/kraken2/
.Bracken tables → reports/bracken/
.Krona interactive HTML plots → reports/krona/
.Stacked bar plots of top 10 species → reports/bracken/species_stacked_bar.png

📈 Plotting

Advit automatically generates a script for species abundance visualization:
```bash
python plot_bracken.py
```

🔧 Subcommands / Pipeline Steps
| Step                 | Tool                | Function                            |
| -------------------- | ------------------- | ----------------------------------- |
| Classification       | Kraken2             | Taxonomic classification of reads   |
| Abundance estimation | Bracken             | Species-level read reassignment     |
| Visualization        | Krona               | Interactive taxonomic visualization |
| Plotting             | Matplotlib + Pandas | Stacked bar plots across samples    |

📖 Citation

If you use Advit in your work, please cite:

Dr. Jitendra Narayan, Rounak Kumawat. Advit: An automated Kraken2 + Bracken + Krona pipeline for metagenomic classification and visualization. 2025.

👩‍💻 Contributors

.Dr. Jitendra Narayan

.Rounak Kumawat

🙏 Acknowledgements

.Kraken2 team for their ultrafast classification tool
.Bracken developers for accurate species abundance estimation
.Krona developers for interactive hierarchical visualization
.The open-source bioinformatics community

📜 License

Advit is released under the MIT License.

