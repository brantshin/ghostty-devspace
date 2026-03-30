# CLAUDE.md

## 语言和称呼
- 使用中文回复
- 称呼用户为"长官"

## Git 规范
- ❌ **禁止自动提交**：只能由用户手动执行 git 操作，任何 skill（包括 executing-plans、subagent-driven-development 的 implementer subagent）均不得执行 `git commit`
- 代码修改完成后只允许执行 `git add`（stage 到暂存区），等待用户 review 后手动提交
- 提交指令默认使用 `/commit-push-pr`
- ❌ **禁止执行 `git clean`**：会删除未跟踪文件

## 编译规范
- 仅在重要代码修改后编译
- 文档修改不需要编译

## 网页获取
- 默认使用 `agent-browser` skill 获取网页内容，而非 WebFetch
