# Makefile sample: variables, targets, conditionals, and shell recipes.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

THEME_NAME  := Themes of Shibbir
THEME_FILE  := themes/$(THEME_NAME)-color-theme.json
SAMPLES     := $(wildcard sample-files/*)
VERSION     ?= $(shell node -p "require('./package.json').version")
OUT         ?= dist
VSIX        := $(OUT)/themes-of-shibbir-$(VERSION).vsix

ifeq ($(origin CI), undefined)
    VSCE_FLAGS := --no-git-tag-version
else
    VSCE_FLAGS := --no-git-tag-version --no-update-package-json
endif

.PHONY: help colors package clean check install

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

colors: ## List every unique hex in the theme
	@grep -oE '#[0-9A-Fa-f]{6,8}' "$(THEME_FILE)" | sort -u

check: ## Validate the theme JSON
	@node -e 'JSON.parse(require("fs").readFileSync("$(THEME_FILE)", "utf8")); console.log("valid")'

$(OUT):
	mkdir -p $@

$(VSIX): $(THEME_FILE) package.json | $(OUT)
	npx @vscode/vsce package $(VSCE_FLAGS) --out $@

package: $(VSIX) ## Build the .vsix
	@echo "built $(VSIX) ($$(du -h $(VSIX) | cut -f1))"

install: package ## Install the built extension locally
	code --install-extension $(VSIX) --force

clean: ## Remove build output
	$(RM) -r $(OUT)
	@echo "cleaned"
