#!/usr/bin/env bash
set -euxo pipefail

export TG_VERSION=${INPUT_TG_VERSION:-latest}
export TF_VERSION=${INPUT_TF_VERSION:-latest}
export TG_COMMAND=${INPUT_TG_COMMAND:-plan}
export TG_DIR=${INPUT_TG_DIR:-/}

tfenv install "${TF_VERSION}"
tfenv use "${TF_VERSION}"

tgenv install "${TG_VERSION}"
tgenv use "${TG_VERSION}"

cd "${TG_DIR}"
terragrunt "${TG_COMMAND}"
