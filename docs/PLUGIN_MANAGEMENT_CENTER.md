# 🔌 统一插件管理中心

## 概述

统一插件管理中心是一个集中式插件存储和分发方案，所有插件集中存储在 `.localAi\plugins`，各平台通过符号链接引用技能。

**默认行为**：
- 插件从仓库**复制**到 `.localAi\plugins`（删除项目后仍可用）
- 插件技能从中心**符号链接**到各平台的 `skills/` 目录
- 可在 `setup.json` 中配置插件的启用/禁用

**关键概念**：
- **插件 ≠ 技能**：插件是完整的功能包，包含：
  - Skills（技能命令，如 `/understand`）
  - Agents（子智能体）
  - Hooks（自动化钩子）
  - Packages（核心功能包）
  - MCP Servers（模型上下文协议服务）

- **为什么必须链接整个插件**：
  - Skills 依赖 Packages/Core（核心引擎）
  - Hooks 需要监听 Git 事件
  - Agents 处理复杂任务
  - 单独复制 Skills 会**找不到核心包**，无法工作

- **技能同步 vs 插件同步**：
  - **技能同步**（`setup.ps1`）：同步 `shared/skills/` 中的独立技能
  - **插件同步**（`sync-plugins.ps1`）：同步 `shared/plugins/` 中的完整插件

## 🎯 架构设计

### 三层结构

```
仓库层 (shared/plugins/)
    ↓ 复制到插件中心
中心层 (%USERPROFILE%\.localAi\plugins/)
    ↓ 符号链接技能
平台层 (~/.claude/, ~/.codex/, ~/.openCode/)
```

### 完整路径图

```
┌─────────────────────────────────────────────────────────┐
│ 仓库层 (Git 管理)                                        │
│ E:\Project\...\shared\plugins\understand-anything\       │
│ └─ understand-anything-plugin\                           │
│    ├─ agents/      (9个子智能体)                        │
│    ├─ hooks/       (自动更新钩子)                        │
│    ├─ packages/    (核心包)                             │
│    └─ skills/      (8个技能)                            │
└─────────────────────────────────────────────────────────┘
                         │ 
                    复制到插件中心
                         ↓
┌─────────────────────────────────────────────────────────┐
│ 插件中心层 (统一存储)                                    │
│ %USERPROFILE%\.localAi\plugins\                          │
│ └─ understand-anything\ (独立副本，可删除仓库)           │
│    ├─ agents/                                            │
│    ├─ hooks/                                             │
│    ├─ packages/                                          │
│    │  └─ core/     ← Skills 依赖此核心包                │
│    └─ skills/                                            │
│       ├─ understand/                                     │
│       ├─ understand-chat/                                │
│       └── ...                                             │
└─────────────────────────────────────────────────────────┘
                         │
                    为每个技能创建链接
                         ↓
┌──────────────────────────────────────────────────────────┐
│ 平台层: Claude / Codex / OpenCode                         │
│ ~/.claude\ (示例)                                         │
│ ├─ plugins/      (平台原生插件)                          │
│ └─ skills/       (技能目录)                              │
│    ├─ understand/        → Junction 指向中心              │
│    ├─ understand-chat/   → Junction 指向中心              │
│    ├─ understand-dashboard/ → Junction 指向中心           │
│    └─ ...                                                │
│                                                          │
│ 链接路径示例:                                             │
│ skills/understand → .localAi/plugins/understand-anything/│
│                     skills/understand                    │
└──────────────────────────────────────────────────────────┘
```

**关键点**：
1. **插件整体**复制到 `.localAi\plugins\understand-anything\`
2. **每个技能单独链接**到平台的 `skills/` 目录
3. 技能通过符号链接的相对路径可以访问 `../packages/core/`
4. 所有平台的技能都指向同一个插件中心，保持版本一致
5. **删除项目后插件仍可用**（复制模式）

## ✅ 优势

### 1. 统一管理

- **单一数据源**: 所有插件集中在 `.localAi\plugins`
- **版本一致**: 各平台使用相同版本
- **独立性强**: 删除项目后插件仍可用
- **灵活配置**: 可在 setup.json 中启用/禁用插件

### 2. 维护便捷

- **集中备份**: 只需备份 `.localAi\plugins`
- **自动清理**: 禁用插件时自动清理插件和技能链接
- **易于管理**: 通过配置控制插件同步

## 🚀 使用方法

### 快速开始

```powershell
# 1. 同步插件到中心并链接到各平台
.\scripts\sync-plugins.ps1

# 2. 同步技能到各平台
.\setup.ps1 -Mode Copy

