---
name: multica-local-development
description: 当本地开发需要接入 Multica 任务流时使用：自动建 issue、默认负责人为当前用户、建父子任务、同步会话评论、查询进度、更新状态；仅在用户明确要求时分配智能体。
---

# Multica 本地开发

## 核心规则

- 先读项目本地配置：`AGENTS.md`、`CLAUDE.md`、`docs/` 中的 Multica 章节；项目配置优先于本 skill。
- 创建 issue 默认负责人是当前 Multica 登录用户本人，不默认分配智能体。
- 只有用户明确要求“派给智能体 / 分配给 agent / 让某某 agent 做”时，才使用项目 Agent 映射。
- 自动建 issue 触发词：开发、新增、修复、优化、调整、排查、设计、测试、实现、整理需求、帮我做。
- 不自动建 issue：只问代码、只看文件、只跑简单命令、用户说“不创建 issue”或“先讨论一下”。
- 有 issue id 先 `issue get`；无 issue id 且任务不小，先建父 issue，再按可独立验收的页面/业务链路建子 issue。
- 子 issue 使用父 issue 的 `project_id` 和 `--parent`；如果父 issue 的 `project_id` 为 `null`，创建子 issue 时省略 `--project`。
- 每个 issue 要有验收标准；每个实际工作 issue 要有对应会话评论。
- 本地继续处理时，只同步增量进展，不重复完整背景。
- 父 issue 只有在子任务完成或用户明确要求时才改为 `done`。


## CLI 权限与命令形态

- 为减少重复人工确认，Multica 命令优先使用稳定前缀：把全局参数放在子命令后面，例如 `multica issue get <issue-id> --workspace-id <workspace-id> --output json`。
- 避免写成 `multica --workspace-id <workspace-id> issue get ...`；这种写法会让命令前缀变成 `multica --workspace-id`，不利于持久授权规则匹配。
- 建议请求/使用这些细粒度持久授权前缀：`["multica","issue","get"]`、`["multica","issue","create"]`、`["multica","issue","comment","add"]`、`["multica","issue","comment","list"]`、`["multica","issue","status"]`、`["multica","workspace","list"]`、`["multica","user","profile","get"]`。
- 不要请求过宽前缀如 `["multica"]`；只覆盖当前工作流需要的命令类别。

## 需要模板时

创建 issue、评论、查询进度或状态同步时，读取：

`references/templates-and-commands.md`


