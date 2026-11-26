#!/bin/bash
set -euo pipefail

cd /workspace/npc_gzip/original_codebase

mkdir -p /workspace/results

START=$(date +%s)

MODE="${MODE:-pilot}"
NUM_WORKERS="${NUM_WORKERS:-6}"
export NUM_WORKERS

echo "======================================"
echo "       NPC-GZIP REPRODUCTION"
echo "======================================"
echo "Mode: $MODE"
echo "Dataset: DBpedia (custom)"
echo "Data directory: /workspace/data/DBpedia"
echo "Classes: 14"
echo "Number of workers: $NUM_WORKERS"
echo ""

if [ "$MODE" = "pilot" ]; then

    echo "=== PILOT TEST DBpedia ==="
    echo "100 test examples x 560000 training examples"

    OUTPUT_DIR="/workspace/results/dbpedia_pilot"
    mkdir -p "$OUTPUT_DIR"

    python -u main_text.py \
        --dataset custom \
        --data_dir /workspace/data/DBpedia \
        --class_num 14 \
        --compressor gzip \
        --all_train \
        --record \
        --para \
        --test_idx_start 0 \
        --test_idx_end 100 \
        --output_dir "$OUTPUT_DIR" \
        2>&1 | tee /workspace/results/dbpedia_pilot.log

elif [ "$MODE" = "full" ]; then

    echo "=== FULL TEST DBpedia ==="
    echo "70000 test examples x 560000 training examples"

    OUTPUT_DIR="/workspace/results/dbpedia_full"
    mkdir -p "$OUTPUT_DIR"

    python -u main_text.py \
        --dataset custom \
        --data_dir /workspace/data/DBpedia \
        --class_num 14 \
        --compressor gzip \
        --all_train \
        --all_test \
        --record \
        --para \
        --output_dir "$OUTPUT_DIR" \
        2>&1 | tee /workspace/results/dbpedia_full.log

else
    echo "ERROR: MODE must be pilot or full"
    exit 1
fi

END=$(date +%s)
DURATION=$((END - START))

echo ""
echo "======================================"
echo "             RESULTS"
echo "======================================"
echo "Execution time: ${DURATION} seconds"
echo "Execution time: $((DURATION / 60)) minutes"
echo "======================================"
echo "=== END ==="
