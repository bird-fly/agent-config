# 技能目录分类

> 本文档记录所有技能的分类、归属和启用状态

## 📊 分类说明

- 🎯 **Matt Pocock 核心** - Matt Pocock 系列的核心技能
- ⚡ **Superpowers 工作流** - Superpowers 流程相关（已禁用）
- 🤝 **Multica 协作** - 多代理协作系统
- 🎨 **设计与原型** - 前端设计和原型开发
- 🛠️ **工具与元技能** - 技能管理和辅助工具
- 🔧 **其他独立技能** - 独立功能技能

---

## 🎯 Matt Pocock 核心技能 (已启用)

### 需求与设计
| 技能名 | 说明 | 状态 |
|--------|------|------|
| `grill-me` | 对计划/设计进行无情追问，澄清需求 | ✅ 启用 |
| `grill-with-docs` | 基于文档的审问，同步更新 CONTEXT.md 和 ADRs | ✅ 启用 |

### 调试与诊断
| 技能名 | 说明 | 状态 |
|--------|------|------|
| `diagnose` | 6阶段系统化调试流程，处理复杂 bug | ✅ 启用 |
| `systematic-debugging` | 系统化调试方法集（根因追踪、条件等待等） | ✅ 启用 |

### 架构优化
| 技能名 | 说明 | 状态 |
|--------|------|------|
| `improve-codebase-architecture` | 发现深化机会，优化架构，生成 HTML 报告 | ✅ 启用 |

### 代码审查
| 技能名 | 说明 | 状态 |
|--------|------|------|
| `requesting-code-review` | 请求代码审查，派发审查子代理 | ✅ 启用 |
| `receiving-code-review` | 接收和响应代码审查反馈 | ✅ 启用 |

### 测试驱动开发
| 技能名 | 说明 | 状态 |
|--------|------|------|
| `tdd` | 测试驱动开发（包含接口设计、重构、mocking） | ✅ 启用 |
| `test-driven-development` | TDD 变体，包含测试反模式指南 | ✅ 启用 |

### Issue 管理
| 技能名 | 说明 | 状态 |
|--------|------|------|
| `to-issues` | 将需求转换为 issue | ✅ 启用 |
| `to-prd` | 将讨论转换为产品需求文档 | ✅ 启用 |
| `triage` | Issue 分流和状态管理 | ✅ 启用 |

### 其他工具
| 技能名 | 说明 | 状态 |
|--------|------|------|
| `setup-matt-pocock-skills` | 配置 Matt Pocock 技能环境 | ✅ 启用 |
| `zoom-out` | 从更高层次审视问题 | ✅ 启用 |

---

## ⚡ Superpowers 工作流 (已禁用)

> 这些技能构成完整的 Superpowers 工作流，已从配置中移除

| 技能名 | 说明 | 状态 | 原因 |
|--------|------|------|------|
| `using-superpowers` | Superpowers 主入口和技能调用规则 | ❌ 禁用 | 工作流入口 |
| `brainstorming` | 头脑风暴，生成设计文档到 `docs/superpowers/specs/` | ❌ 禁用 | 使用 superpowers 路径 |
| `writing-plans` | 编写实现计划到 `docs/superpowers/plans/` | ❌ 禁用 | 使用 superpowers 路径 |
| `executing-plans` | 执行计划（内联方式） | ❌ 禁用 | Superpowers 执行器 |
| `subagent-driven-development` | 子代理驱动开发（另一种执行方式） | ❌ 禁用 | 依赖 Superpowers 工作流 |
| `using-git-worktrees` | Git worktrees 隔离工作区（使用 `~/.config/superpowers/worktrees/`） | ❌ 禁用 | 使用 superpowers 路径 |
| `finishing-a-development-branch` | 完成开发分支，清理 worktrees | ❌ 禁用 | Superpowers 工作流终点 |

**Superpowers 工作流链：**
```
using-superpowers → brainstorming → writing-plans 
                                   ↓
                    ┌──────────────┴──────────────┐
                    ↓                             ↓
            executing-plans          subagent-driven-development
                                                   ↓
                                          using-git-worktrees
                                                   ↓
                                   finishing-a-development-branch
```

---

## 🤝 Multica 协作系统 (已启用)

> 多代理协作的 issue 管理系统

| 技能名 | 说明 | 状态 |
|--------|------|------|
| `multica-agent-invoker` | 调用其他代理 | ✅ 启用 |
| `multica-issue-clarifier` | 澄清 issue 细节 | ✅ 启用 |
| `multica-issue-creator` | 创建新 issue | ✅ 启用 |
| `multica-issue-intake` | Issue 接收处理 | ✅ 启用 |
| `multica-issue-updater` | 更新 issue 状态 | ✅ 启用 |

---

## 🎨 设计与原型 (已启用)

| 技能名 | 说明 | 状态 |
|--------|------|------|
| `design-taste-frontend` | 前端设计原则和品味指导 | ✅ 启用 |
| `prototype` | 快速原型开发（UI + 逻辑） | ✅ 启用 |

---

## 🛠️ 工具与元技能 (已启用)

| 技能名 | 说明 | 状态 |
|--------|------|------|
| `find-skills` | 查找和发现可用技能 | ✅ 启用 |
| `write-a-skill` | 编写新技能的指南 | ✅ 启用 |
| `writing-skills` | 技能编写最佳实践（含 Anthropic 指南） | ✅ 启用 |

---

## 🔧 其他独立技能 (已启用)

| 技能名 | 说明 | 状态 |
|--------|------|------|
| `caveman` | 极简编码模式 | ✅ 启用 |
| `dispatching-parallel-agents` | 派发并行工作的代理 | ✅ 启用 |
| `handoff` | 工作交接给其他开发者或代理 | ✅ 启用 |
| `verification-before-completion` | 完成前的验证检查 | ✅ 启用 |

---

## 📈 统计

- **总技能数：** 34
- **已启用：** 27
- **已禁用：** 7 (Superpowers 工作流)

---

## 🔄 如何管理技能

### 启用技能
在 `clients/{client}/skills.manifest.json` 中添加技能名称：
```json
{
  "skills": [
    "skill-name"
  ]
}
```

### 禁用技能
从 `clients/{client}/skills.manifest.json` 中移除技能名称

### 查看技能详情
```bash
# 查看技能文档
cat shared/skills/{skill-name}/SKILL.md
```

---

## 📝 维护日志

- **2024-07-07** - 初始创建，移除所有 Superpowers 工作流技能
- **2024-07-07** - 从 core.md 中移除 "Superpowers 流程" 引用

