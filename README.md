# ghostty-devspace

在 Ghostty 终端中一键创建开发工作区。

```
┌──────────┬──────────┐
│          │   yazi   │
│  claude  ├──────────┤
│          │ lazygit  │
└──────────┴──────────┘
```

## 新机器安装

```bash
git clone git@github.com:brantshin/ghostty-devspace.git
cd ghostty-devspace
./setup.sh
```

会自动安装所有依赖并部署配置（Homebrew → Node.js → Ghostty → 字体 → yazi → 插件 → lazygit → Claude Code → devspace CLI）。

已有 npm 的机器也可以：

```bash
npm i -g @brantshi1/devspace
devspace setup
```

## 使用

在 Ghostty 终端中运行：

```bash
devspace
```

## 命令

| 命令 | 说明 |
|------|------|
| `devspace` | 创建三栏工作区 |
| `devspace setup [-f]` | 部署开发环境，`-f` 强制覆盖已有配置 |
| `devspace sync` | 将本机配置同步到仓库 `configs/` 目录 |
| `devspace -h` | 显示帮助 |

## 配置同步

源机器修改配置后：

```bash
devspace sync
cd ~/ghostty-devspace
git add configs/ && git commit -m "update configs" && git push
```

目标机器拉取更新：

```bash
cd ~/ghostty-devspace
git pull
devspace setup -f
```

## 要求

- macOS
- Ghostty 终端
- macOS 辅助功能权限（System Events）
