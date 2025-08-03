#!/bin/bash
set -ueox pipefail
THIS_DIR="$(dirname ${0})"
source "${THIS_DIR}/.config"
for MODEL in "${MODELS[@]}"; do
  bash "${PWD}/${THIS_DIR}/one.sh" "${MODEL}"
done