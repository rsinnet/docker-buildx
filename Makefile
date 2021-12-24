.DEFAULT_GOAL := help

REPO ?= rsinnet/docker-buildx
VERSION ?= latest

.PHONY: help
help: ## Show usage information for this Makefile.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: local
local: ## Build locally but don't push.
	docker build --tag=$(REPO):$(VERSION)

.PHONY: push
push: ## Push the container image to the repository.
	docker push $(REPO):$(VERSION)
