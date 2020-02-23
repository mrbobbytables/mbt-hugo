DOCKER			?= docker
DOCKER_RUN		:= $(DOCKER) run --rm -it -v $(CURDIR):/src
HUGO_VERSION		:= 0.49.2
DOCKER_IMAGE		:= mbt-hugo
REPO_ROOT	:=${CURDIR}

.DEFAULT_GOAL	:= help

.PHONY: targets docker-targets
targets: help render serve
docker-targets: docker-image docker-render docker-server

help: ## Show this help text.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


render: ## Build the site using Hugo on the host.
	hugo --verbose --ignoreCache --minify

server: ## Run Hugo locally (if Hugo "extended" is installed locally)
	hugo server \
		--verbose \
		--buildDrafts \
		--buildFuture \
		--disableFastRender \
		--ignoreCache

docker-image: ## Build container image for use with docker-* targets.
	$(DOCKER) build . -t $(DOCKER_IMAGE) --build-arg HUGO_VERSION=$(HUGO_VERSION)

docker-render: ## Build the site using Hugo within a Docker container (equiv to render).
	$(DOCKER_RUN) $(DOCKER_IMAGE) hugo --verbose --ignoreCache --minify

docker-server: ## Run Hugo locally within a Docker container (equiv to server).
	$(DOCKER_RUN) -p 1313:1313 $(DOCKER_IMAGE) hugo server \
		--verbose \
		--bind 0.0.0.0 \
		--buildDrafts \
		--buildFuture \
		--disableFastRender \
		--ignoreCache


production-build: ## Builds the production site (this command used only by Netlify).
	hugo \
		--verbose \
		--ignoreCache \
		--minify

preview-build: ## Builds a deploy preview of the site (this command used only by Netlify).
	hugo \
		--verbose \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture \
		--ignoreCache \
		--minify
