# Matt Pocock 技能对比 - 官网 vs 本项目

> 更新日期：2026-07-07  
> 官方仓库：https://github.com/mattpocock/skills

---

## 📊 技能对比总览

### 官网最新技能列表（2024+）

根据 Matt Pocock 官方 GitHub 仓库 README（最后更新 2024+），技能分为两大类：

#### 🔧 **Engineering（工程类）**

**User-invoked（用户调用）：**
1. ✨ **ask-matt** ⭐ [新增] - 询问哪个技能适合你的情况，技能路由器
2. ✅ **grill-with-docs** - 带文档的审问（更新 CONTEXT.md 和 ADRs）
3. ✅ **triage** - Issue 分流状态机
4. ✅ **improve-codebase-architecture** - 扫描代码库深化机会，生成 HTML 报告
5. ✅ **setup-matt-pocock-skills** - 配置工程技能环境
6. ✅ **to-issues** - 将计划转换为独立 issues（垂直切片）
7. ✅ **to-prd** - 将对话转换为 PRD

**Model-invoked（模型调用）：**
1. ✅ **prototype** - 构建原型（终端应用或 UI 变体）
2. ✨ **diagnosing-bugs** ⭐ [重命名] - 系统化调试循环（之前叫 diagnose）
3. ✨ **research** ⭐ [新增] - 调研问题，生成引用的 Markdown 文档
4. ✅ **tdd** - 测试驱动开发（红-绿-重构）
5. ✨ **domain-modeling** ⭐ [新增] - 主动构建和完善项目领域模型
6. ✨ **codebase-design** ⭐ [新增] - 深模块设计的共享规范和词汇
7. ✨ **code-review** ⭐ [新增] - 双轴代码审查（标准 + 规格）

#### 🎨 **Productivity（生产力类）**

**User-invoked（用户调用）：**
1. ✅ **grill-me** - 对计划或设计进行无情审问
2. ✅ **handoff** - 压缩对话为交接文档
3. ✨ **teach** ⭐ [新增] - 多会话教学新技能或概念
4. ✨ **writing-great-skills** ⭐ [新增] - 编写优秀技能的参考指南

**Model-invoked（模型调用）：**
1. ✨ **grilling** ⭐ [新增] - 可重用的审问循环（grill-me 和 grill-with-docs 的底层）

---

## 🆚 与本项目技能对比

### ✅ 本项目已有的技能

| 技能名 | 状态 | 官网分类 |
|--------|------|----------|
| `grill-me` | ✅ 已有 | Productivity (用户调用) |
| `grill-with-docs` | ✅ 已有 | Engineering (用户调用) |
| `triage` | ✅ 已有 | Engineering (用户调用) |
| `improve-codebase-architecture` | ✅ 已有 | Engineering (用户调用) |
| `setup-matt-pocock-skills` | ✅ 已有 | Engineering (用户调用) |
| `to-issues` | ✅ 已有 | Engineering (用户调用) |
| `to-prd` | ✅ 已有 | Engineering (用户调用) |
| `prototype` | ✅ 已有 | Engineering (模型调用) |
| `tdd` | ✅ 已有 | Engineering (模型调用) |
| `handoff` | ✅ 已有 | Productivity (用户调用) |

### 🆕 官网新增的技能（本项目缺失）

#### **Engineering 类：**

1. **ask-matt** ⭐ 重要
   - **用途：** 技能路由器，帮你选择合适的技能
   - **何时使用：** 不确定用哪个技能时
   - **建议：** 强烈推荐添加，非常实用

2. **diagnosing-bugs** ⭐ 重要（之前叫 diagnose）
   - **用途：** 系统化调试循环
   - **状态：** 本项目有 `diagnose` 和 `systematic-debugging`
   - **建议：** 检查是否为同一技能的不同名称

3. **research** ⭐ 新增
   - **用途：** 调研问题，生成引用文档
   - **何时使用：** 需要研究新技术、库或概念
   - **建议：** 推荐添加，对学习新技术很有帮助

4. **domain-modeling** ⭐ 新增
   - **用途：** 主动构建领域模型，更新 CONTEXT.md
   - **关系：** 类似 `grill-with-docs` 的功能分离版
   - **建议：** 考虑添加，增强领域建模能力

5. **codebase-design** ⭐ 新增
   - **用途：** 深模块设计的共享规范
   - **关系：** 与 `improve-codebase-architecture` 互补
   - **建议：** 推荐添加，完善架构工具链

6. **code-review** ⭐ 重要
   - **用途：** 双轴代码审查（标准 + 规格）
   - **状态：** 本项目有 `requesting-code-review` 和 `receiving-code-review`
   - **建议：** 检查是否为相同功能，可能需要更新

#### **Productivity 类：**

7. **teach** ⭐ 新增
   - **用途：** 多会话教学
   - **何时使用：** 学习新技能或概念
   - **建议：** 推荐添加，对学习很有帮助

