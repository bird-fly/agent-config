# agent-config Commands

本文件汇总本项目常用 PowerShell 命令。默认从仓库根目录执行。

## 🔌 插件管理命令

### 同步插件到管理中心

```powershell
# 同步所有插件到 %USERPROFILE%\.localAi\plugins
.\scripts\sync-plugins.ps1

# 使用指定配置文件
.\scripts\sync-plugins.ps1 -ConfigPath .\setup.json

# 自定义插件中心路径
.\scripts\sync-plugins.ps1 -PluginCenterPath "D:\MyAIPlugins"
```

### 配置插件启用/禁用

```powershell
# 编辑配置文件
notepad setup.json

# 示例配置：
# {
#   "plugins": {
#     "understand-anything": true,   // 启用
#     "another-plugin": false        // 禁用
#   }
# }

# 重新同步
.\scripts\sync-plugins.ps1
```

说明：

- 禁用插件会自动删除插件中心和各平台的相关文件
- 未配置的插件默认启用
- 插件始终复制到中心，删除项目后仍可用

## 📚 技能管理命令

### 查看技能来源和归属

```powershell
# 查看单个技能
.\scripts\skill-source.ps1 grill-me

# 列出所有技能
.\scripts\skill-source.ps1 -All

# 按来源分组
.\scripts\skill-source.ps1 -BySource

# 交互模式（推荐）
.\scripts\skill-source.ps1 -Interactive
```

**输出示例**：

```
╔═══════════════════════════════════════════════════════════╗
║           技能详情 - grill-me                              ║
╚═══════════════════════════════════════════════════════════╝

📛 名称: grill-me
📝 描述: 对计划或设计进行无情审问
📁 分类: Matt Pocock
📦 来源: Matt Pocock
📄 文档: shared\skills\grill-me\SKILL.md
```

### 管理技能启用/禁用

```powershell
# 编辑客户端技能配置
# Claude Code
notepad clients\claude\skills.manifest.json

# Codex
notepad clients\codex\skills.manifest.json

# OpenCode
notepad clients\openCode\skills.manifest.json
```

### 查看技能详情

```powershell
# 查看特定技能的文档
Get-Content shared\skills\{skill-name}\SKILL.md

# 示例：查看 grill-me 技能
Get-Content shared\skills\grill-me\SKILL.md

# 查看所有技能列表
Get-ChildItem shared\skills -Directory | Select-Object Name
```

---

## 首次安装或新电脑

使用项目内的规则和 skills 初始化或重置当前用户的 Codex、Claude Code、openCode：

```powershell
.\setup.ps1 -Mode Copy
```

说明：

- 默认读取 `setup.json`；如果不存在，则读取 `setup.example.json`。
- `setup.example.json` 使用 `%USERPROFILE%`，适合新电脑直接运行。
- `Copy` 模式最稳，不依赖 Windows 链接权限。

如果需要自定义安装路径：

```powershell
Copy-Item setup.example.json setup.json
notepad setup.json
.\setup.ps1 -Mode Copy
```

## 覆盖本机已安装 skills

用本项目 `shared/skills/` 和 `clients/<client>/skills.manifest.json` 覆盖客户端 skills 目录，让本机以项目为准：

```powershell
.\setup.ps1 -Mode Copy
```

覆盖规则：

- 目标目录不存在：直接复制。
- 目标目录已有同名 skill，且 `SKILL.md` 的 `name:` 匹配：覆盖为项目版本。
- 目标目录里存在 manifest 外的本地 skill，且 `SKILL.md` 的 `name:` 和目录名一致：删除。
- 目标目录里存在系统目录、没有 `SKILL.md` 的目录，或 `name:` 不匹配的目录：跳过，避免误删非 skill 内容。

## 导入本机已有 skills 到项目

把当前机器上已经安装的 skills 导入到 `shared/skills/`，并追加到各客户端 manifest：

```powershell
.\setup.ps1 -ImportInstalledSkills -Mode Copy
```

也可以分两步执行：

```powershell
.\scripts\import-installed-skills.ps1 -RepoRoot .
.\setup.ps1 -Mode Copy
```

