# Understand Anything 插件安装文档

## 概述

Understand Anything 是一个完整的代码库分析插件，可以将任何代码库转换为交互式知识图谱。

- **项目地址**: https://github.com/Lum1104/Understand-Anything
- **安装日期**: 2026-07-08
- **插件版本**: Latest (克隆自主仓库)
- **插件位置**: `shared/plugins/understand-anything`

## 插件类型

Understand Anything 是一个 **Plugin（插件系统）**，而不是单个 Skill。它包含完整的工具链和 8 个独立技能。

## 已安装的技能

所有技能已从插件复制到 `shared/skills/` 目录，并配置到三个平台：

### 1. **understand** ⭐ (核心技能)
分析代码库并生成知识图谱
- 生成 `.understand-anything/knowledge-graph.json`
- 支持增量更新（只重新分析变更文件）
- 多语言支持：`--language zh`（中文）、`ja`（日文）、`ko`（韩文）等

### 2. **understand-dashboard**
交互式可视化看板
- 打开 Web 界面浏览知识图谱
- 颜色编码、可搜索、可点击
- 按架构层分组显示

### 3. **understand-chat**
对话式问答
- 基于知识图谱回答代码库相关问题
- 示例：`/understand-chat 支付流程是如何工作的？`

### 4. **understand-diff**
变更影响分析
- 分析当前更改对系统的影响
- 在提交前查看波及效应

### 5. **understand-explain**
深度代码解释
- 深入分析特定文件或函数
- 示例：`/understand-explain src/auth/login.ts`

### 6. **understand-onboard**
新人入职指南
- 为新团队成员生成入职文档
- 自动生成架构演练

### 7. **understand-domain**
业务领域分析
- 提取业务领域知识（domains, flows, steps）
- 将代码映射到真实业务流程
- 切换到领域视图查看业务流程图

### 8. **understand-knowledge**
知识库分析
- 分析 Karpathy 模式的 LLM wiki
- 生成社区聚类的力导向知识图谱
- 示例：`/understand-knowledge ~/path/to/wiki`

## 安装方式

### 方案 A：符号链接模式（推荐）

✅ **优点**: 
- 保留完整插件结构（包含核心包）
- 更新插件时自动同步所有技能
- 节省磁盘空间

```powershell
# 1. 克隆完整插件到 shared/plugins
cd shared/plugins
git clone https://github.com/Lum1104/Understand-Anything.git understand-anything

# 2. 为所有技能创建符号链接
$pluginSkillsPath = "shared/plugins/understand-anything/understand-anything-plugin/skills"
$targetPath = "shared/skills"
Get-ChildItem $pluginSkillsPath -Directory | ForEach-Object {
    cmd /c mklink /J "$targetPath\$($_.Name)" $_.FullName
}

# 3. 更新配置文件
# 在 clients/{claude,codex,openCode}/skills.manifest.json 中添加所有 understand-* 技能

# 4. 同步到本机（使用Link模式保持符号链接）
.\scripts\sync-skills.ps1 -RepoRoot $PWD -Mode Link
```

### 方案 B：复制模式

⚠️ **缺点**: 会丢失插件核心包，技能可能无法正常工作

```powershell
# 不推荐此方式！技能依赖 packages/core 核心包
```

## 使用示例

### 基础分析
```bash
# 分析当前项目
/understand

# 强制完整重建
/understand --full

# 生成中文内容
/understand --language zh

# 自动更新（每次提交后自动更新图谱）
/understand --auto-update

# 分析子目录（大型 monorepo）
/understand src/frontend
```

### 交互式探索
```bash
# 打开可视化看板
/understand-dashboard

# 对话式问答
/understand-chat 认证流程是如何实现的？

# 分析变更影响
/understand-diff

# 解释特定文件
/understand-explain src/components/UserProfile.tsx
```

### 团队协作
```bash
# 生成入职指南
/understand-onboard

# 分析业务域
/understand-domain

# 分析知识库
/understand-knowledge ~/docs/project-wiki
```

## 工作原理

