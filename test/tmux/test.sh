#!/bin/bash

set -e

source dev-container-features-test-lib
check "tmux" tmux -V
reportResults
