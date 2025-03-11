.PHONY : all artifact-podman sweap-podman sweap-docker

all: artifact-podman sweap-podman sweap-docker

artifact-podman:
	podman build -f artifact/Dockerfile -t sweap-artifact --arch amd64

sweap-podman:
	podman build -f artifact/Dockerfile-sweap -t sweap --arch amd64

sweap-docker:
	docker build containers -f containers/Dockerfile-sweap -t sweap --platform linux/amd64
