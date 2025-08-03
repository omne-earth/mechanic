#!make
include .env
export $(shell sed 's/=.*//' .env)

.ONESHELL:
.DEFAULT_GOAL := init
version := 1.0

PODMAN_DIR=$$WORKSPACE/podman
BASE_IMAGE=$(PODMAN_DIR)/fedora-toolbox-42.tar

base:
	podman pull registry.fedoraproject.org/fedora-toolbox:42
	rm -rf $(BASE_IMAGE)
	mkdir -p $(PODMAN_DIR)
	podman save -o $(BASE_IMAGE) fedora-toolbox:42

toolbox-base: base
	podman rm toolbox-base --force || true
	podman container restore --import=$(BASE_IMAGE) 
	toolbox create --image registry.fedoraproject.org/fedora-toolbox:42 --container toolbox-base -y
	podman commit toolbox-base world:base
	toolbox rm toolbox-base --force
	podman rm toolbox-base --force || true

toolbox-cuda:
	podman rm toolbox-cuda--force  || true
	toolbox create --image localhost/world:base --container toolbox-cuda -y
	toolbox run --container toolbox-cuda bash cuda/install.sh
	podman commit toolbox-cuda world:cuda
	podman rm toolbox-cuda --force || true

toolbox-ollama:
	podman rm toolbox-ollama --force || true
	toolbox create --image localhost/world:cuda --container toolbox-ollama -y
	toolbox run --container toolbox-ollama sudo dnf install -y ollama
	podman commit toolbox-ollama world:ollama
	podman rm toolbox-ollama --force || true

toolbox-clean:
	podman rm toolbox-base --force || true
	podman rm toolbox-cuda --force || true
	podman rm toolbox-ollama --force || true

toolbox: toolbox-base toolbox-cuda toolbox-ollama toolbox-clean

git:
	sudo dnf install -y git git-lfs 
	git-lfs install
	echo "export GIT_CONFIG_GLOBAL=$$WORKSPACE/.gitconfig" >> ~/.bashrc

container:
	sudo dnf install -y podman podman-compose toolbox speedtest-cli

container-toolkit:
	curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
		sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
	NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
	sudo dnf update -y
	sudo dnf install -y \
		nvidia-container-toolkit-$$NVIDIA_CONTAINER_TOOLKIT_VERSION \
		nvidia-container-toolkit-base-$$NVIDIA_CONTAINER_TOOLKIT_VERSION \
		libnvidia-container-tools-$$NVIDIA_CONTAINER_TOOLKIT_VERSION \
		libnvidia-container1-$$NVIDIA_CONTAINER_TOOLKIT_VERSION

init-cdi:
	sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

podman-test: init-cdi
	mkdir -p $$VOLUMES/podman-test/
	echo "test file" > $$VOLUMES/podman-test/test
	podman compose -f providers/podman-test/compose.yml down
	podman compose -f providers/podman-test/compose.yml up
	podman compose -f providers/podman-test/compose.yml down
	rm -rf $$VOLUMES/podman-test/


vscode:
	code --install-extension thecreativedodo.usbip-connect --force
	code --install-extension ms-vscode.vscode-serial-monitor --force
	code --install-extension ms-azuretools.vscode-containers --force
	code --install-extension github.remotehub --force
	code --install-extension ms-python.python --force
	code --install-extension ms-toolsai.jupyter --force
	code --install-extension thecreativedodo.usbip-connect --force
	code --install-extension continue.continue --force

init: git container container-toolkit vscode podman-test

llama.cpp:
	THIS_TOOLBOX=$(@)
	podman rm $$THIS_TOOLBOX --force
	toolbox create --image localhost/world:cuda --container $$THIS_TOOLBOX -y
	toolbox run --container $$THIS_TOOLBOX bash providers/$(@).sh

continue: init-cdi
	mkdir -p $$VOLUMES/continue/
	podman compose -f providers/ollama/continue/compose.yml down 
	podman compose -f providers/ollama/continue/compose.yml up -d
	podman logs --follow continue

devstral: init-cdi
	podman compose -f providers/ollama/devstral/compose.yml down
	podman compose -f providers/ollama/devstral/compose.yml up -d
	podman logs --follow devstral
	
clean:
	# all directories inside providers

purge: clean
	# remove all toolboxes
	toolbox rm world --force
