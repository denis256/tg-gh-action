#!/usr/bin/env bash
set -euxo pipefail

export TG_VERSION=${INPUT_TG_VERSION:-latest}
export TF_VERSION=${INPUT_TF_VERSION:-latest}
export TF_COMMAND=${INPUT_TF_COMMAND:-plan}
export TF_DIR=${INPUT_TF_DIR:-/}

tfenv install "${TF_VERSION}"
tgenv install "${TG_VERSION}"

cd "${TF_DIR}"
terragrunt "${TF_COMMAND}"
