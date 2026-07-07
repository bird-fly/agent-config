# 更新 Matt Pocock 技能 - 操作指南

> 由于 skills.sh 安装器的交互界面问题，我们采用手动方式更新

---

## 🎯 方案：手动从 GitHub 下载

### 步骤 1: 克隆官方仓库到临时目录

```powershell
# 在临时目录克隆仓库
cd $env:TEMP
git clone https://github.com/mattpocock/skills.git mattpocock-skills-temp

# 或者下载 ZIP
# https://github.com/mattpocock/skills/archive/refs/heads/main.zip
```

### 步骤 2: 复制需要的新技能

```powershell
# 设置路径
$tempDir = "$env:TEMP\mattpocock-skills-temp"
$projectDir = "e:\Project\codexProject\agent-config"

# 复制新技能（推荐添加的）
Copy-Item "$tempDir\skills\engineering\ask-matt" "$projectDir\shared\skills\ask-matt" -Recurse -Force
Copy-Item "$tempDir\skills\engineering\research" "$projectDir\shared\skills\research" -Recurse -Force
Copy-Item "$tempDir\skills\engineering\codebase-design" "$projectDir\shared\skills\codebase-design" -Recurse -Force
Copy-Item "$tempDir\skills\productivity\teach" "$projectDir\shared\skills\teach" -Recurse -Force
Copy-Item "$tempDir\skills\engineering\diagnosing-bugs" "$projectDir\shared\skills\diagnosing-bugs" -Recurse -Force
Copy-Item "$tempDir\skills\engineering\code-review" "$projectDir\shared\skills\code-review" -Recurse -Force
Copy-Item "$tempDir\skills\productivity\writing-great-skills" "$projectDir\shared\skills\writing-great-skills" -Recurse -Force
Copy-Item "$tempDir\skills\productivity\grilling" "$projectDir\shared\skills\grilling" -Recurse -Force

# 可选：更新现有技能到最新版本
Copy-Item "$tempDir\skills\engineering\improve-codebase-architecture" "$projectDir\shared\skills\improve-codebase-architecture" -Recurse -Force
Copy-Item "$tempDir\skills\engineering\tdd" "$projectDir\shared\skills\tdd" -Recurse -Force
Copy-Item "$tempDir\skills\productivity\grill-me" "$projectDir\shared\skills\grill-me" -Recurse -Force
Copy-Item "$tempDir\skills\engineering\grill-with-docs" "$projectDir\shared\skills\grill-with-docs" -Recurse -Force

# 清理临时目录
Remove-Item "$tempDir" -Recurse -Force
```

### 步骤 3: 更新 skills.manifest.json

编辑三个客户端的配置文件，添加新技能：

```powershell
# 编辑 Claude
notepad clients\claude\skills.manifest.json

# 编辑 Codex
notepad clients\codex\skills.manifest.json

# 编辑 OpenCode
notepad clients\openCode\skills.manifest.json
```

**添加以下新技能到 "skills" 数组：**

```json
{
  "skills": [
    // ... 现有技能 ...
    
    // 新增的重要技能
    "ask-matt",
    "research",
    "codebase-design",
    "teach",
    "diagnosing-bugs",
    "code-review",
    "writing-great-skills",
    "grilling"
  ]
}
```

### 步骤 4: 同步到本机

```powershell
.\setup.ps1 -Mode Copy
```

### 步骤 5: 验证

```powershell
# 使用分析工具验证
node scripts\analyze-skills.js

# 或查看特定技能
.\scripts\skill-source.ps1 ask-matt
.\scripts\skill-source.ps1 research
```

---

## 📋 新技能详细说明

### 🔴 高优先级（强烈推荐）

#### 1. **ask-matt** ⭐⭐⭐
- **路径：** `skills/engineering/ask-matt/`
- **用途：** 技能路由器，帮你选择合适的技能
- **调用：** `/ask-matt` 或在不确定时使用
- **价值：** 非常实用的导航工具

