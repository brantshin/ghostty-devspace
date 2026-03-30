#!/usr/bin/env zsh
# setup.sh - 引导脚本：确保 node 可用后委托给 devspace setup
#
# 用法: ./setup.sh [-f]

set -euo pipefail

SCRIPT_DIR="${0:a:h}"

# 确保 Homebrew 可用
if ! command -v brew &>/dev/null; then
    echo "安装 Homebrew …"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 确保 Node.js 可用
if ! command -v node &>/dev/null; then
    echo "安装 Node.js …"
    brew install node
fi

# 注册 devspace CLI
if ! command -v devspace &>/dev/null; then
    (cd "$SCRIPT_DIR" && npm link)
fi

# 委托给 devspace setup
exec devspace setup "$@"
