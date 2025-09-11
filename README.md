Advait

A streamlined pipeline for Kraken2 + Bracken + Krona analysis of metagenomic data.

Advait automates the installation of dependencies, database setup, taxonomic classification, abundance estimation, and interactive visualization. It also generates summary plots for species-level abundance across samples.

✨ Features

Automated installation of Kraken2, Bracken, and Krona

Database management (download or use existing)

Supports paired-end FASTQ files

Species abundance estimation with Bracken

Interactive taxonomic visualization with Krona

Auto-generates stacked bar plots for top 10 species

⚠️ Important Notes

Always prefer downloading the Kraken2 large (standard) database for best results.

Before running Advait, install aria2:

pip install aria2

🔧 Installation

Clone this repository and make the script executable:

git clone https://github.com/Ronykumawat/Advit.git
cd Advait
chmod +x Advait

🚀 Usage

Run the pipeline using:

./Advait [options]

Options
Option	Description
--threads N	Number of threads (default: 4)
--db PATH	Path to Kraken2 database (required if --have-db yes)
--fastq PATH	Path to folder containing FASTQ files
`--have-db yes	no`
--skip-krona	Skip Krona visualization
--skip-bracken	Skip Bracken abundance estimation
-h, --help	Show help message
Example Commands

Using an existing database:

./Advait --threads 8 --have-db yes --db /path/to/db --fastq fastq_files/


Downloading and using the database:

./Advait --threads 8 --have-db no --fastq fastq_files/

📊 Outputs

Kraken2 reports → results/kraken2/

Bracken abundance tables → reports/bracken/

Krona interactive plots (HTML) → reports/krona/

Stacked bar plots of top species → reports/bracken/species_stacked_bar.png

📈 Extra Plotting

A script plot_bracken.py is automatically generated for visualization:

python plot_bracken.py


This creates a stacked bar plot of top 10 species per sample.

🛠 Requirements

Linux / macOS

Conda or Mamba

Tools: kraken2, bracken, krona (installed automatically)

Python 3 with pandas and matplotlib

📜 License

MIT License – feel free to use and modify.
