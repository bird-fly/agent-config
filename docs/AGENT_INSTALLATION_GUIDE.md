# 智能体（Agent）安装指南

> 本指南说明如何在 agent-config 项目中安装和管理完整的智能体（Agent）

---

## 🤔 Skill vs Agent 的区别

### Skill（技能）
- **定义：** 单一功能模块，提供特定能力
- **结构：** 通常只有 `SKILL.md` + 可选的脚本
- **位置：** `shared/skills/{skill-name}/`
- **示例：** `/grill-me`, `/diagnose`, `/research`

### Agent（智能体）
- **定义：** 完整的 AI 代理，有独立的 prompt、规则、技能集合
- **结构：** 包含 prompt、rules、skills、agents 等多个组件
- **位置：** 需要创建专门的智能体目录结构
- **示例：** 专门的代码审查代理、架构设计代理

---

## 📁 推荐的智能体目录结构

```
agent-config/
├── clients/
│   ├── claude/
│   │   ├── agents/              # 新增：智能体目录
│   │   │   ├── code-reviewer/
│   │   │   │   ├── AGENT.md     # 智能体定义
│   │   │   │   ├── rules/       # 专属规则
│   │   │   │   └── skills.manifest.json
│   │   │   └── architect/
│   │   ├── rules/
│   │   └── skills.manifest.json
│   ├── codex/
│   └── openCode/
└── shared/
    ├── agents/                   # 新增：共享智能体
    │   ├── general-reviewer/
    │   └── domain-expert/
    ├── rules/
    └── skills/
```

---

## 🔧 安装智能体的三种方式

### 方式 1：作为独立子智能体（推荐）

**适用场景：** 完整的智能体项目，如专门的代码审查系统

**步骤：**

1. **创建智能体目录**
```powershell
# 创建客户端专属智能体
New-Item -Path "clients/claude/agents/code-reviewer" -ItemType Directory -Force
```

2. **复制智能体文件**
```powershell
# 假设从 GitHub 下载了智能体
git clone https://github.com/example/code-reviewer-agent.git .temp-agent
Copy-Item -Path ".temp-agent/*" -Destination "clients/claude/agents/code-reviewer/" -Recurse
Remove-Item -Path ".temp-agent" -Recurse -Force
```

3. **配置智能体**
创建 `clients/claude/agents/code-reviewer/config.json`：
```json
{
  "name": "code-reviewer",
  "description": "专门的代码审查智能体",
  "enabled": true,
  "skills": [
    "requesting-code-review",
    "receiving-code-review",
    "tdd"
  ]
}
```

4. **在主 prompt 中引用**
在 `clients/claude/rules/claude.md` 中添加：
```markdown
## 可用的子智能体

- `/code-reviewer` - 专门的代码审查智能体
  调用方式：`invoke_sub_agent("code-reviewer", "审查这段代码")`
```

---

### 方式 2：提取技能并集成

**适用场景：** 智能体主要是技能的集合，没有复杂的独立逻辑

**步骤：**

1. **提取技能**
```powershell
# 假设智能体包含多个技能
git clone https://github.com/example/agent-suite.git .temp-agent

# 复制其中的技能到 shared/skills
Copy-Item -Path ".temp-agent/skills/*" -Destination "shared/skills/" -Recurse

# 清理
Remove-Item -Path ".temp-agent" -Recurse -Force
```

2. **更新技能清单**
在 `clients/claude/skills.manifest.json` 中添加新技能：
```json
{
  "skills": [
    "existing-skill-1",
    "existing-skill-2",
    "new-skill-from-agent",
    "another-new-skill"
  ]
}
```

3. **提取规则**
如果智能体有特殊规则，添加到 `clients/claude/rules/` 或 `shared/rules/`

---

### 方式 3：创建 Agent Profile

**适用场景：** 需要为特定任务创建预设配置的智能体配置文件

**步骤：**

1. **创建配置文件**
`clients/claude/agents/profiles/architect.json`：
```json
{
  "name": "architect",
  "displayName": "架构设计师",
  "description": "专注于系统架构设计和优化",
  "systemPrompt": "你是一位资深的软件架构师...",
  "enabledSkills": [
    "improve-codebase-architecture",
    "codebase-design",
    "grill-with-docs"
  ],
  "rules": [
    "shared/rules/core.md",
    "clients/claude/rules/claude.md",
    "clients/claude/agents/profiles/architect-rules.md"
  ],
  "temperature": 0.7,
  "maxTokens": 4096
}
```

