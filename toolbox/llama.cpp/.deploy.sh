#!/bin/bash
set -ueo pipefail

source providers/llama.cpp/.venv/bin/activate

QUANTIZED_MODEL="/home/shree/workspace/world/.models/microsoft/NextCoder-7B/nextcoder-7b-f32.gguf"

"providers/llama.cpp/.source/build/bin/llama-cli" -mli --conversation -p hello -ngl 64 --model "${QUANTIZED_MODEL}" 