# 3. 重启 AI 工具
```

### 配置插件启用/禁用

```json
// setup.json
{
  "plugins": {
    "understand-anything": true,   // 启用
    "another-plugin": false        // 禁用
  }
}
```

禁用插件后运行 `sync-plugins.ps1`，会自动：
- 删除 `.localAi\plugins\` 中的插件
- 删除各平台 `skills/` 中的技能链接

### 详细步骤

#### 步骤 1: 同步插件到中心

```powershell
cd E:\Project\codexProject\agent-config

# 同步插件到管理中心
.\scripts\sync-plugins.ps1 -RepoRoot $PWD
```

**输出示例**:

```
🔌 插件统一管理系统
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

步骤 1: 同步插件到中心
  ✅ understand-anything (复制)

步骤 2: 链接插件技能到各平台
  understand-anything:
    ✓ Claude: 8 个技能
    ✓ Codex: 8 个技能
    ✓ OpenCode: 8 个技能

✅ 完成！

📊 统计:
  • 同步插件数: 1
  • 插件中心: C:\Users\xxx\.localAi\plugins
  • Claude: 8 个技能
  • Codex: 8 个技能
  • OpenCode: 8 个技能
```

#### 步骤 2: 验证安装

```powershell
# 检查插件中心
ls $env:USERPROFILE\.localAi\plugins

# 检查平台技能链接
ls $env:USERPROFILE\.claude\skills\understand*
ls $env:USERPROFILE\.codex\skills\understand*
ls $env:USERPROFILE\.openCode\skills\understand*

# 验证链接指向
Get-Item $env:USERPROFILE\.claude\skills\understand | Select-Object Name, LinkType, Target
```

#### 步骤 3: 同步其他技能

```powershell
# 同步其他普通技能（非插件技能）
.\setup.ps1 -Mode Copy
```

## 📁 目录结构

### 插件中心目录

```
%USERPROFILE%\.localAi\plugins\
├── understand-anything\        # 复制的插件副本
│   ├── .claude-plugin\        # 插件元数据
│   ├── agents\                # 9个子智能体
│   ├── hooks\                 # 自动化钩子（Git commit监听）
│   ├── packages\              # 核心功能包
│   │   ├── core\             # 分析引擎（Skills依赖此包）
│   │   └── dashboard\        # 可视化面板
│   ├── skills\                # 8个技能
│   └── src\                   # 插件源代码
└── (未来的其他插件)
```

**重要**：
- `skills/` 中的技能**依赖** `packages/core/` 核心包
- 如果只复制 `skills/`，会报错找不到核心包
- 必须链接或复制**整个插件目录**

### 平台目录

```
%USERPROFILE%\.claude\
├── plugins\                    # Claude 原生插件目录
│   └── cache\
│       └── understand-anything # (可选，原生安装的版本)
├── skills\                     # 技能目录（统一管理）
│   ├─ understand\             # Junction → .localAIPlugins/understand-anything/skills/understand
│   ├─ understand-chat\        # Junction → .localAIPlugins/understand-anything/skills/understand-chat
│   ├─ understand-dashboard\   # Junction → .localAIPlugins/understand-anything/skills/understand-dashboard
│   ├─ ... (其他插件技能)
│   ├─ grill-me\               # Junction → shared/skills/grill-me (普通技能)
│   └─ triage\                 # Junction → shared/skills/triage
└── CLAUDE.md                   # Prompt 文件
```

**技能链接的相对路径**：
```
~/.claude/skills/understand/
    → ~/.localAi/plugins/understand-anything/skills/understand/
    → 可访问 ../../packages/core/ (核心包)
```

**说明**：
- 插件的技能和普通技能**混合在同一个 skills/ 目录**
- 插件技能指向 `.localAi/plugins/插件名/skills/技能名`
- 普通技能指向 `shared/skills/技能名`
- 通过符号链接保持相对路径，技能可以访问插件的核心包

## 🔧 高级配置

### 自定义插件中心位置

```powershell
# 使用自定义路径
.\scripts\sync-plugins.ps1 -PluginCenterPath "D:\MyAIPlugins"
```

### 插件启用/禁用配置

在 `setup.json` 中配置：

```json
{
  "plugins": {
    "understand-anything": true,   // 启用
    "another-plugin": false        // 禁用（不同步，且会清理已同步的）
  }
}
```

未在配置中列出的插件默认启用。

### 更新插件

```powershell
# 1. 更新 submodule
cd shared/plugins/understand-anything
git pull origin main

