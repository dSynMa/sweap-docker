.PHONY : all artifact-podman sweap-podman sweap-docker

all: artifact-podman sweap-podman sweap-docker

artifact-podman:
	podman build -f containers/Dockerfile -t sweap-artifact:v1.1 --arch amd64

artifact-docker:
	docker build containers -f containers/Dockerfile -t sweap-artifact:v1.1 --platform linux/amd64

sweap-podman:
	podman build -f containers/Dockerfile-sweap -t sweap --arch amd64

sweap-docker:
	docker build containers -f containers/Dockerfile-sweap -t sweap --platform linux/amd64