2. **创建专属规则**
`clients/claude/agents/profiles/architect-rules.md`：
```markdown
# 架构设计师专属规则

## 工作流程
1. 理解业务需求和技术约束
2. 使用 `/grill-with-docs` 澄清架构需求
3. 使用 `/improve-codebase-architecture` 分析现有架构
4. 提供架构设计方案和迁移路径
```

3. **创建加载脚本**
`scripts/load-agent.ps1`：
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$AgentName,
    
    [ValidateSet("claude", "codex", "openCode")]
    [string]$Client = "claude"
)

$profilePath = "clients/$Client/agents/profiles/$AgentName.json"
if (Test-Path $profilePath) {
    $profile = Get-Content $profilePath | ConvertFrom-Json
    Write-Host "加载智能体: $($profile.displayName)"
    # 这里可以生成临时的 prompt 文件或配置
} else {
    Write-Error "智能体配置不存在: $profilePath"
}
```

---

## 📋 实际案例：安装一个完整智能体

### 案例：安装 OpenClaw Hermes Agent

假设你要安装一个完整的智能体项目：

**1. 分析智能体结构**
```powershell
git clone https://github.com/example/hermes-agent.git .temp-hermes
tree .temp-hermes
```

查看结构：
```
.temp-hermes/
├── AGENT.md           # 智能体说明
├── system-prompt.md   # 系统提示词
├── rules/             # 规则
│   ├── core.md
│   └── workflows.md
├── skills/            # 技能
│   ├── skill-a/
│   └── skill-b/
└── config.json        # 配置
```

**2. 决定安装方式**

根据结构选择：
- **有独立 system-prompt** → 方式 1（子智能体）
- **主要是技能集合** → 方式 2（提取技能）
- **是配置模板** → 方式 3（Agent Profile）

**3. 执行安装**

以方式 2 为例（提取技能）：

```powershell
# 提取技能
Copy-Item -Path ".temp-hermes/skills/*" -Destination "shared/skills/" -Recurse

# 提取规则（如果有用）
Copy-Item -Path ".temp-hermes/rules/workflows.md" -Destination "shared/rules/hermes-workflows.md"

# 更新配置
# 编辑 clients/claude/skills.manifest.json，添加新技能

# 清理
Remove-Item -Path ".temp-hermes" -Recurse -Force

# 同步到本机
.\scripts\sync-skills.ps1 -RepoRoot $PWD -Mode Copy

# 提交
git add shared/skills/ shared/rules/ clients/*/skills.manifest.json
git commit -m "feat: 集成 Hermes Agent 的技能和规则"
git push
```

---

## 🔄 同步智能体到本机

### 只同步技能（不更新 prompt）
```powershell
.\scripts\sync-skills.ps1 -RepoRoot $PWD -Mode Copy
```

### 完整同步（包括 prompt）
```powershell
.\setup.ps1 -Mode Copy
```

### 同步特定智能体
```powershell
# 如果有专门的智能体同步脚本
.\scripts\sync-agent.ps1 -AgentName "code-reviewer" -Client "claude"
```

---

## 📝 最佳实践

### ✅ 推荐做法

1. **评估再决定**
   - 先分析智能体的结构和复杂度
   - 简单的技能集合 → 提取技能
   - 复杂的独立系统 → 创建子智能体

2. **保持一致性**
   - 使用项目现有的目录结构
   - 遵循命名规范
   - 保持规则文件的简洁性

3. **文档化**
   - 记录智能体来源和版本
   - 更新 README 或 AGENTS.md
   - 说明使用方法

4. **版本管理**
   - 提交到 Git
   - 记录更新日志
   - 标注智能体版本

### ❌ 避免做法

1. **不要直接覆盖**
   - 不要直接覆盖现有规则和配置
   - 先备份，再集成

2. **不要混乱结构**
   - 不要把智能体文件散落在各处
   - 保持目录结构清晰

3. **不要忽略冲突**
   - 检查规则冲突
   - 检查技能名称冲突
   - 解决依赖问题

---

## 🎯 总结

| 智能体类型 | 推荐方式 | 位置 |
|-----------|---------|------|
| 完整独立智能体 | 方式 1：子智能体 | `clients/{client}/agents/` |
| 技能集合型 | 方式 2：提取技能 | `shared/skills/` |
| 配置模板型 | 方式 3：Profile | `clients/{client}/agents/profiles/` |
| 共享智能体 | 方式 1 + 共享 | `shared/agents/` |

---

## 📚 相关文档

- [技能管理指南](./SKILLS_MANAGEMENT.md)
- [规则文件说明](../shared/rules/)
- [客户端配置](../clients/)

---

**最后更新：** 2026-07-08  
**维护者：** agent-config 项目组