#### 2. **research** ⭐⭐⭐
- **路径：** `skills/engineering/research/`
- **用途：** 调研技术问题，生成引用文档
- **调用：** 需要研究新技术、库时
- **价值：** 系统化学习工具

#### 3. **codebase-design** ⭐⭐⭐
- **路径：** `skills/engineering/codebase-design/`
- **用途：** 深模块设计规范
- **调用：** 设计模块边界时
- **价值：** 与 improve-codebase-architecture 互补

#### 4. **teach** ⭐⭐
- **路径：** `skills/productivity/teach/`
- **用途：** 多会话教学
- **调用：** `/teach` 学习新技能
- **价值：** 结构化学习工具

### 🟡 中优先级（考虑添加）

#### 5. **diagnosing-bugs**
- **路径：** `skills/engineering/diagnosing-bugs/`
- **用途：** 系统化调试（可能是 diagnose 的更新版）
- **建议：** 对比现有的 `diagnose` 技能
- **决策：** 如果更新，替换现有的

#### 6. **code-review**
- **路径：** `skills/engineering/code-review/`
- **用途：** 双轴代码审查
- **建议：** 对比现有的 requesting/receiving-code-review
- **决策：** 可能需要替换或共存

#### 7. **writing-great-skills**
- **路径：** `skills/productivity/writing-great-skills/`
- **用途：** 编写技能最佳实践
- **建议：** 对比现有的 write-a-skill 和 writing-skills
- **决策：** 考虑替换旧版本

### 🟢 低优先级（可选）

#### 8. **grilling**
- **路径：** `skills/productivity/grilling/`
- **用途：** 可重用的审问循环
- **说明：** grill-me 和 grill-with-docs 的底层
- **决策：** 主要供模型内部使用

---

## 🔍 需要检查的现有技能

### 可能需要替换或更新：

| 现有技能 | 可能的新版本 | 建议 |
|----------|-------------|------|
| `diagnose` | `diagnosing-bugs` | 对比后决定是否替换 |
| `requesting-code-review` | `code-review` | 检查是否被整合 |
| `receiving-code-review` | `code-review` | 检查是否被整合 |
| `write-a-skill` | `writing-great-skills` | 考虑更新 |
| `writing-skills` | `writing-great-skills` | 考虑更新 |
| `find-skills` | `ask-matt` | 考虑替换 |

### 检查方法：

```powershell
# 1. 对比文档内容
code --diff shared\skills\diagnose\SKILL.md shared\skills\diagnosing-bugs\SKILL.md

# 2. 查看文件大小和修改时间
Get-Item shared\skills\diagnose\SKILL.md | Select-Object Name, Length, LastWriteTime
Get-Item shared\skills\diagnosing-bugs\SKILL.md | Select-Object Name, Length, LastWriteTime

# 3. 查看 metadata
Get-Content shared\skills\diagnose\SKILL.md | Select-Object -First 10
Get-Content shared\skills\diagnosing-bugs\SKILL.md | Select-Object -First 10
```

---

## 💡 推荐的更新策略

### 策略 A：保守更新（推荐）⭐

只添加明确缺失的新技能：

```json
{
  "skills": [
    // 保留所有现有技能
    "diagnose",  // 暂时保留
    "grill-me",
    // ... 其他现有技能 ...
    
    // 只添加新技能
    "ask-matt",
    "research",
    "codebase-design",
    "teach"
  ]
}
```

**优点：**
- ✅ 风险最小
- ✅ 现有工作流不受影响
- ✅ 可以慢慢测试新技能

### 策略 B：完全同步

添加所有新技能，替换可能过时的：

```json
{
  "skills": [
    // 新技能
    "ask-matt",
    "research",
    "codebase-design",  
    "teach",
    "diagnosing-bugs",  // 替换 diagnose
    "code-review",  // 替换 requesting/receiving-code-review
    "writing-great-skills",  // 替换 write-a-skill/writing-skills
    "grilling",
    
    // 保留的核心技能
    "grill-me",
    "grill-with-docs",
    "improve-codebase-architecture",
    // ... 其他核心技能 ...
  ]
}
```

