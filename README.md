# agent-config

> 🤖 统一管理 Claude Code、Codex、OpenCode 的智能体配置、规则和技能

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![技能数量](https://img.shields.io/badge/技能-41个-blue.svg)](#技能列表)
[![平台支持](https://img.shields.io/badge/平台-Claude%20%7C%20Codex%20%7C%20OpenCode-green.svg)](#支持的平台)

---

## 🎯 核心特性

- **一处编写，多处生效** - 共享规则和技能，自动同步到所有平台
- **智能同步** - 符号链接优先，自动回退到复制模式
- **完整的技能库** - 41 个精选技能，涵盖工程、生产力和代码分析
- **自动化工具** - 一键安装、同步、检查和诊断

---

## 🚀 快速开始

### 安装

```powershell
# 克隆仓库（包含子模块）
git clone --recursive https://github.com/bird-fly/agent-config.git
cd agent-config

# 首次设置（自动生成 prompt 并同步技能）
.\setup.ps1 -Mode Copy
```

### 日常使用

```powershell
# 修改规则或技能后，重新同步
.\setup.ps1 -Mode Copy

# 检查配置状态
.\scripts\doctor.ps1 -RepoRoot .

# 查询技能来源
.\scripts\skill-source.ps1 grill-me

# 交互式查询
.\scripts\skill-source.ps1 -Interactive
```

---

## 📁 目录结构

```
agent-config/
├── shared/                      # 共享资源（核心）
│   ├── rules/                   # 共享规则
│   │   ├── core.md             # 核心规则
│   │   ├── workflow.md         # 工作流规则
│   │   └── frontend-design.md # 前端设计规则
│   ├── skills/                  # 共享技能（41个）
│   └── plugins/                 # 插件（如 understand-anything）
│
├── clients/                     # 客户端特定配置
│   ├── claude/
│   │   ├── rules/              # Claude 专属规则
│   │   └── skills.manifest.json # Claude 技能清单
│   ├── codex/
│   └── openCode/
│
├── generated/                   # 自动生成（不要手动编辑）
│   ├── claude/CLAUDE.md        # Claude 最终 prompt
│   ├── codex/AGENTS.md         # Codex 最终 prompt
│   └── openCode/AGENTS.md      # OpenCode 最终 prompt
│
├── scripts/                     # 自动化脚本
│   ├── build-prompts.ps1       # 生成 prompt
│   ├── sync-skills.ps1         # 同步技能
│   ├── skill-source.ps1        # 技能来源查询
│   ├── analyze-skills.js       # 技能分析
│   └── doctor.ps1              # 配置诊断
│
├── docs/                        # 文档
│   ├── UNDERSTAND_ANYTHING_PLUGIN.md  # Understand插件文档
│   └── AGENT_INSTALLATION_GUIDE.md    # 智能体安装指南
│
└── setup.ps1                    # 一键设置脚本
```

---

## 🎨 技能列表

### 📊 总览
- **总技能数**: 41 个
- **Matt Pocock 系列**: 6 个
- **Understand 系列**: 8 个
- **Multica 系列**: 5 个
- **其他核心技能**: 22 个

### 🔥 热门技能

| 技能 | 分类 | 描述 |
|------|------|------|
| `understand` | 代码分析 | 生成代码库知识图谱 |
| `understand-dashboard` | 代码分析 | 交互式可视化看板 |
| `grill-with-docs` | 工程 | 带文档的代码审查 |
| `triage` | 工程 | Issue 分流状态机 |
| `prototype` | 工程 | 快速构建原型 |
| `tdd` | 工程 | 测试驱动开发 |
| `ask-matt` | 生产力 | 技能路由器 |
| `research` | 生产力 | 调研并生成文档 |
| `teach` | 生产力 | 多会话教学 |
| `last30days` | 研究 | 研究过去30天的讨论 |

**查看完整列表**:
```powershell
# 按来源分组查看
.\scripts\skill-source.ps1 -BySource

# 详细分析
node scripts\analyze-skills.js
```

---

## 🔧 常用操作

### 修改规则

1. 编辑共享规则：
   ```
   shared/rules/core.md
   shared/rules/workflow.md
   shared/rules/frontend-design.md
   ```

2. 或编辑客户端专属规则：
   ```
   clients/claude/rules/claude.md
   clients/codex/rules/codex.md
   clients/openCode/rules/openCode.md
   ```

3. 重新同步：
   ```powershell
   .\setup.ps1 -Mode Copy
   ```

### 添加新技能

1. 将技能添加到 `shared/skills/<skill-name>/`

2. 更新客户端清单：
   ```json
   // clients/claude/skills.manifest.json
   {
     "skills": [
       "existing-skill",
       "new-skill-name"  // 添加这里
     ]
   }
   ```

3. 同步到本机：
   ```powershell
   .\setup.ps1 -Mode Copy
   ```

### 导入已安装的技能

如果你本机已经有技能想导入到仓库：

```powershell
# 自动扫描 ~/.claude, ~/.codex, ~/.openCode 等目录
.\setup.ps1 -ImportInstalledSkills -Mode Copy
```

### 查询技能来源

```powershell
# 查询单个技能
.\scripts\skill-source.ps1 grill-me

# 交互模式（推荐）
.\scripts\skill-source.ps1 -Interactive

# 查看所有技能
.\scripts\skill-source.ps1 -All

# 按来源分组
.\scripts\skill-source.ps1 -BySource
```

---

## 🌟 特色功能

### 1. Understand-Anything 插件

完整的代码库分析插件，包含 8 个技能：

- 🔍 **understand** - 生成知识图谱
- 💬 **understand-chat** - 对话式问答
- 📊 **understand-dashboard** - 可视化看板
- 🔄 **understand-diff** - 变更影响分析
- 🏢 **understand-domain** - 业务域分析
- 📖 **understand-explain** - 深度代码解释
- 📚 **understand-knowledge** - 知识库分析
- 👥 **understand-onboard** - 新人入职指南

**使用**:
```bash
# 分析项目
/understand

# 打开可视化看板
/understand-dashboard

# 对话式问答
/understand-chat 认证流程是如何工作的？
```

📖 [完整文档](docs/UNDERSTAND_ANYTHING_PLUGIN.md)

### 2. 技能来源查询

不记得某个技能来自哪里？一键查询：

```powershell
# 快速查询
.\scripts\skill-source.ps1 grill-me

# 输出示例：
# ✓ grill-me
#   来源: Matt Pocock (官方技能)
#   分类: Productivity
#   描述: 对计划或设计进行无情审问
```

### 3. 自动化检查

确保配置正确：

```powershell
# 完整健康检查
.\scripts\doctor.ps1 -RepoRoot .

# 运行测试
.\scripts\test-agent-config.ps1 -RepoRoot .
```

---

## 🖥️ 支持的平台

| 平台 | 状态 | Prompt 路径 | 技能路径 |
|------|------|------------|----------|
| **Claude Code** | ✅ 支持 | `~/.claude/CLAUDE.md` | `~/.claude/skills/` |
| **Codex** | ✅ 支持 | `~/.codex/AGENTS.md` | `~/.codex/skills/` |
| **OpenCode** | ✅ 支持 | `~/.openCode/AGENTS.md` | `~/.opencode/skills/` |

---

## 📚 文档

- [INSTALLATION_SUMMARY.md](INSTALLATION_SUMMARY.md) - Understand 插件安装总结
- [docs/UNDERSTAND_ANYTHING_PLUGIN.md](docs/UNDERSTAND_ANYTHING_PLUGIN.md) - Understand 插件详细文档
- [docs/AGENT_INSTALLATION_GUIDE.md](docs/AGENT_INSTALLATION_GUIDE.md) - 智能体 vs 插件 vs 技能
- [COMMANDS.md](COMMANDS.md) - 常用命令速查

---

## 🔍 故障排查

### 问题：技能没有同步到本机

```powershell
# 检查配置
.\scripts\doctor.ps1 -RepoRoot .

# 强制重新同步
.\setup.ps1 -Mode Copy
```

### 问题：Understand 技能找不到核心包

确保使用了符号链接模式：

```powershell
.\setup.ps1 -Mode Link
```

### 问题：权限不足无法创建符号链接

使用复制模式：

```powershell
.\setup.ps1 -Mode Copy
```

---

## 🤝 贡献

欢迎贡献新技能、规则改进或文档更新！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/my-skill`)
3. 提交更改 (`git commit -m 'Add my skill'`)
4. 推送到分支 (`git push origin feature/my-skill`)
5. 创建 Pull Request

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 🙏 致谢

- [Matt Pocock](https://github.com/mattpocock/skills) - 提供优秀的工程和生产力技能
- [Understand-Anything](https://github.com/Lum1104/Understand-Anything) - 强大的代码分析插件
- [Multica](https://github.com/multica) - Issue 管理技能集

---

**最后更新**: 2026-07-08  
**仓库**: https://github.com/bird-fly/agent-config  
**技能数**: 41 个
