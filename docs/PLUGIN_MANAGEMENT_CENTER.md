# 🔌 统一插件管理中心

## 概述

统一插件管理中心是一个集中式插件存储和分发方案，所有插件只存储一份，各平台通过符号链接引用。

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
    ↓ 同步
中心层 (%USERPROFILE%\.localAIPlugins/)
    ↓ 链接
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
                    Junction 符号链接
                         ↓
┌─────────────────────────────────────────────────────────┐
│ 插件中心层 (统一存储)                                    │
│ %USERPROFILE%\.localAIPlugins\                           │
│ └─ understand-anything\ → (指向仓库插件)                 │
│    ├─ agents/                                            │
│    ├─ hooks/                                             │
│    ├─ packages/                                          │
│    └─ skills/                                            │
└─────────────────────────────────────────────────────────┘
           │                 │                 │
      Junction          Junction          Junction
           ↓                 ↓                 ↓
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ 平台层: Claude   │ │ 平台层: Codex    │ │ 平台层: OpenCode │
│ ~/.claude\       │ │ ~/.codex\        │ │ ~/.openCode\     │
│ ├─ plugins/      │ │ ├─ plugins/      │ │ ├─ plugins/      │
│ ├─ skills/       │ │ ├─ skills/       │ │ ├─ skills/       │
│ └─ understand-   │ │ └─ understand-   │ │ └─ understand-   │
│    anything\     │ │    anything\     │ │    anything\     │
│    (链接→中心)   │ │    (链接→中心)   │ │    (链接→中心)   │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

**说明**：
- 插件安装在平台**根目录**下，不是在 `plugins/` 子目录
- `plugins/` 是平台原生的插件目录（如 Claude 原生插件）
- `skills/` 是通过 `setup.ps1` 同步的技能目录
- `understand-anything/` 是通过插件管理中心链接的完整插件

## ✅ 优势

### 1. 统一管理

- **单一数据源**: 所有插件只存储一份
- **版本一致**: 各平台使用相同版本
- **易于更新**: 更新一次，所有平台生效

### 2. 节省空间

- **避免重复**: 不需要在每个平台复制一份
- **磁盘友好**: 大型插件只占用一份空间

### 3. 维护便捷

- **集中备份**: 只需备份 `.localAIPlugins`
- **快速切换**: 可以轻松切换插件版本
- **Git 管理**: 仓库层面的版本控制

## 🚀 使用方法

### 快速开始

```powershell
# 1. 同步插件到中心并链接到各平台
.\scripts\sync-plugins.ps1 -Mode Link

# 2. 同步技能到各平台
.\setup.ps1 -Mode Copy

# 3. 重启 AI 工具
```

### 详细步骤

#### 步骤 1: 同步插件到中心

```powershell
cd E:\Project\codexProject\agent-config

# 使用符号链接模式（推荐）
.\scripts\sync-plugins.ps1 -RepoRoot $PWD -Mode Link

# 或使用复制模式
.\scripts\sync-plugins.ps1 -RepoRoot $PWD -Mode Copy
```

**输出示例**:

```
🔌 插件统一管理系统
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

步骤 1: 同步插件到中心
  ✅ understand-anything (符号链接)

步骤 2: 链接到各平台
  understand-anything:
    ✓ Claude
    ✓ Codex
    ✓ OpenCode

✅ 完成！
```

#### 步骤 2: 验证安装

```powershell
# 检查插件中心
ls $env:USERPROFILE\.localAIPlugins

# 检查各平台链接
ls $env:USERPROFILE\.claude\understand-anything
ls $env:USERPROFILE\.codex\understand-anything
ls $env:USERPROFILE\.openCode\understand-anything
```

#### 步骤 3: 同步技能

```powershell
# 技能仍然通过 setup.ps1 同步
.\setup.ps1 -Mode Copy
```

## 📁 目录结构

### 插件中心目录

```
%USERPROFILE%\.localAIPlugins\
├── understand-anything\        # Junction → 仓库
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
├── plugins\                    # Claude 原生插件目录（保留）
│   └── cache\
│       └── understand-anything # 原生安装的插件
├── skills\                     # 技能目录（setup.ps1 同步）
│   ├── understand\             # Junction → shared/skills/
│   ├── understand-chat\
│   └── ...
├── understand-anything\        # Junction → .localAIPlugins\understand-anything
│   ├── agents\                 # 完整插件（通过插件中心）
│   ├── hooks\
│   ├── packages\
│   └── skills\
└── CLAUDE.md                   # Prompt 文件
```

**注意**：
- Claude 可能有两个 understand-anything：
  - `plugins/cache/understand-anything` - 原生安装（可选，可以删除）
  - `understand-anything` - 插件中心链接（推荐使用）
