#!/usr/bin/env zsh
# setup.sh - 在新 Mac 上一键部署 Ghostty 开发环境
#
# 用法: ./setup.sh [-f]
#   -f  强制覆盖已有配置文件

set -euo pipefail

SCRIPT_DIR="${0:a:h}"
CONFIGS_DIR="$SCRIPT_DIR/configs"
FORCE=false

[[ "${1:-}" == "-f" ]] && FORCE=true

# ── 颜色 ──────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo "${GREEN}  ✓${RESET} $1" }
info() { echo "${YELLOW}  …${RESET} $1" }
fail() { echo "${RED}  ✗${RESET} $1" }

section() { echo "\n${BOLD}[$1]${RESET}" }

# ── 复制配置文件（检查已存在） ─────────────────────────
copy_config() {
    local src="$1" dst="$2"
    if [[ -f "$dst" ]] && ! $FORCE; then
        ok "$dst 已存在（跳过，用 -f 强制覆盖）"
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    ok "已复制 → $dst"
}

copy_dir() {
    local src="$1" dst="$2"
    if [[ -d "$dst" ]] && ! $FORCE; then
        ok "$dst/ 已存在（跳过，用 -f 强制覆盖）"
        return 0
    fi
    mkdir -p "$dst"
    cp -R "$src"/ "$dst"/
    ok "已复制 → $dst/"
}

# ── 检查 brew 包 ──────────────────────────────────────
ensure_brew_pkg() {
    local pkg="$1"
    if brew list "$pkg" &>/dev/null; then
        ok "$pkg 已安装"
    else
        info "安装 $pkg …"
        brew install "$pkg" || { fail "$pkg 安装失败"; return 1; }
        ok "$pkg 安装完成"
    fi
}

ensure_brew_cask() {
    local cask="$1"
    if brew list --cask "$cask" &>/dev/null; then
        ok "$cask 已安装"
    else
        info "安装 $cask …"
        brew install --cask "$cask" || { fail "$cask 安装失败"; return 1; }
        ok "$cask 安装完成"
    fi
}

# ── 前置检查 ──────────────────────────────────────────
echo "${BOLD}devspace setup — Ghostty 开发环境部署${RESET}"
echo "配置源: $CONFIGS_DIR"
echo ""

if [[ "$(uname)" != "Darwin" ]]; then
    fail "仅支持 macOS"
    exit 1
fi
ok "macOS $(sw_vers -productVersion)"

if ! [[ -d "$CONFIGS_DIR" ]]; then
    fail "找不到 configs/ 目录，请确认在仓库根目录运行"
    exit 1
fi

# ── 1. Homebrew ───────────────────────────────────────
section "Homebrew"
if command -v brew &>/dev/null; then
    ok "Homebrew 已安装"
else
    info "安装 Homebrew …"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Apple Silicon 需要加 PATH
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ok "Homebrew 安装完成"
fi

# ── 2. Ghostty ────────────────────────────────────────
section "Ghostty"
if command -v ghostty &>/dev/null || [[ -d "/Applications/Ghostty.app" ]]; then
    ok "Ghostty 已安装"
else
    ensure_brew_cask ghostty
fi

# ── 3. 字体 ──────────────────────────────────────────
section "字体"
if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font Mono" || \
   ls ~/Library/Fonts/JetBrainsMonoNerdFontMono-Regular.ttf &>/dev/null; then
    ok "JetBrainsMono Nerd Font Mono 已安装"
else
    ensure_brew_cask font-jetbrains-mono-nerd-font
fi

# ── 4. Ghostty 配置 ──────────────────────────────────
section "Ghostty 配置"
copy_config "$CONFIGS_DIR/ghostty/config" "$HOME/.config/ghostty/config"
copy_dir    "$CONFIGS_DIR/ghostty/themes" "$HOME/.config/ghostty/themes"

# ── 5. Yazi ──────────────────────────────────────────
section "Yazi"
ensure_brew_pkg yazi

# ── 6. Yazi 配置 ─────────────────────────────────────
section "Yazi 配置"
copy_config "$CONFIGS_DIR/yazi/yazi.toml"    "$HOME/.config/yazi/yazi.toml"
copy_config "$CONFIGS_DIR/yazi/package.toml" "$HOME/.config/yazi/package.toml"

# ── 7. Yazi 插件 ─────────────────────────────────────
section "Yazi 插件"
if command -v ya &>/dev/null; then
    info "安装 yazi 插件（ya pkg install）…"
    ya pkg install || { fail "ya pkg install 失败"; }
    ok "yazi 插件安装完成"
else
    fail "ya 命令不存在，请手动运行: ya pkg install"
fi

# ── 8. 插件依赖 ──────────────────────────────────────
section "插件依赖"
ensure_brew_pkg glow

if command -v rich &>/dev/null; then
    ok "rich-cli 已安装"
elif command -v pipx &>/dev/null; then
    info "安装 rich-cli（pipx）…"
    pipx install rich-cli || { fail "rich-cli 安装失败"; }
    ok "rich-cli 安装完成"
elif command -v pip3 &>/dev/null; then
    info "安装 rich-cli（pip3）…"
    pip3 install rich-cli || { fail "rich-cli 安装失败"; }
    ok "rich-cli 安装完成"
else
    fail "未找到 pipx 或 pip3，请手动安装 rich-cli"
fi

# ── 9. devspace 依赖 ─────────────────────────────────
section "devspace 依赖"
ensure_brew_pkg node
ensure_brew_pkg lazygit

if command -v claude &>/dev/null; then
    ok "Claude Code 已安装"
else
    if command -v npm &>/dev/null; then
        info "安装 Claude Code …"
        npm i -g @anthropic-ai/claude-code || { fail "Claude Code 安装失败"; }
        ok "Claude Code 安装完成"
    else
        fail "npm 未安装，请先安装 Node.js 后运行: npm i -g @anthropic-ai/claude-code"
    fi
fi

# ── 10. devspace CLI ──────────────────────────────────
section "devspace CLI"
if command -v devspace &>/dev/null; then
    ok "devspace 已安装（$(devspace --version)）"
else
    if command -v npm &>/dev/null; then
        info "npm link 安装 devspace …"
        (cd "$SCRIPT_DIR" && npm link) || { fail "npm link 失败"; }
        ok "devspace 安装完成"
    else
        fail "npm 未安装，请先安装 Node.js 后在仓库目录运行: npm link"
    fi
fi

# ── 完成 ─────────────────────────────────────────────
echo ""
echo "${GREEN}${BOLD}部署完成！${RESET}"
echo "打开 Ghostty 后运行 ${BOLD}devspace${RESET} 即可启动开发工作区。"
