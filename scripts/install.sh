#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_dir}"

./scripts/init.sh

printf '\nDownloading the stable Hermes image...\n'
sudo docker compose pull

printf '\nConfigure the model provider. Credentials stay in data/hermes/.env.\n'
sudo docker compose run --rm hermes setup

printf '\nConfigure Telegram and Email. Keep both user allowlists enabled.\n'
sudo docker compose run --rm hermes gateway setup

printf '\nStarting Hermes...\n'
sudo docker compose up -d

printf '\nRunning diagnostics...\n'
sudo docker compose exec hermes hermes doctor

printf '\nHermes is running. Follow logs with:\n'
printf '  sudo docker compose logs -f hermes\n'

