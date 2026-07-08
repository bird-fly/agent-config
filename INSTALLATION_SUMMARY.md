# 🎉 Understand-Anything 插件安装成功！

## ✅ 已完成

### 1. 插件安装
- ✅ 将 [Understand-Anything](https://github.com/Lum1104/Understand-Anything) 作为 **git submodule** 添加到 `shared/plugins/`
- ✅ 使用 **Junction 符号链接** 连接 8 个技能到 `shared/skills/`
- ✅ 保留完整插件结构，包含 `packages/core` 核心包

### 2. 多平台同步
已成功同步到：
- ✅ **Claude Code** (`~/.claude/skills/`)
- ✅ **Codex** (`~/.codex/skills/`)
- ✅ **OpenCode** (`~/.opencode/skills/`)

### 3. 技能配置
已在所有三个平台的 `skills.manifest.json` 中添加：

| 技能名 | 功能描述 |
|--------|----------|
| `understand` | 核心分析 - 生成代码库知识图谱 |
| `understand-chat` | 对话问答 - 基于知识图谱回答问题 |
| `understand-dashboard` | 可视化看板 - 交互式浏览知识图谱 |
| `understand-diff` | 变更影响 - 分析代码变更的影响范围 |
| `understand-domain` | 业务域分析 - 提取业务流程和领域知识 |
| `understand-explain` | 深度解释 - 深入分析特定文件或函数 |
| `understand-knowledge` | 知识库分析 - 分析 wiki 知识库 |
| `understand-onboard` | 入职指南 - 生成新人入职文档 |

## 📊 技能统计

- **总技能数**: 41 个
- **Understand 系列**: 8 个（新增 7 个）
- **Matt Pocock 系列**: 6 个
- **Multica 系列**: 5 个
- **其他核心技能**: 22 个

## 🏗️ 符号链接结构

```
本机 (~/.claude/skills/understand)
  ↓ Junction
仓库 (shared/skills/understand)
  ↓ Junction  
插件源 (shared/plugins/understand-anything/.../skills/understand)
  ↓ 同级目录
核心包 (shared/plugins/understand-anything/.../packages/core) ✅
```

**关键优势**:
- ✅ 技能能找到核心包（通过相对路径解析）
- ✅ 一次更新插件，所有地方自动生效
- ✅ 节省磁盘空间（符号链接而非多次复制）
- ✅ Git submodule 管理，版本可追溯

## 📖 使用指南

### 快速开始

```bash
# 1. 分析当前项目（生成知识图谱）
/understand

# 2. 打开可视化看板
/understand-dashboard

# 3. 对话式问答
/understand-chat 认证系统是如何工作的？
```

### 进阶功能

```bash
# 生成中文内容
/understand --language zh

# 分析变更影响
/understand-diff

# 生成入职指南
/understand-onboard

# 分析业务域
/understand-domain
```

## 🔄 更新插件

```powershell
# 1. 更新 submodule
cd shared/plugins/understand-anything
git pull origin main

# 2. 由于使用符号链接，技能自动更新
# 只需重新同步到本机
cd ../..
.\scripts\sync-skills.ps1 -RepoRoot $PWD -Mode Link
```

## 📝 相关文档

- [Understand Anything 插件文档](docs/UNDERSTAND_ANYTHING_PLUGIN.md) - 完整的安装和使用指南
- [智能体安装指南](docs/AGENT_INSTALLATION_GUIDE.md) - 插件 vs 技能的区别
- [官方文档](https://understand-anything.com)
- [在线演示](https://understand-anything.com/demo/)

## 🚀 下一步

1. **首次分析**: 在你的项目中运行 `/understand` 生成知识图谱
2. **探索看板**: 使用 `/understand-dashboard` 可视化浏览
3. **提交图谱**: 如果需要团队共享，可以将 `.understand-anything/knowledge-graph.json` 提交到 Git

## ⚠️ 注意事项

- **Token 消耗**: 首次分析会消耗大量 tokens（分析整个代码库），建议使用订阅计划或本地模型
- **增量更新**: 后续运行自动增量更新，只分析变更文件，token 消耗少得多
- **构建依赖**: 技能首次运行时会自动构建核心包（需要 Node.js ≥ 22 和 pnpm ≥ 10）

## 🎯 常见问题

### Q: 技能找不到核心包怎么办？
A: 确保使用了符号链接模式（`-Mode Link`），技能会自动通过相对路径找到核心包。

### Q: 如何在其他项目中使用？
A: 直接克隆此仓库：
```bash
git clone --recursive https://github.com/bird-fly/agent-config
cd agent-config
.\setup.ps1 -Mode Link
```

### Q: 核心包构建失败？
A: 确保安装了 Node.js ≥ 22 和 pnpm ≥ 10：
```bash
node --version
pnpm --version
```

---

**安装完成时间**: 2026-07-08  
**最后提交**: c78a744  
**仓库**: https://github.com/bird-fly/agent-config