# 2. 重新同步
cd ../../..
.\scripts\sync-plugins.ps1
```

## 🔍 故障排查

### 问题 1: 无法创建符号链接

**症状**:

```
⚠️  无法创建符号链接，尝试复制...
```

**解决方案**:

**方案 A** - 使用管理员权限:

```powershell
# 以管理员身份运行 PowerShell
.\scripts\sync-plugins.ps1
```

**方案 B** - 启用开发者模式:

1. 设置 → 更新和安全 → 开发者选项
2. 启用"开发人员模式"
3. 重新运行脚本

### 问题 2: 平台无法识别插件

**症状**:

- 插件功能无法使用
- /understand 命令不存在
- 报错找不到 `@understand-anything/core` 包

**诊断**:

```powershell
# 检查链接是否正确
Get-Item "$env:USERPROFILE\.codex\understand-anything" | 
  Select-Object FullName, LinkType, Target

# 检查核心包是否存在
Test-Path "$env:USERPROFILE\.codex\understand-anything\packages\core"
```

**解决方案**:

```powershell
# 重新同步插件
.\scripts\sync-plugins.ps1

# 重启 AI 工具
```

**根本原因**：
- Skills 依赖 Packages/Core 核心包
- 如果只复制了 skills/ 目录（通过 setup.ps1），会找不到核心包
- 必须通过 sync-plugins.ps1 同步整个插件

### 问题 3: 插件被禁用后如何重新启用

**解决方案**:

```json
// setup.json - 设置为 true 或删除该配置项
{
  "plugins": {
    "understand-anything": true
  }
}
```

```powershell
# 重新同步
.\scripts\sync-plugins.ps1
```

## 📊 优势对比

### 集中管理 vs 分散安装

| 方面                 | 分散安装         | 集中管理（本方案） |
| -------------------- | ---------------- | ------------------ |
| **存储位置**   | 各平台独立存储   | 中心统一存储       |
| **更新方式**   | 每个平台单独更新 | 更新一次全部生效   |
| **版本一致性** | 可能不一致       | 始终一致           |
| **管理复杂度** | 高               | 低                 |
| **配置灵活性** | 无               | 支持启用/禁用      |
| **项目独立性** | 依赖项目         | 删除项目后仍可用   |

## 🎯 最佳实践

### 推荐配置

1. **使用默认复制模式** - 删除项目后插件仍可用
2. **配置插件启用/禁用** - 在 setup.json 中管理插件
3. **定期更新** - 保持插件最新
4. **备份中心** - 定期备份 `.localAi\plugins`

### 完整工作流

```powershell
# 1. 克隆仓库
git clone --recursive https://github.com/bird-fly/agent-config.git
cd agent-config

# 2. 配置插件（可选）
Copy-Item setup.example.json setup.json
# 编辑 setup.json 中的 plugins 配置

# 3. 同步插件到中心
.\scripts\sync-plugins.ps1

# 4. 同步技能和规则
.\setup.ps1 -Mode Copy

# 5. 重启 AI 工具

# 6. 测试功能
# 在 Claude/Codex/OpenCode 中运行: /understand
```

### 更新工作流

```powershell
# 1. 拉取最新代码
git pull origin main
git submodule update --recursive

# 2. 重新同步插件
.\scripts\sync-plugins.ps1

# 3. 重新同步技能
.\setup.ps1 -Mode Copy

# 4. 重启 AI 工具
```

## 📝 相关文档

- [README.md](../README.md) - 项目主文档
- [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) - 项目概述和架构（包含技能同步模式说明）
- [COMMANDS.md](COMMANDS.md) - 常用命令速查
- [COMMANDS.md](COMMANDS.md) - 常用命令速查

## 🔮 未来扩展

### 支持更多插件

在 `shared/plugins/` 添加新插件：

```
shared/plugins/
├── understand-anything\
├── another-plugin\          # 新插件
└── third-plugin\            # 又一个插件
```

运行同步：

```powershell
.\scripts\sync-plugins.ps1 -Mode Link
```

所有插件都会自动同步到中心并链接到各平台！

### 插件版本管理

使用 git submodule 管理插件版本：

```bash
# 切换到特定版本
cd shared/plugins/understand-anything
git checkout v2.8.2

# 或更新到最新
git checkout main
git pull
```

## 🎉 总结

插件管理中心提供了：

- ✅ 统一的插件存储
- ✅ 多平台同步支持
- ✅ 节省磁盘空间
- ✅ 简化维护流程
- ✅ 版本一致性保证

这是管理多平台 AI 工具插件的最佳实践！