导入规则：

- 默认扫描 `%USERPROFILE%\.agents\skills`、`.codex\skills`、`.claude\skills`、`.openCode\skills`。
- 只有包含 `SKILL.md` 的目录才会被当作 skill。
- `SKILL.md` 的 `name:` 必须和目录名一致，否则跳过。
- 同名 skill 只保留第一个；如果 `shared/skills/<name>` 已存在，不覆盖已有项目版本。

## 只生成 prompt 文件

只从规则源生成各客户端 prompt，不同步 skills：

```powershell
.\scripts\build-prompts.ps1 -RepoRoot .
```

使用指定配置文件：

```powershell
.\scripts\build-prompts.ps1 -RepoRoot . -ConfigPath .\setup.json
```

生成逻辑：

- 共享规则来自 `shared/rules/core.md`、`workflow.md`、`frontend-design.md`。
- 客户端规则来自 `clients/<client>/rules/*.md`。
- 生成到 `generated/<client>/AGENTS.md` 或 `generated/<client>/CLAUDE.md`。
- 如果配置了 `promptTarget`，会同时部署到目标路径。

## 只同步 skills

只同步 manifest 中声明的 skills，不重新生成 prompt：

```powershell
.\scripts\sync-skills.ps1 -RepoRoot . -Mode Copy
```

使用链接优先，失败后自动复制：

```powershell
.\scripts\sync-skills.ps1 -RepoRoot . -Mode Auto
```

强制使用链接：

```powershell
.\scripts\sync-skills.ps1 -RepoRoot . -Mode Link
```

说明：

- `Copy`：删除并复制 manifest 内的目标 skill 目录，最稳定；同时清理 manifest 外的本地 skill。
- `Auto`：优先创建 Junction/HardLink，失败后复制。
- `Link`：只尝试链接；链接失败会报错。

## 检查当前安装状态

检查源目录、生成文件、目标 prompt、同步后的 skills 和 `state/install-map.json`：

```powershell
.\scripts\doctor.ps1 -RepoRoot .
```

使用指定配置：

```powershell
.\scripts\doctor.ps1 -RepoRoot . -ConfigPath .\setup.json
```

## 跳过 doctor

生成 prompt 并同步 skills，但不执行最终检查：

```powershell
.\setup.ps1 -Mode Copy -SkipDoctor
```

一般不推荐跳过；只有在你明确知道目标客户端目录暂时不可访问时使用。

## 运行项目脚本测试

运行临时目标目录下的集成测试：

```powershell
.\scripts\test-agent-config.ps1 -RepoRoot .
```

测试会使用 `generated/_test-targets`，并会备份/恢复 `state/install-map.json`，避免污染本机同步状态。

## 单独使用 link-or-copy

把一个源目录复制或链接到目标目录：

```powershell
.\scripts\link-or-copy.ps1 -Source .\shared\skills\diagnose -Destination "$env:USERPROFILE\.codex\skills\diagnose" -Mode Copy
```

一般不需要手动调用该脚本；它主要由 `sync-skills.ps1` 调用。

## 推荐日常流程

修改规则后：

```powershell
.\setup.ps1 -Mode Copy
```

修改 skill 后：

```powershell
.\setup.ps1 -Mode Copy
```

修改脚本后：

```powershell
.\scripts\test-agent-config.ps1 -RepoRoot .
```

新电脑部署：

```powershell
.\setup.ps1 -Mode Copy
```

从本机反向导入已有 skills：

```powershell
.\setup.ps1 -ImportInstalledSkills -Mode Copy
```

## 常见判断

- 想让项目覆盖本机客户端配置：用 `.\setup.ps1 -Mode Copy`。
- 想把本机已有 skills 纳入项目维护：用 `.\setup.ps1 -ImportInstalledSkills -Mode Copy`。
- 只想检查有没有同步成功：用 `.\scripts\doctor.ps1 -RepoRoot .`。
- 只想测试脚本逻辑：用 `.\scripts\test-agent-config.ps1 -RepoRoot .`。
- 不确定用哪个模式：优先用 `-Mode Copy`。