**优点：**
- ✅ 使用最新版本
- ✅ 功能最完整

**缺点：**
- ⚠️ 可能有破坏性变更
- ⚠️ 需要适应新的工作流

### 策略 C：渐进式更新（最推荐）✅

1. **第一步：** 添加明确的新技能
   ```json
   "ask-matt",
   "research",
   "codebase-design",
   "teach"
   ```

2. **第二步：** 测试新技能，确保工作正常

3. **第三步：** 逐个对比和替换可能过时的技能
   - 对比 `diagnose` vs `diagnosing-bugs`
   - 对比 code-review 相关技能
   - 对比技能编写工具

4. **第四步：** 清理不再需要的旧技能

---

## 📊 建议的最终技能清单

基于官网 README，推荐的完整技能列表：

### Engineering (用户调用)
```json
"ask-matt",  // 新增 ⭐
"grill-with-docs",
"triage",
"improve-codebase-architecture",
"setup-matt-pocock-skills",
"to-issues",
"to-prd"
```

### Engineering (模型调用)
```json
"prototype",
"diagnosing-bugs",  // 新增/更新 ⭐
"research",  // 新增 ⭐
"tdd",
"codebase-design",  // 新增 ⭐
"code-review"  // 新增/更新 ⭐
```

### Productivity (用户调用)
```json
"grill-me",
"handoff",
"teach",  // 新增 ⭐
"writing-great-skills"  // 新增/更新 ⭐
```

### Productivity (模型调用)
```json
"grilling"  // 新增 ⭐
```

### 其他保留（非官方但有用）
```json
"design-taste-frontend",
"caveman",
"zoom-out",
"systematic-debugging",
"verification-before-completion"
```

---

## ✅ 快速执行方案

### 立即行动（最简单）：

```powershell
# 1. 克隆仓库
cd $env:TEMP
git clone --depth=1 https://github.com/mattpocock/skills.git mp-skills

# 2. 复制核心新技能
$src = "$env:TEMP\mp-skills\skills"
$dst = "e:\Project\codexProject\agent-config\shared\skills"

# 关键新技能
Copy-Item "$src\engineering\ask-matt" "$dst\ask-matt" -Recurse -Force
Copy-Item "$src\engineering\research" "$dst\research" -Recurse -Force
Copy-Item "$src\engineering\codebase-design" "$dst\codebase-design" -Recurse -Force  
Copy-Item "$src\productivity\teach" "$dst\teach" -Recurse -Force

# 3. 编辑配置（手动）
code e:\Project\codexProject\agent-config\clients\claude\skills.manifest.json

# 添加：
# "ask-matt", "research", "codebase-design", "teach"

# 4. 同步
cd e:\Project\codexProject\agent-config
.\setup.ps1 -Mode Copy

# 5. 验证
node scripts\analyze-skills.js

# 6. 清理
Remove-Item $env:TEMP\mp-skills -Recurse -Force
```

---

## 🔄 更新完成后的操作

1. **运行分析工具：**
   ```powershell
   node scripts\analyze-skills.js
   ```

2. **更新技能目录文档：**
   ```powershell
   notepad SKILLS_CATALOG.md
   # 添加新技能的说明
   ```

3. **测试新技能：**
   ```powershell
   # 在 Claude Code 中测试
   /ask-matt
   /research <topic>
   ```

4. **提交更改：**
   ```powershell
   git add .
   git commit -m "feat: 添加 Matt Pocock 最新技能 (ask-matt, research, codebase-design, teach)"
   git push
   ```

---

## 📚 参考资源

- 📘 [官方仓库](https://github.com/mattpocock/skills)
- 📗 [对比文档](Matt-Pocock-技能对比.md)
- 📙 [技能目录](SKILLS_CATALOG.md)
- 📕 [快速参考](SKILLS_QUICK_REFERENCE.md)

---

**准备好更新了吗？选择一个策略开始执行！** 🚀
