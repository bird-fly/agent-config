# 技能管理指南

> 如何有效管理和组织 Agent 技能

## 📋 目录

- [问题背景](#问题背景)
- [解决方案](#解决方案)
- [快速开始](#快速开始)
- [工具说明](#工具说明)
- [常见场景](#常见场景)
- [最佳实践](#最佳实践)

---

## 问题背景

当你下载或创建了很多技能后，可能会遇到以下问题：

- ❓ 不知道某个技能属于哪个系列（Matt Pocock? Superpowers? Multica?）
- 🤔 不清楚哪些技能已启用，哪些已禁用
- 🔗 不了解技能之间的依赖关系
- 📚 难以快速找到需要的技能

## 解决方案

本项目提供了三层管理工具：

### 1. 📖 分类文档：`SKILLS_CATALOG.md`
- **位置：** 项目根目录
- **用途：** 完整的技能分类目录
- **内容：**
  - 按类别组织的技能列表
  - 每个技能的说明和状态
  - Superpowers 工作流说明
  - 维护日志

### 2. 🔍 分析工具：`scripts/analyze-skills.js`
- **位置：** `scripts/` 目录
- **用途：** 自动分析技能
- **功能：**
  - 统计技能数量和分类
  - 识别 Superpowers 技能
  - 检测依赖关系
  - 显示启用/禁用状态

### 3. 📝 配置文件：`clients/*/skills.manifest.json`
- **位置：** 每个客户端目录
- **用途：** 控制哪些技能启用
- **格式：** JSON 数组

---

## 快速开始

### 查看当前技能状态

```powershell
# 方式 1：查看分析报告（推荐）
node scripts\analyze-skills.js

# 方式 2：查看分类文档
Get-Content SKILLS_CATALOG.md

# 方式 3：查看某个客户端启用的技能
Get-Content clients\claude\skills.manifest.json
```

### 启用一个技能

1. 编辑客户端配置文件：
```powershell
notepad clients\claude\skills.manifest.json
```

2. 在 `skills` 数组中添加技能名：
```json
{
  "skills": [
    "existing-skill-1",
    "existing-skill-2",
    "new-skill-name"
  ]
}
```

3. 同步到本机：
```powershell
.\setup.ps1 -Mode Copy
```

### 禁用一个技能

1. 编辑客户端配置文件
2. 从 `skills` 数组中移除技能名
3. 同步到本机

---

## 工具说明

### 分析工具 (`scripts/analyze-skills.js`)

#### 基本用法
```powershell
node scripts\analyze-skills.js
```

#### 输出内容
```
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
  - brainstorming
  - writing-plans
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
```

#### 高级选项
```powershell
# 输出 JSON 格式（用于脚本处理）
node scripts\analyze-skills.js --json > analysis.json
```

### 分类文档 (`SKILLS_CATALOG.md`)

#### 结构
```markdown
# 技能目录分类

## 🎯 Matt Pocock 核心技能
### 需求与设计
| 技能名 | 说明 | 状态 |
|--------|------|------|
| grill-me | ... | ✅ 启用 |

## ⚡ Superpowers 工作流
| 技能名 | 说明 | 状态 | 原因 |
|--------|------|------|------|
| brainstorming | ... | ❌ 禁用 | ... |

...
```

#### 何时更新
- ✅ 添加新技能时
- ✅ 移除技能时
- ✅ 重新分类时
- ✅ 发现新的依赖关系时

---

## 常见场景

### 场景 1：我想知道某个技能是干什么的

```powershell
# 方式 1：查看分类文档（快速）
Get-Content SKILLS_CATALOG.md | Select-String "skill-name"

# 方式 2：查看技能原始文档（详细）
Get-Content shared\skills\skill-name\SKILL.md
```

### 场景 2：我想知道某个技能是否已启用

```powershell
# 运行分析工具
node scripts\analyze-skills.js

# 或者直接检查配置文件
Get-Content clients\claude\skills.manifest.json | Select-String "skill-name"
```

### 场景 3：我下载了一个新技能，如何添加？

1. **将技能放到 `shared/skills/` 目录**
   ```powershell
   # 确保目录结构正确
   # shared/skills/new-skill/SKILL.md 必须存在
   ```

2. **更新分类文档**
   ```powershell
   notepad SKILLS_CATALOG.md
   # 在合适的分类下添加技能信息
   ```

3. **决定是否启用**
   ```powershell
   # 如果要启用，添加到 manifest
   notepad clients\claude\skills.manifest.json
   ```

4. **同步到本机**
   ```powershell
   .\setup.ps1 -Mode Copy
   ```

5. **验证**
   ```powershell
   node scripts\analyze-skills.js
   ```

### 场景 4：我想清理不用的技能

**不推荐物理删除！** 而是在配置中禁用：

1. **识别不需要的技能**
   ```powershell
   node scripts\analyze-skills.js
   # 查看分类和依赖关系
   ```

2. **从 manifest 中移除**
   ```powershell
   notepad clients\claude\skills.manifest.json
   # 删除相应的技能名
   ```

3. **更新分类文档状态**
   ```powershell
   notepad SKILLS_CATALOG.md
   # 将状态改为 ❌ 禁用
   ```

4. **同步**
   ```powershell
   .\setup.ps1 -Mode Copy
   ```

### 场景 5：我想了解 Superpowers 工作流

```powershell
# 查看分类文档中的 Superpowers 章节
Get-Content SKILLS_CATALOG.md

# 或运行分析工具
node scripts\analyze-skills.js
```

**Superpowers 工作流包含：**
- `using-superpowers` - 入口
- `brainstorming` - 设计
- `writing-plans` - 计划
- `executing-plans` / `subagent-driven-development` - 执行
- `using-git-worktrees` - 隔离环境
- `finishing-a-development-branch` - 完成

---

## 最佳实践

### ✅ 推荐做法

1. **定期运行分析工具**
   ```powershell
   node scripts\analyze-skills.js
   ```
   - 了解当前状态
   - 发现孤立技能
   - 检查依赖关系

2. **保持分类文档更新**
   - 新增技能时更新 `SKILLS_CATALOG.md`
   - 记录禁用原因
   - 维护日志记录变更

3. **使用配置管理而非物理删除**
   - 在 `skills.manifest.json` 中控制启用/禁用
   - 保留所有技能文件
   - 便于将来重新启用

4. **理解技能分类**
   - Matt Pocock 核心：高质量独立工具
   - Superpowers：完整工作流系统
   - Multica：多代理协作
   - 根据需求选择合适的技能集

5. **注意依赖关系**
   - 运行分析工具查看依赖
   - 禁用技能前检查是否被其他技能依赖
   - 保持技能集的完整性

### ❌ 避免的做法

1. **不要随意删除 `shared/skills/` 中的文件夹**
   - 使用配置控制，不要物理删除
   - 删除可能导致其他技能依赖失败

2. **不要忘记同步**
   ```powershell
   # 修改配置后必须同步
   .\setup.ps1 -Mode Copy
   ```

3. **不要混用不同工作流**
   - 例如：同时启用 Superpowers 和 Matt Pocock 的类似功能
   - 可能导致冲突和混乱

4. **不要忽略分类文档**
   - 保持 `SKILLS_CATALOG.md` 更新
   - 这是团队共享知识的重要资源

---

## 技能分类速查表

| 分类 | 标识符 | 特征 | 示例 |
|------|--------|------|------|
| 🎯 Matt Pocock 核心 | `matt-pocock-core` | 独立高质量工具 | grill-me, diagnose |
| ⚡ Superpowers | `superpowers` | 使用 `docs/superpowers/` 路径 | brainstorming, writing-plans |
| 🤝 Multica | `multica` | 前缀 `multica-` | multica-issue-creator |
| 🎨 设计与原型 | `design` | 前端/UI相关 | design-taste-frontend, prototype |
| 🛠️ 元技能 | `meta` | 管理技能的技能 | find-skills, write-a-skill |
| 🔧 其他 | `other` | 独立功能 | caveman, handoff |

---

## 相关文件

- 📖 **SKILLS_CATALOG.md** - 完整分类目录
- 🔍 **scripts/analyze-skills.js** - 分析工具
- 📝 **clients/*/skills.manifest.json** - 配置文件
- 📚 **COMMANDS.md** - 所有命令参考
- 🔧 **shared/rules/core.md** - 核心规则（引用技能）

---

## 故障排查

### 问题：分析工具无法运行

```powershell
# 确保安装了 Node.js
node --version

# 确保在项目根目录
cd e:\Project\codexProject\agent-config
```

### 问题：修改配置后技能未生效

```powershell
# 检查配置文件语法
Get-Content clients\claude\skills.manifest.json | ConvertFrom-Json

# 重新同步
.\setup.ps1 -Mode Copy

# 运行检查
.\scripts\doctor.ps1 -RepoRoot .
```

### 问题：不确定某个技能的分类

```powershell
# 运行分析工具
node scripts\analyze-skills.js

# 查看技能文档
Get-Content shared\skills\skill-name\SKILL.md
```

---

## 总结

通过这套管理工具，你可以：

✅ **清楚了解**每个技能的归属和用途  
✅ **轻松管理**技能的启用和禁用  
✅ **快速查找**需要的功能  
✅ **避免冲突**不同工作流之间  
✅ **保持整洁**技能库的组织结构  

记住：**用配置管理，不要物理删除**！
