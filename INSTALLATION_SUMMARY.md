# 🎉 Understand-Anything 插件安装完成

> 安装日期：2026-07-08 | 最后提交：d87f88d

## ✅ 安装概览

### 插件结构
- **方式**: Git Submodule + Junction 符号链接
- **位置**: `shared/plugins/understand-anything`
- **优势**: 保留完整插件（含 `packages/core` 核心包）

### 同步状态
已同步到三个平台：
- ✅ Claude Code (`~/.claude/skills/`)
- ✅ Codex (`~/.codex/skills/`)
- ✅ OpenCode (`~/.opencode/skills/`)

## 📦 8 个技能

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

## 🚀 快速开始

```bash
# 分析项目生成知识图谱
/understand

# 打开可视化看板
/understand-dashboard

# 对话式问答
/understand-chat 认证系统是如何工作的？

# 中文输出
/understand --language zh
```

## 🔄 更新插件

```powershell
cd shared/plugins/understand-anything
git pull origin main
cd ../..
.\scripts\sync-skills.ps1 -RepoRoot $PWD -Mode Link
```

## 📖 相关文档

- [完整使用指南](docs/UNDERSTAND_ANYTHING_PLUGIN.md)
- [官方文档](https://understand-anything.com)
- [在线演示](https://understand-anything.com/demo/)

## ⚠️ 重要提示

- **Token 消耗**: 首次分析消耗大量 tokens，建议使用订阅或本地模型
- **增量更新**: 后续自动增量，只分析变更文件
- **构建依赖**: 需要 Node.js ≥ 22 和 pnpm ≥ 10

## 💡 常见问题

**Q: 技能找不到核心包？**  
A: 使用符号链接模式：`.\setup.ps1 -Mode Link`

**Q: 核心包构建失败？**  
A: 检查依赖：`node --version` 和 `pnpm --version`

---

📌 **详细文档**: [docs/UNDERSTAND_ANYTHING_PLUGIN.md](docs/UNDERSTAND_ANYTHING_PLUGIN.md)  
🔗 **仓库**: https://github.com/bird-fly/agent-config
