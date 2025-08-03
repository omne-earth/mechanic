#!/bin/bash
set -ueo pipefail
# source .config "$1"

# f32, f16, bf16, q8_0, tq1_0, tq2_0, auto
CONVERSION_TENSOR="f32"
MODEL_DIR="/home/shree/workspace/world/.models/microsoft/NextCoder-7B"


source providers/llama.cpp/.venv/bin/activate


CONVERTED_MODEL="/home/shree/workspace/world/.models/microsoft/NextCoder-7B/nextcoder-7b-f32.gguf"

rm -rf "${CONVERTED_MODEL}"
python "providers/llama.cpp/.source/convert_hf_to_gguf.py" "${MODEL_DIR}" --outtype "${CONVERSION_TENSOR}" --outfile "${CONVERTED_MODEL}"
deactivate
