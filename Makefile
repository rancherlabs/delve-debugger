GO_VERSION=1.18
DLV_VERSION=1.9.1
DELVE_DEBUGGER_VERSION=1

IMAGE_NAME=ghcr.io/moio/delve-debugger

build:
	docker build --build-arg GO_VERSION=$(GO_VERSION) --build-arg DLV_VERSION=$(DLV_VERSION) --tag $(IMAGE_NAME):$(DLV_VERSION)-$(DELVE_DEBUGGER_VERSION) package/

push: build
	docker push $(TAG)
