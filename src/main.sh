#!/usr/bin/env bash
set -e

[[ "${TRACE}" ]] && set -x

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
  local -r command=($2)

  cd "${dir}"
  terragrunt "${command[@]}"
}

function main {
  local -r tf_version=${INPUT_TF_VERSION:-latest}
  local -r tg_version=${INPUT_TG_VERSION:-latest}
  local -r tg_command=${INPUT_TG_COMMAND:-plan}
  local -r tg_dir=${INPUT_TG_DIR:-.}

  install_terraform "${tf_version}"
  install_terragrunt "${tg_version}"

  # add auto approve for apply and destroy commands
  if [[ "${tg_command[*]}" =~ ^(apply|destroy|run-all[[:space:]]*apply|run-all[[:space:]]*destroy) ]]; then
    local -r apply_or_destroy="true"
  else
    local -r apply_or_destroy="false"
  fi
  local -r tg_arg_and_commands=$(( apply_or_destroy == "true" ? "${tg_command[*]} -auto-approve --terragrunt-non-interactive " : "${tg_command[*]}" ))
  run_terragrunt "${tg_dir}" "${tg_arg_and_commands}"
}

main "$@"
