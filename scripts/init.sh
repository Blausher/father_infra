#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hermes_dir="${repo_dir}/data/hermes"
vault_dir="${repo_dir}/data/obsidian-vault"

install -d -m 0700 "${hermes_dir}"
install -d -m 0750 \
  "${vault_dir}/00 Inbox" \
  "${vault_dir}/10 Knowledge" \
  "${vault_dir}/20 Sources" \
  "${vault_dir}/90 System/Templates"

if [[ ! -e "${hermes_dir}/.env" ]]; then
  install -m 0600 "${repo_dir}/templates/hermes.env.example" "${hermes_dir}/.env"
fi

if [[ ! -e "${hermes_dir}/config.yaml" ]]; then
  install -m 0600 "${repo_dir}/templates/config.yaml" "${hermes_dir}/config.yaml"
fi

if [[ ! -e "${hermes_dir}/SOUL.md" ]]; then
  install -m 0600 "${repo_dir}/templates/SOUL.md" "${hermes_dir}/SOUL.md"
fi

if [[ ! -e "${vault_dir}/.hermes.md" ]]; then
  install -m 0640 "${repo_dir}/templates/vault/.hermes.md" "${vault_dir}/.hermes.md"
fi

if [[ ! -e "${vault_dir}/README.md" ]]; then
  install -m 0640 "${repo_dir}/templates/vault/README.md" "${vault_dir}/README.md"
fi

if [[ ! -e "${vault_dir}/90 System/Templates/Knowledge.md" ]]; then
  install -m 0640 \
    "${repo_dir}/templates/vault/90 System/Templates/Knowledge.md" \
    "${vault_dir}/90 System/Templates/Knowledge.md"
fi

printf 'Hermes directories initialized.\n'
printf 'Next: sudo docker compose pull\n'
printf 'Then: sudo docker compose run --rm hermes setup\n'
printf 'Then: sudo docker compose run --rm hermes gateway setup\n'

