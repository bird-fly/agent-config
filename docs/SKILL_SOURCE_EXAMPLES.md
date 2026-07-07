# 技能来源查询示例

> 如何快速找到技能的来源和归属

## 🎯 问题场景

你可能遇到这些问题：
- ❓ "这个 `to-issues` 技能是谁写的？"
- ❓ "我有很多技能，哪些是 Matt Pocock 的？"
- ❓ "这个技能属于 Superpowers 吗？"
- ❓ "Multica 相关的技能有哪些？"

## 🔧 解决方案：两个工具

### 工具 1: Node.js 分析工具 (功能强大)
- 📊 完整分析报告
- 🔍 智能检测来源
- 📈 统计信息

### 工具 2: PowerShell 快速查询 (快速便捷)
- ⚡ 即时查询
- 💬 交互模式
- 📋 按来源分组

---

## 📚 使用示例

### 示例 1: 查看单个技能的来源

#### 使用 Node.js
```powershell
PS> node scripts\analyze-skills.js --skill grill-me

╔═══════════════════════════════════════════════════════════╗
║                技能详情 - grill-me                        ║
╚═══════════════════════════════════════════════════════════╝

📛 名称: grill-me
📝 描述: Interview the user relentlessly about a plan or design
📁 分类: matt-pocock-core
📦 来源: Matt Pocock
🔗 依赖: 无
✅ 启用状态: 已启用于 claude, codex, openCode

📄 文档位置: shared/skills/grill-me/SKILL.md
```

#### 使用 PowerShell
```powershell
PS> .\scripts\skill-source.ps1 grill-me

╔═══════════════════════════════════════════════════════════╗
║           技能详情 - grill-me                             ║
╚═══════════════════════════════════════════════════════════╝

📛 名称: grill-me
📝 描述: Interview the user relentlessly...
📁 分类: Matt Pocock
📦 来源: Matt Pocock
📄 文档: shared\skills\grill-me\SKILL.md
```

---

### 示例 2: 查看所有技能的来源

```powershell
PS> .\scripts\skill-source.ps1 -All

📚 所有技能来源列表

brainstorming                           → Superpowers Framework
caveman                                 → 未知来源
design-taste-frontend                   → 未知来源
diagnose                                → Matt Pocock
dispatching-parallel-agents             → 未知来源
executing-plans                         → Superpowers Framework
find-skills                             → 未知来源
finishing-a-development-branch          → Superpowers Framework
grill-me                                → Matt Pocock
grill-with-docs                         → Matt Pocock
improve-codebase-architecture           → Matt Pocock
multica-agent-invoker                   → Multica Platform
multica-issue-clarifier                 → Multica Platform
...
```

---

### 示例 3: 按来源分组查看

```powershell
PS> .\scripts\skill-source.ps1 -BySource

📦 按来源分组

🏷️  Matt Pocock
  ────────────────────────────────────────────────────────────
  • diagnose
  • grill-me
  • grill-with-docs
  • improve-codebase-architecture
  • requesting-code-review
  • receiving-code-review
  • setup-matt-pocock-skills
  • systematic-debugging
  • tdd
  • test-driven-development
  • to-issues
  • to-prd
  • triage
  • zoom-out

🏷️  Multica Platform
  ────────────────────────────────────────────────────────────
  • multica-agent-invoker
  • multica-issue-clarifier
  • multica-issue-creator
  • multica-issue-intake
  • multica-issue-updater

🏷️  Superpowers Framework
  ────────────────────────────────────────────────────────────
  • brainstorming
  • executing-plans
  • finishing-a-development-branch
  • subagent-driven-development
  • using-git-worktrees
  • using-superpowers
  • writing-plans

🏷️  未知来源
  ────────────────────────────────────────────────────────────
  • caveman
  • design-taste-frontend
  • dispatching-parallel-agents
  • find-skills
  • handoff
  • prototype
  • verification-before-completion
  • write-a-skill
  • writing-skills
```

---

### 示例 4: 交互模式（最方便）

```powershell
PS> .\scripts\skill-source.ps1 -Interactive

🔍 技能来源查询工具 (交互模式)

输入技能名称 (或 'exit' 退出): diagnose

╔═══════════════════════════════════════════════════════════╗
║           技能详情 - diagnose                             ║
╚═══════════════════════════════════════════════════════════╝

📛 名称: diagnose
📝 描述: Disciplined diagnosis loop for hard bugs...
📁 分类: Matt Pocock
📦 来源: Matt Pocock
📄 文档: shared\skills\diagnose\SKILL.md

输入技能名称 (或 'exit' 退出): to-issues

╔═══════════════════════════════════════════════════════════╗
║           技能详情 - to-issues                            ║
╚═══════════════════════════════════════════════════════════╝

📛 名称: to-issues
📝 描述: Break a plan, spec, or PRD into issues...
📁 分类: Matt Pocock
📦 来源: Matt Pocock
📄 文档: shared\skills\to-issues\SKILL.md

输入技能名称 (或 'exit' 退出): exit

再见！
```

---

### 示例 5: 使用完整分析报告

