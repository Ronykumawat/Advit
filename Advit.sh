#!/bin/bash

# ===============================
# Kraken2 + Bracken + Krona Pipeline
# ===============================
# Auto installs dependencies, runs Kraken2, Bracken, and Krona
# Generates both text reports and plots
# ===============================

# Defaults
THREADS=4
DB_PATH=""
FASTQ_DIR=""
RUN_KRONA=true
RUN_BRACKEN=true
HAVE_DB=""   # yes or no
FASTA_DIR=""
INPUT_TYPE=""

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --threads N          Number of threads (default: 4)"
    echo "  --db PATH            Path to Kraken2 database (required if --have-db yes)"
    echo "  --fastq PATH         Path to folder containing FASTQ files"
    echo "  --fasta PATH         Path to folder containing FASTA files (alternative to --fastq)"
    echo "  --have-db yes|no     Specify if you already have a Kraken2 database"
    echo "  --skip-krona         Skip Krona visualization"
    echo "  --skip-bracken       Skip Bracken abundance estimation"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --threads 8 --have-db yes --db /path/to/db --fastq fastq_files/"
    echo "  $0 --threads 8 --have-db no --fastq fastq_files/"
    exit 0
}

# ===============================
# Parse Arguments
# ===============================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --threads)
            THREADS="$2"
            shift 2
            ;;
        --db)
            DB_PATH="$2"
            shift 2
            ;;
        --fastq)
            FASTQ_DIR="$2"
            INPUT_TYPE="fastq"
            shift 2
            ;;
            --fasta)
            FASTA_DIR="$2"
            INPUT_TYPE="fasta"
            shift 2
            ;;
        --have-db)
            HAVE_DB="$2"
            shift 2
            ;;
        --skip-krona)
            RUN_KRONA=false
            shift
            ;;
        --skip-bracken)
            RUN_BRACKEN=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# ===============================
# Install Tools
# ===============================
check_tools() {
    for tool in kraken2 bracken ktImportTaxonomy; do
        if ! command -v $tool &> /dev/null; then
            echo "$tool not found. Installing via conda/mamba..."
            if command -v mamba &> /dev/null; then
                mamba install -y -c bioconda -c conda-forge kraken2 bracken krona
            elif command -v conda &> /dev/null; then
                conda install -y -c bioconda -c conda-forge kraken2 bracken krona
            else
                echo "Error: Neither conda nor mamba found. Please install one of them first."
                exit 1
            fi
            break
        fi
    done
}

# ===============================
# Setup Database
# ===============================
setup_database() {
    if [[ "$HAVE_DB" == "yes" ]]; then
        if [[ -z "$DB_PATH" ]]; then
            echo "Error: You must provide --db PATH when using --have-db yes"
            exit 1
        fi
        if [ ! -d "$DB_PATH" ]; then
            echo "Error: Database path $DB_PATH not found!"
            exit 1
        fi
    elif [[ "$HAVE_DB" == "no" ]]; then
        echo "Which database do you want to download?"
        echo "1) Full (~70 GB)"
        echo "2) Smaller (~5.5 GB)"
        read choice

        if [[ "$choice" == "1" ]]; then
            DB_URL="https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20250714.tar.gz"
        elif [[ "$choice" == "2" ]]; then
            DB_URL="https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08_GB_20250714.tar.gz"
        else
            echo "Invalid choice. Exiting."
            exit 1
        fi

        echo "Downloading database with $THREADS threads..."
        mkdir -p Database_kraken
        aria2c --check-certificate=false -x 10 -s "$THREADS" -d Database_kraken -o db.tar.gz "$DB_URL"

        echo "Extracting database..."
        tar -xvzf Database_kraken/db.tar.gz -C Database_kraken
        #rm Database_kraken/db.tar.gz
        DB_PATH="Database_kraken"
        echo "Database ready at $DB_PATH"
    else
        echo "Error: You must specify --have-db yes|no"
        exit 1
    fi
}

