#!/bin/bash

set -e
source dev-container-features-test-lib
check "bat" bat --version
check "flux" flux version --client
check "notation" notation version
check "crane" crane version
check "skopeo" skopeo --version
check "kyverno" kyverno version
check "cyclonedx" cyclonedx --version
check "gitleaks" gitleaks version
check "gic" gic --version
check "uv" uv --version
check "ruff" ruff --version
check "jnv" jnv -V
check "zarf" zarf version
check "codex" codex --version
check "just" just --version
check "opencode" opencode --version
check "ccc" ccc --version
check "yazi" yazi --version
check "tmux" tmux -V
check "fzf" fzf --version
check "lazygit" lazygit --version
check "ripgrep" rg --version
check "fd" fd --version
check "rtk" rtk --version
check "zoxide" zoxide --version
check "hyperfine" hyperfine --version
check "glow" glow --version
check "fx" fx --version
check "hurl" hurl --version
check "markitdown" markitdown --version
check "ast-grep" sg --version
check "mise" mise --version
check "jj" jj --version
check "difftastic" difft --version
check "delta" delta --version
check "actionlint" actionlint --version

reportResults
