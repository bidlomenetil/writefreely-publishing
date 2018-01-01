#!/bin/bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
docker compose run --rm --entrypoint ./cmd/writefreely/writefreely writefreely-web --config
docker compose run --rm -T --entrypoint ./cmd/writefreely/writefreely writefreely-web --init-db
docker compose run --rm -T --entrypoint ./cmd/writefreely/writefreely writefreely-web --gen-keys
