# Makefile for Jetson Linux Flash Docker

# Configuration variables
SW_VERSION ?= r36.4
IMAGE_NAME ?= jetson-flash
IMAGE_TAG ?= $(SW_VERSION)
WORKSPACE ?= $(PWD)
BOARD ?= autodetect
ROOTDEV ?= mmcblk0p1
L4T_RELEASE_PACKAGE ?= https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2
SAMPLE_FS_PACKAGE ?= https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2

# Docker run flags
DOCKER_RUN_FLAGS = -it --privileged --net=host \
	-v /dev/bus/usb:/dev/bus/usb \
	-v $(WORKSPACE):/workspace

.PHONY: help build run shell flash clean

help:
	@echo "Jetson Linux Flash Docker Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build          - Build the Docker image"
	@echo "  run            - Run the container interactively"
	@echo "  shell          - Start a shell in the container"
	@echo "  flash          - Flash the Jetson device"
	@echo "  clean          - Remove the Docker image"
	@echo ""
	@echo "Configuration:"
	@echo "  SW_VERSION     = $(SW_VERSION)"
	@echo "  IMAGE_NAME     = $(IMAGE_NAME)"
	@echo "  IMAGE_TAG      = $(IMAGE_TAG)"
	@echo "  BOARD          = $(BOARD)"
	@echo "  WORKSPACE      = $(WORKSPACE)"

build:
	docker build \
		--build-arg SW_VERSION=$(SW_VERSION) \
		--build-arg L4T_RELEASE_PACKAGE=$(L4T_RELEASE_PACKAGE) \
		--build-arg SAMPLE_FS_PACKAGE=$(SAMPLE_FS_PACKAGE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		-t $(IMAGE_NAME):latest \
		.

run: build
	docker run -it $(DOCKER_RUN_FLAGS) $(IMAGE_NAME):$(IMAGE_TAG)

shell: build
	docker run $(DOCKER_RUN_FLAGS) $(IMAGE_NAME):$(IMAGE_TAG) bash

flash: build
	docker run $(DOCKER_RUN_FLAGS) $(IMAGE_NAME):$(IMAGE_TAG) \
		bash -c "cd /workspace/Linux_for_Tegra && ./flash.sh --no-root-check $(BOARD) $(ROOTDEV)"

clean:
	docker rmi -f $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest || true