8. **writing-great-skills** ⭐ 新增
   - **用途：** 编写技能的最佳实践指南
   - **关系：** 可能替代或增强 `write-a-skill` 和 `writing-skills`
   - **建议：** 推荐添加或更新现有技能

9. **grilling** ⭐ 新增
   - **用途：** 可重用的审问循环
   - **关系：** `grill-me` 和 `grill-with-docs` 的底层实现
   - **建议：** 可选，主要供模型内部使用

---

## 🔍 本项目特有的技能（官网未提及）

### 可能不在官方仓库的技能：

| 技能名 | 可能原因 |
|--------|----------|
| `diagnose` | 可能被重命名为 `diagnosing-bugs` |
| `systematic-debugging` | 可能是更早版本或社区贡献 |
| `test-driven-development` | 可能与 `tdd` 重复 |
| `receiving-code-review` | 可能被整合到新的 `code-review` |
| `requesting-code-review` | 可能被整合到新的 `code-review` |
| `zoom-out` | 可能是旧版本或社区贡献 |
| `find-skills` | 可能被 `ask-matt` 替代 |
| `write-a-skill` | 可能被 `writing-great-skills` 替代 |
| `writing-skills` | 可能被 `writing-great-skills` 替代 |
| `caveman` | 未在 README 主列表中，但在仓库中存在 |
| `design-taste-frontend` | 可能是社区贡献或专项技能 |
| `dispatching-parallel-agents` | 可能是社区贡献 |
| `verification-before-completion` | 可能是社区贡献 |

---

## 📋 推荐行动清单

### 🔴 高优先级（强烈推荐添加）

1. ✨ **ask-matt** - 技能路由器，非常实用
2. ✨ **research** - 调研工具，学习新技术必备
3. ✨ **codebase-design** - 完善架构设计工具链
4. ✨ **teach** - 学习工具，提升技能

### 🟡 中优先级（考虑添加）

5. ✨ **domain-modeling** - 增强领域建模能力
6. ✨ **writing-great-skills** - 更新或替代现有技能编写工具

### 🟢 低优先级（可选）

7. ✨ **grilling** - 主要供模型内部使用
8. 🔄 检查 `diagnosing-bugs` vs `diagnose` 是否为同一技能
9. 🔄 检查 `code-review` vs `requesting/receiving-code-review` 的关系

---

## 🔄 技能更新建议

### 方案 A：完全同步官网（激进）

```powershell
# 1. 备份当前配置
Copy-Item clients\claude\skills.manifest.json clients\claude\skills.manifest.json.backup

# 2. 使用 skills.sh 安装器
npx skills@latest add mattpocock/skills

# 3. 选择所有新技能
# 4. 对比差异并决定保留哪些旧技能
```

### 方案 B：选择性添加（保守）

```powershell
# 手动下载新技能到 shared/skills/
# 然后添加到 manifest

# 1. 添加 ask-matt
# 2. 添加 research
# 3. 添加 codebase-design
# 4. 添加 teach
```

### 方案 C：检查并更新（推荐）⭐

```powershell
# 1. 检查现有技能是否需要更新
#    - diagnose → diagnosing-bugs?
#    - code-review 相关技能
#    - write-a-skill → writing-great-skills?

# 2. 添加明确缺失的新技能
#    - ask-matt (强烈推荐)
#    - research
#    - codebase-design
#    - teach

# 3. 保留非官方但有用的技能
#    - systematic-debugging
#    - zoom-out
#    - caveman
```

---

## 📊 技能数量对比

| 类别 | 官网 | 本项目 | 差异 |
|------|------|--------|------|
| **Engineering (用户调用)** | 7 | 7 | 0 |
| **Engineering (模型调用)** | 7 | 3 | +4 (缺少) |
| **Productivity (用户调用)** | 4 | 2 | +2 (缺少) |
| **Productivity (模型调用)** | 1 | 0 | +1 (缺少) |
| **其他/社区** | ? | 8+ | - |
| **总计** | ~19 | 14+ | - |

---

## 🔗 相关资源

- 📘 [Matt Pocock Skills 官方仓库](https://github.com/mattpocock/skills)
- 📗 [Skills.sh 安装器](https://skills.sh/mattpocock/skills)
- 📙 [AI Hero 技能目录](https://www.aihero.dev/skills-catalog)
- 📕 [Newsletter 订阅](https://www.aihero.dev/s/skills-newsletter)

---

## 💡 下一步

### 立即行动：

```powershell
# 1. 查看当前技能
.\scripts\skill-source.ps1 -BySource

# 2. 决定是否添加新技能
#    推荐优先添加：ask-matt, research, codebase-design

# 3. 使用 skills.sh 安装器或手动下载
npx skills@latest add mattpocock/skills
```

### 保持更新：

- 📧 订阅 Matt Pocock 的 newsletter
- ⭐ Star GitHub 仓库以获取更新通知
- 🔍 定期运行本文档的检查流程

---

**最后更新：** 2026-07-07  
**来源：** https://raw.githubusercontent.com/mattpocock/skills/main/README.md

