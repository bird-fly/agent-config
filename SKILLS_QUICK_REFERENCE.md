# 技能管理快速参考

> 一页纸搞定技能管理 🚀

## 🔍 查看技能

```powershell
# 完整分析报告（推荐）
node scripts\analyze-skills.js

# 查看特定技能详情
node scripts\analyze-skills.js --skill diagnose

# 显示详细来源信息
node scripts\analyze-skills.js --verbose

# PowerShell 快速查询
.\scripts\skill-source.ps1 grill-me          # 单个技能
.\scripts\skill-source.ps1 -All              # 所有技能列表
.\scripts\skill-source.ps1 -BySource         # 按来源分组
.\scripts\skill-source.ps1 -Interactive      # 交互模式

# 查看分类文档
Get-Content SKILLS_CATALOG.md

# 查看某个技能详情
Get-Content shared\skills\grill-me\SKILL.md

# 查看所有技能列表
Get-ChildItem shared\skills -Directory | Select-Object Name
```

## ➕ 启用技能

1. 编辑配置：`notepad clients\claude\skills.manifest.json`
2. 添加技能名到 `skills` 数组
3. 同步：`.\setup.ps1 -Mode Copy`

## ➖ 禁用技能

1. 编辑配置：`notepad clients\claude\skills.manifest.json`
2. 从 `skills` 数组移除技能名
3. 同步：`.\setup.ps1 -Mode Copy`

## 📊 技能分类

| 图标 | 分类 | 数量 | 状态 |
|------|------|------|------|
| 🎯 | Matt Pocock 核心 | 14 | ✅ 已启用 |
| ⚡ | Superpowers 工作流 | 7 | ❌ 已禁用 |
| 🤝 | Multica 协作 | 5 | ✅ 已启用 |
| 🎨 | 设计与原型 | 2 | ✅ 已启用 |
| 🛠️ | 工具与元技能 | 3 | ✅ 已启用 |
| 🔧 | 其他独立 | 3 | ✅ 已启用 |

## 🎯 核心技能速查

### 需求澄清
- `grill-me` - 无情追问，澄清需求
- `grill-with-docs` - 基于文档的审问

### Bug 调试
- `diagnose` - 6阶段系统化调试
- `systematic-debugging` - 调试方法集

### 架构优化
- `improve-codebase-architecture` - 架构深化

### 代码审查
- `requesting-code-review` - 请求审查
- `receiving-code-review` - 接收审查

### 测试
- `tdd` - 测试驱动开发
- `test-driven-development` - TDD 变体

## ⚠️ 已禁用的 Superpowers

| 技能 | 原因 |
|------|------|
| `using-superpowers` | 工作流入口 |
| `brainstorming` | 使用 superpowers 路径 |
| `writing-plans` | 使用 superpowers 路径 |
| `executing-plans` | Superpowers 执行器 |
| `subagent-driven-development` | 依赖工作流 |
| `using-git-worktrees` | 使用 superpowers 路径 |
| `finishing-a-development-branch` | 工作流终点 |

## 📁 关键文件位置

```
agent-config/
├── SKILLS_CATALOG.md              # 完整分类目录
├── SKILLS_QUICK_REFERENCE.md      # 本文件（快速参考）
├── docs/SKILLS_MANAGEMENT.md      # 详细管理指南
├── scripts/analyze-skills.js      # 分析工具
├── shared/skills/                 # 所有技能文件
└── clients/
    ├── claude/skills.manifest.json    # Claude 配置
    ├── codex/skills.manifest.json     # Codex 配置
    └── openCode/skills.manifest.json  # OpenCode 配置
```

## 🔄 典型工作流

### 新增技能
```powershell
1. 放到 shared/skills/new-skill/
2. notepad clients\claude\skills.manifest.json
3. .\setup.ps1 -Mode Copy
4. node scripts\analyze-skills.js
```

### 移除技能
```powershell
1. notepad clients\claude\skills.manifest.json
2. .\setup.ps1 -Mode Copy
3. notepad SKILLS_CATALOG.md  # 更新文档
```

### 检查状态
```powershell
node scripts\analyze-skills.js
```

## 💡 最佳实践

✅ **推荐**
- 用配置控制，不要物理删除
- 定期运行分析工具
- 保持分类文档更新

❌ **避免**
- 物理删除技能文件夹
- 忘记同步配置
- 混用冲突的工作流

## 📚 详细文档

- 🔍 **完整管理指南：** `docs/SKILLS_MANAGEMENT.md`
- 📖 **分类目录：** `SKILLS_CATALOG.md`
- 🔧 **命令参考：** `COMMANDS.md`

---

**记住：配置管理 > 物理删除 | 工具优先 > 手动查找**
