#!/bin/bash
set -ueo pipefail
THIS_DIR="$(dirname ${0})"
source "${THIS_DIR}/.config"
mkdir -p "${MODELS_DIR}/${1}"
git clone "https://${PLATFORM_USER}:${PLATFORM_TOKEN}@${PLATFORM_DOMAIN}/${1}" "${MODELS_DIR}/${1}" || true
