IMAGE_NAME=ghcr.io/moio/delve-debugger

GO_VERSION := $(shell grep '^ARG GO_VERSION=' package/Dockerfile | cut -d'=' -f2)
DLV_VERSION := $(shell grep '^ARG DLV_VERSION=' package/Dockerfile | cut -d'=' -f2)
DELVE_DEBUGGER_VERSION := $(shell grep '^ARG DELVE_DEBUGGER_VERSION=' package/Dockerfile | cut -d'=' -f2)

K3D_IMPORT_CLUSTER=upstream

build:
	docker build --build-arg GO_VERSION=$(GO_VERSION) --build-arg DLV_VERSION=$(DLV_VERSION) --tag $(IMAGE_NAME):$(DLV_VERSION)-$(DELVE_DEBUGGER_VERSION) package/

import: build
	k3d image import --mode direct --cluster $(K3D_IMPORT_CLUSTER) $(IMAGE_NAME):$(DLV_VERSION)-$(DELVE_DEBUGGER_VERSION)

# Build the test target image
test-build-target:
	docker build -t delve-debugger-test-target:latest test/testprogram/

# Run Docker e2e test only
test-e2e-docker: build test-build-target
	bash test/e2e-docker.sh

# Run k3d e2e test only (requires k3d)
test-e2e-k3d: build test-build-target
	bash test/e2e-k3d.sh

# Run all e2e tests
test-e2e: build test-build-target
	bash test/e2e-docker.sh && bash test/e2e-k3d.sh
