# add test task
.PHONY: test
test:
	devcontainer features test --global-scenarios-only .
test-matrix:
	devcontainer features test -f $(feature) -i ubuntu:latest
	devcontainer features test -f $(feature) -i debian:latest
	devcontainer features test -f $(feature) -i mcr.microsoft.com/devcontainers/base:ubuntu