```powershell
PS> node scripts\analyze-skills.js

╔═══════════════════════════════════════════════════════════╗
║           技能分析报告 - Skills Analysis Report          ║
╚═══════════════════════════════════════════════════════════╝

📊 总技能数: 34

📁 分类统计:
  🎯 Matt Pocock 核心: 14
  ⚡ Superpowers 工作流: 7
  🤝 Multica 协作: 5
  🎨 设计与原型: 2
  🛠️ 工具与元技能: 3
  🔧 其他独立技能: 3

⚡ Superpowers 技能 (应被禁用):
  - using-superpowers
    Use when starting any conversation...
  - brainstorming
    Explores user intent, requirements and design...
  ...

❌ 已禁用的技能:
  - using-superpowers (superpowers)
    禁用客户端: claude, codex, openCode
  ...

🔗 技能依赖关系:
  subagent-driven-development → using-git-worktrees, writing-plans
  ...

✅ 启用状态 (按客户端):
  claude: 27 个技能
  codex: 27 个技能
  openCode: 27 个技能

📦 技能来源统计:
  Matt Pocock: 14 个技能
  Superpowers Framework: 7 个技能
  Multica Platform: 5 个技能
  未知来源: 8 个技能

💡 提示: 使用 --verbose 查看每个来源的详细技能列表
      使用 --skill <name> 查看特定技能的详细信息
```

---

### 示例 6: 带详细信息的分析

```powershell
PS> node scripts\analyze-skills.js --verbose

...
📦 技能来源统计:
  Matt Pocock: 14 个技能
    - diagnose
    - grill-me
    - grill-with-docs
    - improve-codebase-architecture
    - receiving-code-review
    - requesting-code-review
    - setup-matt-pocock-skills
    - systematic-debugging
    - tdd
    - test-driven-development
    - to-issues
    - to-prd
    - triage
    - zoom-out
  
  Superpowers Framework: 7 个技能
    - brainstorming
    - executing-plans
    - finishing-a-development-branch
    - subagent-driven-development
    - using-git-worktrees
    - using-superpowers
    - writing-plans
  
  Multica Platform: 5 个技能
    - multica-agent-invoker
    - multica-issue-clarifier
    - multica-issue-creator
    - multica-issue-intake
    - multica-issue-updater
  ...
```

---

## 🎯 实际应用场景

### 场景 1: 下载了新技能，不知道来源

```powershell
# 查看新技能详情
PS> node scripts\analyze-skills.js --skill new-skill-name

# 或使用交互模式快速查询多个
PS> .\scripts\skill-source.ps1 -Interactive
```

### 场景 2: 想禁用所有 Superpowers 技能

```powershell
# 1. 查看哪些是 Superpowers
PS> .\scripts\skill-source.ps1 -BySource

# 2. 找到 "Superpowers Framework" 分组下的技能
# 3. 从 clients/*/skills.manifest.json 中移除这些技能
# 4. 同步
PS> .\setup.ps1 -Mode Copy
```

### 场景 3: 只想使用 Matt Pocock 的技能

```powershell
# 查看所有 Matt Pocock 技能
PS> .\scripts\skill-source.ps1 -BySource

# 复制 "Matt Pocock" 分组下的技能列表
# 更新 skills.manifest.json 只包含这些技能
```

### 场景 4: 团队协作，告诉别人技能来源

```powershell
# 生成完整报告
PS> node scripts\analyze-skills.js > skill-report.txt

# 或生成 JSON 格式
PS> node scripts\analyze-skills.js --json > skills.json

# 分享给团队
```

---

## 🔍 检测规则说明

### 如何识别来源？

1. **Matt Pocock**
   - 文档中包含 "mattpocock", "matt-pocock", "Matt Pocock"
   - 在 `setup-matt-pocock-skills` 中被引用

2. **Superpowers Framework**
   - 使用 `docs/superpowers/` 路径
   - 使用 `~/.config/superpowers/` 路径
   - 引用 `superpowers:` 前缀的其他技能

3. **Multica Platform**
   - 技能名以 `multica-` 开头
   - 文档中包含 "multica" 关键字

4. **Anthropic**
   - 文档中包含 "anthropic", "Anthropic"
   - 引用 "anthropic-best-practices"

5. **GitHub 项目**
   - 文档中包含 GitHub 仓库链接

6. **未知来源**
   - 以上特征都不匹配

---

## 💡 高级用法

### 导出技能来源映射

```powershell
# JSON 格式（适合程序处理）
node scripts\analyze-skills.js --json | ConvertFrom-Json | 
    Select-Object -ExpandProperty sources | 
    ConvertTo-Json -Depth 10 | 
    Out-File skills-sources.json
```

### 过滤特定来源的技能

```powershell
# 只查看 Matt Pocock 的技能
node scripts\analyze-skills.js --json | 
    ConvertFrom-Json | 
    Select-Object -ExpandProperty sources | 
    Get-Member -MemberType NoteProperty | 
    Where-Object { $_.Definition -like '*Matt Pocock*' } | 
    Select-Object Name
```

### 批量查询

```powershell
# 查询多个技能
$skills = @('grill-me', 'diagnose', 'to-issues', 'brainstorming')
foreach ($skill in $skills) {
    Write-Host "`n=== $skill ===" -ForegroundColor Green
    node scripts\analyze-skills.js --skill $skill
}
```

---

## 📚 相关文档

- [技能管理入门](../README_SKILLS.md)
- [快速参考卡](../SKILLS_QUICK_REFERENCE.md)
- [完整分类目录](../SKILLS_CATALOG.md)
- [详细管理指南](SKILLS_MANAGEMENT.md)

---

**记住：不确定技能来源？直接问工具！** 🚀

```powershell
# 最快的方式
.\scripts\skill-source.ps1 -Interactive
```
