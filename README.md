# ghostty-devspace

在 Ghostty 终端中一键创建开发工作区。

```
┌──────────┬──────────┐
│          │   yazi   │
│  claude  ├──────────┤
│          │ lazygit  │
└──────────┴──────────┘
```

## 安装

```bash
git clone git@github.com:brantshin/ghostty-devspace.git
cd ghostty-devspace
./setup.sh
```

`setup.sh` 会自动检查并安装所有依赖（Ghostty、字体、yazi、lazygit、Claude Code 等），并部署配置文件。

## 使用

在 Ghostty 终端中运行：

```bash
devspace
```

## 命令

| 命令 | 说明 |
|------|------|
| `devspace` | 创建三栏工作区 |
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
./setup.sh -f
```

`-f` 表示强制覆盖已有配置文件。

## 要求

- macOS
- Ghostty 终端
- macOS 辅助功能权限（System Events）