# ===============================
# Run Kraken2 + Bracken + Krona
# ===============================
run_pipeline() {
    if [[ "$INPUT_TYPE" == "fastq" ]]; then
        if [[ -z "$FASTQ_DIR" ]]; then
            echo "Error: You must provide --fastq PATH"
            exit 1
        fi

        if [ ! -d "$FASTQ_DIR" ]; then
            echo "Error: FASTQ folder not found!"
            exit 1
        fi

        mkdir -p results/kraken2 reports/bracken reports/krona

        for R1 in "$FASTQ_DIR"/*_R1_*.fq; do
            SAMPLE=$(basename "$R1" | sed 's/_R1.*.fq//')
            R2="${FASTQ_DIR}/${SAMPLE}_R2_val_2.fq"

            if [ ! -f "$R2" ]; then
                echo "Warning: Paired file for $SAMPLE not found. Skipping."
                continue
            fi

            echo "Running Kraken2 on sample $SAMPLE..."
            kraken2 --db "$DB_PATH" \
                --threads $THREADS \
                --paired "$R1" "$R2" \
                --report results/kraken2/${SAMPLE}.kreport \
                --output results/kraken2/${SAMPLE}.kraken

            if $RUN_BRACKEN; then
                echo "Running Bracken on $SAMPLE..."
                bracken -d "$DB_PATH" \
                    -i results/kraken2/${SAMPLE}.kreport \
                    -o reports/bracken/${SAMPLE}.bracken \
                    -r 150 -l S
            fi

            if $RUN_KRONA; then
                echo "Generating Krona plot for $SAMPLE..."
                ktImportTaxonomy results/kraken2/${SAMPLE}.kraken \
                    -o reports/krona/${SAMPLE}.html
            fi
        done

    elif [[ "$INPUT_TYPE" == "fasta" ]]; then
        if [[ -z "$FASTA_DIR" ]]; then
            echo "Error: You must provide --fasta PATH"
            exit 1
        fi

        if [ ! -d "$FASTA_DIR" ]; then
            echo "Error: FASTA folder not found!"
            exit 1
        fi

        mkdir -p results/kraken2 reports/bracken reports/krona

        for FILE in "$FASTA_DIR"/*.fasta "$FASTA_DIR"/*.fa; do
            [ -e "$FILE" ] || continue
            SAMPLE=$(basename "$FILE" | sed 's/\..*//')

            echo "Running Kraken2 on FASTA sample $SAMPLE..."
            kraken2 --db "$DB_PATH" \
                --threads $THREADS \
                --fasta-input "$FILE" \
                --report results/kraken2/${SAMPLE}.kreport \
                --output results/kraken2/${SAMPLE}.kraken

            if $RUN_BRACKEN; then
                echo "Running Bracken on $SAMPLE..."
                bracken -d "$DB_PATH" \
                    -i results/kraken2/${SAMPLE}.kreport \
                    -o reports/bracken/${SAMPLE}.bracken \
                    -r 150 -l S
            fi

            if $RUN_KRONA; then
                echo "Generating Krona plot for $SAMPLE..."
                ktImportTaxonomy results/kraken2/${SAMPLE}.kraken \
                    -o reports/krona/${SAMPLE}.html
            fi
        done

    else
        echo "Error: Please specify either --fastq or --fasta input"
        exit 1
    fi

    echo "Pipeline complete. Results in results/, reports/."
}


# ===============================
# Plotting Script Generator
# ===============================
make_plot_script() {
cat << 'EOF' > plot_bracken.py
import os
import pandas as pd
import matplotlib.pyplot as plt

# Folder containing bracken reports
folder = "reports/bracken"
files = [f for f in os.listdir(folder) if f.endswith(".bracken")]

all_data = []
for file in files:
    sample = file.replace(".bracken", "")
    df = pd.read_csv(os.path.join(folder, file), sep="\t")
    df = df[df["taxonomy_lvl"] == "S"].copy()
    df = df.sort_values(by="new_est_reads", ascending=False).head(10)
    df["sample"] = sample
    all_data.append(df)

df_all = pd.concat(all_data)

pivot = df_all.pivot(index="name", columns="sample", values="new_est_reads").fillna(0)

pivot.T.plot(kind="bar", stacked=True, figsize=(12, 7))
plt.ylabel("Reads (Bracken estimated)")
plt.title("Species Abundance Across Samples (Bracken)")
plt.tight_layout()
plt.savefig("reports/bracken/species_stacked_bar.png", dpi=300)
plt.show()
EOF
    echo "Plotting script saved as plot_bracken.py"
    echo "Run it with: python plot_bracken.py"
}

# ===============================
# Main
# ===============================
check_tools
setup_database
run_pipeline
make_plot_script

