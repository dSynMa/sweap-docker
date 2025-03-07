.PHONY : all artifact-container sweap-container

all: artifact-container sweap-container

artifact-container:
	podman build -f artifact/Dockerfile -t sweap-artifact

sweap-container:
	podman build -f artifact/Dockerfile-sweap -t sweap
