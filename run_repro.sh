#!/bin/bash
set -e

mkdir -p /workspace/results

echo "=========================================================="
echo "PARTIE 1 : Code historique original (original_codebase)"
echo "=========================================================="
cd /workspace/npc_gzip/original_codebase

echo "20News (5-shot, 200 test)..."
python main_text.py --dataset 20News --compressor gzip --num_train 5 --num_test 200 --para > /workspace/results/orig_20News_5shot.log 2>&1

echo "AG_NEWS (5-shot, 500 test)..."
python main_text.py --dataset AG_NEWS --compressor gzip --num_train 5 --num_test 500 --para > /workspace/results/orig_AGNews_${shot}shot.log 2>&1


echo "=========================================================="
echo "PARTIE 2 : Package officiel corrigé (npc_gzip)"
echo "=========================================================="
# python /workspace/compare_official_fix.py > /workspace/results/fixed_official_comparison.log 2>&1

echo "=== Terminé ! Résultats disponibles dans /workspace/results ==="
grep -H "Accuracy" /workspace/results/*.log