- Codex/OpenCode 只有插件中心链接的版本
- 插件在平台根目录，技能在 `skills/` 子目录
- **插件包含完整功能**：Skills + Agents + Hooks + Packages + MCP Servers

## 🔧 高级配置

### 自定义插件中心位置

```powershell
# 使用自定义路径
.\scripts\sync-plugins.ps1 -PluginCenterPath "D:\MyAIPlugins"
```

### 选择性同步

编辑 `shared/plugins/` 目录，只保留需要的插件：

```
shared/plugins/
├── understand-anything\     # 会被同步
└── another-plugin\          # 也会被同步
```

### 更新插件

```powershell
# 1. 更新 submodule
cd shared/plugins/understand-anything
git pull origin main

# 2. 重新同步（因为使用符号链接，通常不需要）
# 如果使用 Copy 模式，需要重新运行
cd ../../..
.\scripts\sync-plugins.ps1 -Mode Link
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
.\scripts\sync-plugins.ps1 -Mode Link
```

**方案 B** - 启用开发者模式:

1. 设置 → 更新和安全 → 开发者选项
2. 启用"开发人员模式"
3. 重新运行脚本

**方案 C** - 使用复制模式:

```powershell
.\scripts\sync-plugins.ps1 -Mode Copy
```

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
# 重新同步插件（必须用 Link 模式）
.\scripts\sync-plugins.ps1 -Mode Link

# 如果无法创建符号链接，使用 Copy 模式
.\scripts\sync-plugins.ps1 -Mode Copy

# 重启 AI 工具
```

**根本原因**：
- Skills 依赖 Packages/Core 核心包
- 如果只复制了 skills/ 目录（通过 setup.ps1），会找不到核心包
- 必须通过 sync-plugins.ps1 同步整个插件

### 问题 3: 插件中心和平台不同步

**症状**:

- 更新了仓库，但平台没有生效

**原因**:

- 使用了 Copy 模式而不是 Link 模式

**解决方案**:

```powershell
# 切换到 Link 模式
.\scripts\sync-plugins.ps1 -Mode Link
```

## 📊 对比

### 旧方案 vs 新方案

| 方面                 | 旧方案           | 新方案 (插件中心)  |
| -------------------- | ---------------- | ------------------ |
| **存储位置**   | 各平台独立存储   | 中心统一存储       |
| **磁盘占用**   | 3份 × 插件大小  | 1份插件 + 符号链接 |
| **更新方式**   | 每个平台单独更新 | 更新一次全部生效   |
| **版本一致性** | 可能不一致       | 始终一致           |
| **管理复杂度** | 高               | 低                 |

### 示例

以 understand-anything 插件为例（约 50MB）:

**旧方案**:

```
~/.claude/understand-anything      50MB
~/.codex/understand-anything       50MB
~/.openCode/understand-anything    50MB
总计: 150MB
```

**新方案**:

```
~/.localAIPlugins/understand-anything  50MB (真实存储)
~/.claude/understand-anything          0MB (符号链接)
~/.codex/understand-anything           0MB (符号链接)
~/.openCode/understand-anything        0MB (符号链接)
总计: ~50MB
```

**节省**: 约 100MB (67%)

## 🎯 最佳实践

### 推荐配置

1. **使用 Link 模式** - 实时同步，节省空间
2. **定期更新** - 保持插件最新
3. **备份中心** - 定期备份 `.localAIPlugins`

### 完整工作流

```powershell
# 1. 克隆仓库
git clone --recursive https://github.com/bird-fly/agent-config.git
cd agent-config

# 2. 同步插件到中心
.\scripts\sync-plugins.ps1 -Mode Link

# 3. 同步技能和规则
.\setup.ps1 -Mode Copy

# 4. 重启 AI 工具

# 5. 测试功能
# 在 Claude/Codex/OpenCode 中运行: /understand
```

### 更新工作流

```powershell
# 1. 拉取最新代码
git pull origin main
git submodule update --recursive

# 2. 如果使用 Link 模式，插件自动更新
# 如果使用 Copy 模式：
.\scripts\sync-plugins.ps1 -Mode Copy

# 3. 重新同步技能
.\setup.ps1 -Mode Copy

# 4. 重启 AI 工具
```

## 📝 相关文档

- [README.md](../README.md) - 项目主文档
- [UNDERSTAND_ANYTHING_PLUGIN.md](UNDERSTAND_ANYTHING_PLUGIN.md) - Understand 插件详细说明
- [SKILL_SYNC_MODES.md](SKILL_SYNC_MODES.md) - 技能同步模式配置

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
