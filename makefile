# add test task
.PHONY: test
test:
	devcontainer features test --global-scenarios-only .
