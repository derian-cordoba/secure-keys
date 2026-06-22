# Makefile — MultiEnvironmentApp
# Convenience wrappers around the `secure-keys env` CLI.
#
# Usage:
#   make setup-dev            Install development secrets into the Keychain
#   make generate-dev         Generate the development xcframework
#   make generate-staging     Generate the staging xcframework (requires env vars)
#   make generate-production  Generate the production xcframework (requires env vars)
#   make generate-all         Generate xcframeworks for every environment
#   make diff ENV_A=dev ENV_B=production   Compare two environments
#   make list                 List all configured environments
#   make init                 Create .secure-keys.yml from the default template

.PHONY: init list diff generate-dev generate-staging generate-production generate-all setup-dev clean

# ─── Configuration ────────────────────────────────────────────────────────────

ENV_A ?= development
ENV_B ?= production

# ─── Targets ──────────────────────────────────────────────────────────────────

init:
	secure-keys env init

list:
	secure-keys env list

diff:
	secure-keys env diff $(ENV_A) $(ENV_B)

setup-dev:
	./scripts/setup-development.sh

generate-dev:
	secure-keys env generate development

generate-staging:
	secure-keys env generate staging

generate-production:
	secure-keys env generate production

generate-all:
	secure-keys env generate --all

clean:
	rm -rf .secure-keys
