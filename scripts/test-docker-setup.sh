#!/bin/bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir "$test_dir/bin"
cat > "$test_dir/bin/docker" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$DOCKER_LOG"
if [ "${FAIL_COMMAND:-}" = "$*" ]; then
    exit 42
fi
STUB
chmod +x "$test_dir/bin/docker"
ln -s docker "$test_dir/bin/docker-compose"
export PATH="$test_dir/bin:$PATH"
export DOCKER_LOG="$test_dir/docker.log"

cd "$test_dir"
bash "$repo_dir/docker-setup.sh"
cat > "$test_dir/expected" <<'EXPECTED'
compose run --rm --entrypoint ./cmd/writefreely/writefreely writefreely-web --config
compose run --rm -T --entrypoint ./cmd/writefreely/writefreely writefreely-web --init-db
compose run --rm -T --entrypoint ./cmd/writefreely/writefreely writefreely-web --gen-keys
EXPECTED
diff -u "$test_dir/expected" "$DOCKER_LOG"

for failure in '--config' '--init-db'; do
    : > "$DOCKER_LOG"
    if [ "$failure" = '--config' ]; then
        export FAIL_COMMAND='compose run --rm --entrypoint ./cmd/writefreely/writefreely writefreely-web --config'
        expected_lines=1
    else
        export FAIL_COMMAND='compose run --rm -T --entrypoint ./cmd/writefreely/writefreely writefreely-web --init-db'
        expected_lines=2
    fi
    if bash "$repo_dir/docker-setup.sh"; then
        echo "Expected setup to fail for $failure" >&2
        exit 1
    fi
    test "$(wc -l < "$DOCKER_LOG" | tr -d ' ')" = "$expected_lines"
done
printf '%s\n' 'Docker setup command and failure checks passed.'
