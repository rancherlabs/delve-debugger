GO_VERSION=1.18
DLV_VERSION=1.9.1

TAG=ghcr.io/moio/delve-debugger:v$(DLV_VERSION)

build:
	docker build --build-arg GO_VERSION=$(GO_VERSION) --build-arg DLV_VERSION=$(DLV_VERSION) --tag $(TAG) package/

push: build
	docker push $(TAG)
