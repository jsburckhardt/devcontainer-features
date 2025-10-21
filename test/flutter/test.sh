#!/bin/bash

set -e

source dev-container-features-test-lib
# Check that flutter and dart binaries exist
check "flutter binary exists" test -f /opt/flutter/bin/flutter
check "dart binary exists" test -f /opt/flutter/bin/dart
# Check symlinks
check "flutter symlink" test -L /usr/local/bin/flutter
check "dart symlink" test -L /usr/local/bin/dart
reportResults
