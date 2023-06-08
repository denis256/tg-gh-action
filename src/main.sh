#!/usr/bin/env bash
set -e

[[ "${TRACE}" ]] && set -x

function log {
  local -r message="$1"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} ${message}"
}

function clean_colors {
  local -r input="$1"
  echo "${input}" | sed -E 's/\x1B\[[0-9;]*[mGK]//g'
}

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
  TG_VERSION="${version}" tgswitch
}

function run_terragrunt {
  local -r dir="$1"
  local -r command=($2)

  # terragrunt_log_file can be used later as file with execution output
  terragrunt_log_file=$(mktemp)

  cd "${dir}"
  terragrunt "${command[@]}" 2>&1 | tee "${terragrunt_log_file}"
  # terragrunt_exit_code can be used later to determine if execution was successful
  terragrunt_exit_code=${PIPESTATUS[0]}

}

function comment {
  local -r message="$1"
  local -r comment_url
  comment_url=$(jq -r '.pull_request.comments_url' "$GITHUB_EVENT_PATH")
  if [[ "${comment_url}" == "" || "${comment_url}" == "null" ]]; then
    log "Skipping comment as there is not comment url"
    return
  fi
  local -r messagePayload
  messagePayload=$(jq -n --arg body "$message" '{ "body": $body }')
  curl -s -S -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" -d "$messagePayload" "$comment_url"
}

function main {
  log "Starting Terragrunt Action"
  trap 'log "Finished Terragrunt Action execution"' EXIT
  local -r tf_version=${INPUT_TF_VERSION:-latest}
  local -r tg_version=${INPUT_TG_VERSION:-latest}
  local -r tg_command=${INPUT_TG_COMMAND:-plan}
  local -r tg_comment=${INPUT_TG_COMMENT:-0}
  local -r tg_dir=${INPUT_TG_DIR:-.}

  install_terraform "${tf_version}"
  install_terragrunt "${tg_version}"

  # add auto approve for apply and destroy commands
  if [[ "$tg_command" == "apply"* || "$tg_command" == "destroy"* || "$tg_command" == "run-all apply"* || "$tg_command" == "run-all destroy"* ]]; then
    local -r tg_arg_and_commands="${tg_command} -auto-approve --terragrunt-non-interactive"
  else
    local -r tg_arg_and_commands="${tg_command}"
  fi
  run_terragrunt "${tg_dir}" "${tg_arg_and_commands}"

  local -r log_file="${terragrunt_log_file}"
  trap 'rm -rf ${log_file}' EXIT

  local -r exit_code
  exit_code=$(("${terragrunt_exit_code}"))

  local -r terragrunt_log_content
  terragrunt_log_content=$(cat "${log_file}")
  # output without colors
  local -r terragrunt_output
  terragrunt_output=$(clean_colors "${terragrunt_log_content}")

  if [[ "${tg_comment}" == "1" ]]; then
    comment "Execution result of \`$tg_command\` in ${tg_dir} :
\`\`\`
${terragrunt_output}
\`\`\`
    "
  fi
  echo "::set-output name=tg_action_exit_code::${exit_code}"
  local tg_action_output
  tg_action_output="${terragrunt_output//'%'/'%25'}"
  tg_action_output="${tg_action_output//$'\n'/'%0A'}"
  tg_action_output="${tg_action_output//$'\r'/'%0D'}"
  echo "::set-output name=tg_action_output::${tg_action_output}"
  exit $exit_code
}

main "$@"
