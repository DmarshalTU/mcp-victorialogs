download-docs:
	bash ./scripts/update-docs.sh

download-blog:
	bash ./scripts/update-blog.sh

update-docs: download-docs

update-blog: download-blog

update-resources: update-docs update-blog

test:
	bash ./scripts/test-all.sh

check:
	bash ./scripts/check-all.sh

lint:
	bash ./scripts/lint-all.sh

build:
	bash ./scripts/build-binaries.sh

all: test check lint build

IMAGE_REPO ?= dmarshaltu/mcp-vicrorialogs
IMAGE_TAG ?= $(shell grep '^appVersion:' k8s/helm/Chart.yaml | awk '{print $$2}')
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: docker-build
docker-build:
	docker build -t $(IMAGE_REPO):$(IMAGE_TAG) .

.PHONY: docker-push
docker-push:
	docker push $(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: docker
docker: docker-build docker-push

.PHONY: dockerx-setup
dockerx-setup:
	# Ensure buildx builder exists
	@if ! docker buildx inspect multiarch >/dev/null 2>&1; then \
		docker buildx create --name multiarch --use; \
	fi

.PHONY: dockerx-build
dockerx-build: dockerx-setup
	docker buildx build \
	  --platform $(PLATFORMS) \
	  -t $(IMAGE_REPO):$(IMAGE_TAG) \
	  --build-arg TARGETOS=linux \
	  --push \
	  .

.PHONY: dockerx
dockerx: dockerx-build