### 混合分析引擎
- **Tree-sitter (确定性)**: 解析源码，提取结构事实（导入、导出、函数、类）
- **LLM (语义)**: 生成摘要、标签、架构层分配、业务域映射

### 多智能体管道
`/understand` 命令协调 5 个专业智能体：

| 智能体 | 职责 |
|--------|------|
| `project-scanner` | 发现文件，检测语言和框架 |
| `file-analyzer` | 提取函数、类、导入；生成图节点和边 |
| `architecture-analyzer` | 识别架构层 |
| `tour-builder` | 生成引导式学习路径 |
| `graph-reviewer` | 验证图的完整性和引用完整性 |

## 平台兼容性

| 平台 | 状态 | 位置 |
|------|------|------|
| Claude Code | ✅ 已配置 | `~/.claude/skills/understand-*` |
| Codex | ✅ 已配置 | `~/.codex/skills/understand-*` |
| OpenCode | ✅ 已配置 | `~/.opencode/skills/understand-*` |

## 输出位置

所有分析结果保存在项目的 `.understand-anything/` 目录：

```
.understand-anything/
├── knowledge-graph.json      # 主知识图谱文件
├── meta.json                 # 元数据（git commit hash等）
├── config.json               # 配置（autoUpdate, outputLanguage等）
├── intermediate/             # 中间文件（不要提交到Git）
│   ├── scan-result.json
│   ├── batches.json
│   ├── batch-*.json
│   └── assembled-graph.json
└── .understandignore         # 排除规则（类似 .gitignore）
```

## 团队共享建议

### 提交知识图谱到 Git
图谱是 JSON 文件，可以提交到版本控制：

```gitignore
# .gitignore
.understand-anything/intermediate/
.understand-anything/diff-overlay.json
```

```bash
# 提交主图谱和配置
git add .understand-anything/knowledge-graph.json
git add .understand-anything/meta.json
git add .understand-anything/config.json
git add .understand-anything/.understandignore
git commit -m "Add knowledge graph"
```

### 大型图谱处理
对于 >10 MB 的图谱，使用 git-lfs：

```bash
git lfs install
git lfs track ".understand-anything/*.json"
git add .gitattributes .understand-anything/
```

## Token 使用提示

⚠️ **首次分析会消耗大量 tokens**（分析整个代码库）

建议：
- 使用 token 订阅计划运行首次分析
- 或配置本地模型（如 Ollama）
- 后续运行是**增量更新**，只分析变更文件，token 消耗少得多

## 更新插件

使用符号链接模式时，更新非常简单：

```powershell
# 进入插件目录
cd shared/plugins/understand-anything

# 拉取最新版本
git pull origin main

# 由于使用符号链接，技能自动更新！
# 只需重新同步到本机
cd ../..
.\scripts\sync-skills.ps1 -RepoRoot $PWD -Mode Link
```

## 符号链接结构

```
本机技能目录 (~/.claude/skills/understand)
  ↓ Junction
仓库技能目录 (shared/skills/understand)
  ↓ Junction  
插件技能源 (shared/plugins/understand-anything/understand-anything-plugin/skills/understand)
  ↓ 同级目录
插件核心包 (shared/plugins/understand-anything/understand-anything-plugin/packages/core)
```

这种结构确保：
- ✅ 技能能找到核心包（通过相对路径 `../../packages/core`）
- ✅ 一次更新，所有地方生效
- ✅ 支持多平台（Claude、Codex、OpenCode）

## 技能总数统计

- **总技能数**: 41 个
- **Understand 系列**: 8 个
- **Matt Pocock 系列**: 6 个
- **Multica 系列**: 5 个
- **其他核心技能**: 22 个

## 参考资源

- [官方文档](https://understand-anything.com)
- [在线演示](https://understand-anything.com/demo/)
- [GitHub 仓库](https://github.com/Lum1104/Understand-Anything)
- [Egonex AI](https://egonex.ai) - 项目维护者

## 许可证

MIT License © Yuxiang Lin and Infinite Universe, Inc.
