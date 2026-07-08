# 📘 项目概述

## 🎯 项目目标

**agent-config** 是一个统一管理多个 AI 编程助手（Claude、Codex、OpenCode）的配置系统，实现：

1. **一处编写，多处生效** - 规则和技能在多个平台间共享
2. **集中管理插件** - 插件统一存储，版本一致
3. **灵活配置** - 支持技能的不同同步模式，插件的启用/禁用

---

## 🏗️ 核心架构

### 三层结构

```
┌─────────────────────────────────────┐
│  仓库层 (Git 管理)                   │
│  • shared/rules/ - 共享规则          │
│  • shared/skills/ - 共享技能         │
│  • shared/plugins/ - 插件源          │
│  • clients/ - 平台特定配置           │
└─────────────────────────────────────┘
                 │
            同步/复制/链接
                 ↓
┌─────────────────────────────────────┐
│  中心层 (统一存储)                   │
│  • ~/.localAi/plugins/ - 插件中心    │
│  • ~/.localAi/skills/ - 技能中心     │
│    (仅 Link 模式使用)                │
└─────────────────────────────────────┘
                 │
            链接到平台
                 ↓
┌─────────────────────────────────────┐
│  平台层 (AI 工具)                    │
│  • ~/.claude/ - Claude Code         │
│  • ~/.codex/ - Codex                │
│  • ~/.openCode/ - OpenCode          │
└─────────────────────────────────────┘
```

---

## 📂 目录结构说明

### 核心目录

```
agent-config/
├── shared/                      # 共享资源
│   ├── rules/                   # 共享规则（所有平台通用）
│   │   ├── core.md             # 核心行为规则
│   │   ├── workflow.md         # 工作流规则
│   │   └── frontend-design.md # 前端设计规则
│   ├── skills/                  # 共享技能库（33个普通技能）
│   └── plugins/                 # 插件源（Git submodules）
│
├── clients/                     # 平台特定配置
│   ├── claude/
│   │   ├── rules/              # Claude 专属规则
│   │   └── skills.manifest.json # 技能清单（指定启用哪些技能）
│   ├── codex/
│   └── openCode/
│
├── scripts/                     # 自动化脚本
│   ├── build-prompts.ps1       # 生成平台 prompt 文件
│   ├── sync-skills.ps1         # 同步技能到平台
│   ├── sync-plugins.ps1        # 同步插件到管理中心 ⭐
│   ├── skill-source.ps1        # 查询技能来源
│   └── doctor.ps1              # 诊断配置状态
│
├── generated/                   # 自动生成的文件（不要手动编辑）
│   ├── claude/CLAUDE.md        # Claude 的最终 prompt
│   ├── codex/AGENTS.md         # Codex 的最终 prompt
│   └── openCode/AGENTS.md      # OpenCode 的最终 prompt
│
├── docs/                        # 文档
├── setup.ps1                    # 主安装脚本
├── setup.json                   # 用户配置（不提交 Git）
└── setup.example.json           # 配置模板（提交 Git）
```

### 用户配置文件

**setup.json** (本地配置，不提交 Git):
```json
{
  "clients": {
    "claude": {
      "promptTarget": "%USERPROFILE%\\.claude\\CLAUDE.md",
      "skillsTarget": "%USERPROFILE%\\.claude\\skills"
    }
  },
  "plugins": {
    "understand-anything": true,   // 插件启用/禁用
    "another-plugin": false
  },
  "skillSyncModes": {
    "understand": "Link",          // 技能同步模式
    "grill-me": "Copy"
  }
}
```

---

## 🔄 工作流程

### 初次安装

```powershell
# 1. 克隆仓库（包含子模块）
git clone --recursive https://github.com/bird-fly/agent-config.git
cd agent-config

# 2. 同步插件到管理中心
.\scripts\sync-plugins.ps1

# 3. 生成 prompt 并同步技能
.\setup.ps1 -Mode Copy

# 4. 重启 AI 工具
```

### 日常使用

```powershell
# 修改规则或技能后重新同步
.\setup.ps1 -Mode Copy

# 更新插件
.\scripts\sync-plugins.ps1

# 检查配置状态
.\scripts\doctor.ps1

# 查询技能来源
.\scripts\skill-source.ps1 -Interactive
```

---

## 🎨 技能管理

### 技能分类

项目包含 **41 个技能**：

1. **普通技能** (33个) - 存储在 `shared/skills/`
   - Matt Pocock 系列 (6个): grill-me, ask-matt, triage 等
   - Multica 系列 (5个): last30days, research, teach 等
   - 其他核心技能 (22个)

2. **插件技能** (8个) - 来自插件，如 understand 系列
   - understand, understand-chat, understand-dashboard 等

### 技能同步模式

技能支持两种同步模式：

| 模式   | 说明                                    | 适用场景               |
| ------ | --------------------------------------- | ---------------------- |
| Copy   | 直接复制技能到平台                      | 普通技能（推荐）       |
| Link   | 复制到 .localAi/skills，再链接到平台 | 有外部依赖的技能       |

**配置示例**:
```json
{
  "skillSyncModes": {
    "understand": "Link",      // 依赖插件核心包，必须 Link
    "grill-me": "Copy"         // 独立技能，可以 Copy
  }
}
```

