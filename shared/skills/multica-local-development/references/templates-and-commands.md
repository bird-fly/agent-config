# Multica 模板与命令

## 默认负责人

```powershell
multica user profile get --workspace-id <workspace-id> --output json
```

创建 issue 时默认使用当前用户：

```powershell
--assignee-id <current-user-id>
```

仅在用户明确要求派给智能体时执行：

```powershell
multica issue assign <issue-id> --to-id <agent-id> --workspace-id <workspace-id>
```

## CLI 授权友好写法

优先让命令以稳定子命令开头，把 `--workspace-id` 放到子命令参数后面：

```powershell
multica issue get <issue-id> --workspace-id <workspace-id> --output json
```

避免写成：

```powershell
multica --workspace-id <workspace-id> issue get <issue-id> --output json
```

建议细粒度持久授权前缀：

```text
["multica","issue","get"]
["multica","issue","create"]
["multica","issue","comment","add"]
["multica","issue","comment","list"]
["multica","issue","status"]
["multica","workspace","list"]
["multica","user","profile","get"]
```

不要请求过宽前缀如 `["multica"]`。

## 任务类型

- 产品：需求澄清、PRD、流程、用户故事、验收、优先级
- 开发：前后端、接口、数据库、SQL、业务逻辑、bug、重构、构建运行问题
- UI/UX：页面、交互、样式、移动端、表单/列表/弹窗/流程页、视觉一致性
- 测试：用例、回归、验收、审查、复测、测试报告、边界验证

## Issue 描述模板

```md
## 用户原始需求

<用户原话>

## 任务类型判断

<产品 / 开发 / UI/UX / 测试>

## 执行目标

<要达成的结果>

## 计划步骤

1. ...
2. ...

## 验收标准

- [ ] ...
- [ ] ...

## 本地项目路径

<local-path>

## Multica 项目

<project-title> / <project-id>
```

子 issue 可加：

```md
## Parent

<identifier> / <title>

## Blocked by

None - can start immediately
```

## 会话评论模板

只写和当前 issue 相关的摘要，不贴完整聊天。

```md
## 会话依据

- 用户需求或变更
- 已确认决策
- bug 根因或接口/字段/UI 约束

## 实现关注点

- 必须保留的原有行为
- 不能回归的接口、分页、授权、跳转、弹窗、返回、提示
- 验证点和风险

## 本次进展

- 分析 / 修改文件 / 决策 / 验证命令 / 测试结果 / 阻塞原因
```

## 创建 Issue

```powershell
multica issue create `
  --workspace-id <workspace-id> `
  --project <project-id> `
  --assignee-id <current-user-id> `
  --title "<title>" `
  --description-file "<description-file>" `
  --status todo `
  --output json
```

## 创建子 Issue

父 issue 的 `project_id` 为 `null` 时，省略 `--project <project-id>`。

```powershell
multica issue create `
  --workspace-id <workspace-id> `
  --project <project-id> `
  --parent "<parent-issue-id>" `
  --assignee-id <current-user-id> `
  --title "<title>" `
  --description-file "<description-file>" `
  --status todo `
  --output json
```

## 评论

```powershell
multica issue comment add <issue-id> --content-file "<file>" --workspace-id <workspace-id> --output json
```

评论结果不确定时，先查再重试：

```powershell
multica issue comment list <issue-id> --workspace-id <workspace-id> --output json --summary --recent 5
```

重复评论只保留最完整的一条：

```powershell
multica issue comment delete <comment-id> --workspace-id <workspace-id>
```

## 查进度

```powershell
multica issue get <issue-id> --workspace-id <workspace-id> --output json
multica issue runs <issue-id> --workspace-id <workspace-id> --output json
multica issue run-messages <run-id> --workspace-id <workspace-id> --output json
```

## 改状态

有效 issue 状态：`backlog`、`todo`、`in_progress`、`in_review`、`done`、`blocked`、`cancelled`。不要用 project 状态 `planned`。

```powershell
multica issue status <issue-id> done --workspace-id <workspace-id> --output json
```

## 回复用户

创建 issue 后回复：标题、issue ID、负责人、智能体分配情况、项目、平台链接。

## Windows

多行中文用 `--description-file` / `--content-file`，临时文件放 `$env:TEMP`，UTF-8 编码。
