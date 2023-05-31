#!/usr/bin/env bash
set -e

readonly TF_VERSION=${INPUT_TF_VERSION:-latest}
readonly TG_VERSION=${INPUT_TG_VERSION:-latest}
readonly TG_COMMAND=${INPUT_TG_COMMAND:-plan}
readonly TG_DIR=${INPUT_TG_DIR:-.}

function install_terraform {
  local -r version="$1"
  if [[ "${version}" == "none" ]]; then
    return
  fi
  tfenv install "${version}"
  tfenv use "${version}"
}

function install_terragrunt {
  local -r version="$1"
  if [[ "${version}" == "none" ]]; then
    return
  fi
  tgenv install "${version}"
  tgenv use "${version}"
}

function run_terragrunt {
  local -r dir="$1"
  local -r command="$1"

  cd "${dir}"
  terragrunt "${command}"
}

function main {
  install_terraform "${TF_VERSION}"
  install_terragrunt "${TG_VERSION}"

  run_terragrunt "${TG_DIR}" "${TG_COMMAND}"
}

main "$@"
