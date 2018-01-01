# WriteFreely publishing

Federated publishing application written in Go, with server-rendered templates and MySQL or SQLite persistence.

This repository is a separately imported source snapshot of [writefreely](https://github.com/writefreely/writefreely). Upstream contributors created the imported application; local work is recorded in the commits after the source import. See [Upstream source](UPSTREAM_SOURCE.md) for attribution.

## Read the history accurately

The local history starts with a source import on November 3, 2026. The parent year directory and the “Original project year” field do not establish a historical contribution date or a release tag. The imported upstream commit and release are not recorded in the available provenance file.

## Navigate the source

| Path | Responsibility |
| --- | --- |
| [cmd/](cmd/) | Executable entry points |
| [config/](config/) | Configuration handling |
| [migrations/](migrations/) | Database migrations |
| [templates/](templates/) | Server-rendered templates |
| [Makefile](Makefile) | Build, dependency, and test commands |

## Prepare development

Read `go.mod`, `Makefile`, `docker-compose.yml`, and the configuration package. Match the declared Go version. SQLite builds use the `sqlite` build tag and a C compiler. Several Makefile build targets depend on dependency-fetching targets; inspect them before running.

The commands below are existing project entry points, to run after their toolchain, dependency, and service prerequisites are ready:

```sh
go test ./...
make build
```

## Validation scope

The documentation change was checked for local link targets, manifest command references, and whitespace errors. Application builds, dependency installation, and service-backed test suites were not run for this documentation change. These instructions do not establish deployment readiness.

## Preserve upstream licensing

Read [LICENSE](LICENSE) and the notices in individual source files. This documentation does not change the license of imported code.

## Initialize the Compose development instance

After preparing `config.ini` and starting the database service with `docker compose up -d writefreely-db`, wait until MariaDB reports it is ready for connections, then run `bash docker-setup.sh` from an interactive terminal. The helper configures the instance, initializes its database, and generates keys using one-off `writefreely-web` containers. Start the web service with `docker compose up -d writefreely-web` after initialization. Use this initialization flow for a fresh development instance, not as a database upgrade command. It stops if a step fails.

Run `bash scripts/test-docker-setup.sh` for the dependency-free command and failure-handling regression checks. These checks mock Docker; a live container/database initialization has not been performed.

## Build and run locally

Install the Go toolchain declared in `go.mod`, and a C compiler for SQLite builds. Build the application using the existing Makefile:

```sh
make build
./cmd/writefreely/writefreely --config
./cmd/writefreely/writefreely --init-db
./cmd/writefreely/writefreely --gen-keys
./cmd/writefreely/writefreely
```

The configuration wizard prepares `config.ini`; select a fresh local database and development hostname before initialization. Do not run `--init-db` as an upgrade step for a database containing existing posts. `make ui` prepares frontend assets and requires the Less tooling referenced by the Makefile and Dockerfile.

## Plan a deployment

Review `Dockerfile.prod`, `docker-compose.prod.yml`, and the configuration package before choosing an image. Persist `config.ini`, keys, and database data, configure a public HTTPS hostname, and retain database backups before upgrades. The development Compose password `changeme` must be replaced for any exposed instance.
