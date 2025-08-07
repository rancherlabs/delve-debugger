IMAGE_NAME=ghcr.io/moio/delve-debugger

GO_VERSION := $(shell grep '^ARG GO_VERSION=' package/Dockerfile | cut -d'=' -f2)
DLV_VERSION := $(shell grep '^ARG DLV_VERSION=' package/Dockerfile | cut -d'=' -f2)
DELVE_DEBUGGER_VERSION := $(shell grep '^ARG DELVE_DEBUGGER_VERSION=' package/Dockerfile | cut -d'=' -f2)

K3D_IMPORT_CLUSTER=upstream

build:
	docker build --build-arg GO_VERSION=$(GO_VERSION) --build-arg DLV_VERSION=$(DLV_VERSION) --tag $(IMAGE_NAME):$(DLV_VERSION)-$(DELVE_DEBUGGER_VERSION) package/

import: build
	k3d image import --mode direct --cluster $(K3D_IMPORT_CLUSTER) $(IMAGE_NAME):$(DLV_VERSION)-$(DELVE_DEBUGGER_VERSION)
