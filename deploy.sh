#!/bin/bash
set -ueox pipefail
source .config "$1"
TOOL="$1"
TYPE=$2

N_THREADS="16"
GLOBAL_OPTS="--parallel ${N_THREADS} --threads ${N_THREADS} --mlock --swa-full --kv-unified --flash-attn --keep -1"

TOOL_EXE=""
TOOL_ARGS=""
case "${TOOL}" in
    "cli")
        TOOL_EXE="build/bin/llama-cli"
        ;;
    "server")
        TOOL_EXE="build/bin/llama-server"
        TOOL_ARGS="--host 0.0.0.0"
        ;;
    *)
        echo "unsupported tool" && exit 1
        ;;
esac

# -ngl 0 disables gpu acceleration if necessary
# "${PROVIDER_DIR}/build/bin/llama-cli" --model "${QUANTIZED_MODEL}" -ngl 0
MODEL_ARGS=""

# needs work, parameterize by quantization
case "${TYPE}" in
    "quantized")
        MODEL_ARGS="--model "${QUANTIZED_MODEL}" --ctx-size 32768 --cache-type-k f16 --cache-type-k f16"
        ;;
    "precision")
        MODEL_ARGS="--model "${CONVERTED_MODEL}" --ctx-size 32768 --cache-type-k f16 --cache-type-k f16 --parallel 16"
        ;;
    *)
        echo "unsupported deployment" && exit 1
        ;;
esac

# install vscode extensions
# CONTINUE_PLUGIN_DIR="${HOME}/.continue"
# code --install-extension continue.continue
# code --install-extension ms-toolsai.jupyter
# mkdir -p "${CONTINUE_PLUGIN_DIR}"
# cp -f ./continue.config.yaml "${CONTINUE_PLUGIN_DIR}/config.yaml"

bash -c "${PROVIDER_DIR}/${TOOL_EXE} ${TOOL_ARGS} ${MODEL_ARGS}"