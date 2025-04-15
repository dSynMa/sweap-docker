.PHONY : all artifact-podman sweap-podman sweap-docker

all: artifact-podman sweap-podman sweap-docker

artifact-podman:
	podman build -f containers/Dockerfile -t sweap-artifact:v1.4 --arch amd64
	podman tag localhost/sweap-artifact:v1.4 localhost/sweap-artifact:latest

artifact-docker:
	docker build containers -f containers/Dockerfile -t sweap-artifact:v1.4 --platform linux/amd64
	docker tag sweap-artifact:v1.4 sweap-artifact:latest

sweap-podman:
	podman build -f containers/Dockerfile-sweap -t sweap --arch amd64

sweap-docker:
	docker build containers -f containers/Dockerfile-sweap -t sweap --platform linux/amd64