---

## 🔌 插件管理

### 插件系统

插件是完整的功能包，包含：
- **Skills** - 技能命令（如 /understand）
- **Agents** - 子智能体
- **Hooks** - 自动化钩子
- **Packages** - 核心功能包
- **MCP Servers** - 模型上下文协议服务

### 插件工作流

```
仓库 (shared/plugins/)
    ↓ 复制
插件中心 (~/.localAi/plugins/)
    ↓ 为每个技能创建链接
平台 (claude/codex/openCode)
```

### 插件配置

```json
{
  "plugins": {
    "understand-anything": true,   // 启用
    "another-plugin": false        // 禁用（会清理相关文件）
  }
}
```

禁用插件后，系统会自动：
1. 删除 `.localAi\plugins\` 中的插件
2. 删除各平台 `skills/` 中的技能链接

---

## 🛠️ 核心脚本说明

### setup.ps1 (主脚本)

一键执行所有设置：
1. 生成 prompt 文件（build-prompts.ps1）
2. 同步技能（sync-skills.ps1）
3. 诊断检查（doctor.ps1）

```powershell
.\setup.ps1 -Mode Copy              # 使用 Copy 模式
.\setup.ps1 -ImportInstalledSkills  # 导入本机已有技能
.\setup.ps1 -SkipDoctor             # 跳过诊断检查
```

### sync-plugins.ps1 (插件同步)

同步插件到管理中心：
- 从 `shared/plugins/` 复制插件到 `.localAi/plugins/`
- 为每个插件技能创建符号链接到平台
- 根据 `setup.json` 配置启用/禁用插件
- 自动清理已禁用插件的相关文件

```powershell
.\scripts\sync-plugins.ps1
.\scripts\sync-plugins.ps1 -ConfigPath .\setup.json
```

### sync-skills.ps1 (技能同步)

同步普通技能到平台：
- 读取 `clients/<平台>/skills.manifest.json`
- 根据配置使用 Copy 或 Link 模式
- 自动清理不在清单中的本地技能
- 支持插件技能优先策略（跳过插件技能）

```powershell
.\scripts\sync-skills.ps1 -Mode Copy
.\scripts\sync-skills.ps1 -Mode Link
```

### build-prompts.ps1 (Prompt 生成)

生成平台的 prompt 文件：
- 合并共享规则和平台专属规则
- 生成到 `generated/<平台>/` 目录
- 如果配置了 `promptTarget`，同时部署到平台

```powershell
.\scripts\build-prompts.ps1
```

### doctor.ps1 (诊断工具)

检查配置状态：
- 验证源目录、生成文件、目标路径
- 检查技能同步状态
- 显示安装映射（state/install-map.json）

```powershell
.\scripts\doctor.ps1
```

### skill-source.ps1 (技能查询)

查询技能来源和归属：

```powershell
.\scripts\skill-source.ps1 grill-me      # 查询单个技能
.\scripts\skill-source.ps1 -All          # 列出所有技能
.\scripts\skill-source.ps1 -BySource     # 按来源分组
.\scripts\skill-source.ps1 -Interactive  # 交互模式
```

---

## 🔑 核心概念

### 插件 vs 技能

| 概念   | 说明                                          | 示例                   |
| ------ | --------------------------------------------- | ---------------------- |
| 插件   | 完整功能包，包含技能、智能体、钩子、核心包    | understand-anything    |
| 技能   | 单个命令，可以是独立的或来自插件              | grill-me, understand   |

### 插件技能优先策略

当 `shared/skills/` 和插件中都有同名技能时：
- **插件技能优先** - 使用插件版本
- 自动跳过 `shared/skills/` 中的插件技能
- 避免冲突和重复

### 同步模式

| 模式   | 插件                     | 技能                                    |
| ------ | ------------------------ | --------------------------------------- |
| Copy   | 始终复制（默认且唯一）   | 直接复制到平台                          |
| Link   | 不支持                   | 复制到 .localAi/skills，再链接到平台 |

---

## 📚 常用命令速查

```powershell
# === 完整设置 ===
.\setup.ps1 -Mode Copy                    # 重新同步所有内容

# === 插件管理 ===
.\scripts\sync-plugins.ps1                # 同步插件
notepad setup.json                        # 配置插件启用/禁用

# === 技能管理 ===
.\scripts\sync-skills.ps1 -Mode Copy      # 只同步技能
.\scripts\skill-source.ps1 -Interactive   # 查询技能来源

# === 诊断和检查 ===
.\scripts\doctor.ps1                      # 检查配置状态
.\scripts\test-agent-config.ps1           # 运行测试

# === 配置编辑 ===
notepad clients\claude\skills.manifest.json  # 编辑技能清单
notepad shared\rules\core.md                 # 编辑核心规则
```

---

## 📖 进一步阅读

- [README.md](../README.md) - 项目主文档
- [COMMANDS.md](COMMANDS.md) - 完整命令参考
- [PLUGIN_MANAGEMENT_CENTER.md](PLUGIN_MANAGEMENT_CENTER.md) - 插件管理详解

---

**最后更新**: 2026-07-09
