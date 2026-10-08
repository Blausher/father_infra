#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup_dir="${repo_dir}/backups"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive="${backup_dir}/father-hermes-${timestamp}.tar.gz"

install -d -m 0700 "${backup_dir}"

if [[ ! -d "${repo_dir}/data/hermes" ]]; then
  printf 'Hermes data directory does not exist. Run scripts/init.sh first.\n' >&2
  exit 1
fi

cd "${repo_dir}"
was_running=false
running_container="$(sudo docker compose ps --status running -q hermes)"

restart_hermes() {
  if [[ "${was_running}" == true ]]; then
    sudo docker compose start hermes >/dev/null
  fi
}

if [[ -n "${running_container}" ]]; then
  was_running=true
  trap restart_hermes EXIT
  sudo docker compose stop hermes >/dev/null
fi

tar \
  --exclude='hermes/logs' \
  --exclude='hermes/cache' \
  -C "${repo_dir}/data" \
  -czf "${archive}" \
  hermes obsidian-vault

chmod 0600 "${archive}"
restart_hermes
trap - EXIT
printf 'Backup created: %s\n' "${archive}"
