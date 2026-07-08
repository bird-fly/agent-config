# 技能同步模式配置

## 📖 概述

你可以为每个技能单独指定同步模式（符号链接 Link 或 复制 Copy），无需全局设置。

## 🎯 使用场景

### 为什么需要分别配置？

1. **Understand 系列技能** - 必须使用 **Link** 模式
   - 原因：依赖 `packages/core` 核心包
   - 如果使用 Copy，技能找不到核心包会报错

2. **普通技能** - 可以使用 **Copy** 模式
   - 原因：独立的技能，没有外部依赖
   - Copy 模式更稳定，不依赖符号链接权限

## ⚙️ 配置方法

### 1. 创建 setup.json

如果还没有 `setup.json`，复制示例配置：

```powershell
Copy-Item setup.example.json setup.json
```

### 2. 编辑 setup.json

```json
{
  "clients": {
    "claude": {
      "promptTarget": "%USERPROFILE%\\.claude\\CLAUDE.md",
      "skillsTarget": "%USERPROFILE%\\.claude\\skills"
    },
    "codex": {
      "promptTarget": "%USERPROFILE%\\.codex\\AGENTS.md",
      "skillsTarget": "%USERPROFILE%\\.codex\\skills"
    },
    "openCode": {
      "promptTarget": "%USERPROFILE%\\.openCode\\AGENTS.md",
      "skillsTarget": "%USERPROFILE%\\.openCode\\skills"
    }
  },
  "skillSyncModes": {
    "description": "指定特定技能的同步模式",
    
    "understand": "Link",
    "understand-chat": "Link",
    "understand-dashboard": "Link",
    "understand-diff": "Link",
    "understand-domain": "Link",
    "understand-explain": "Link",
    "understand-knowledge": "Link",
    "understand-onboard": "Link",
    
    "grill-me": "Copy",
    "triage": "Copy",
    "prototype": "Copy"
  }
}
```

### 3. 运行同步

```powershell
# 使用配置文件中指定的模式
.\setup.ps1

# 或明确指定全局默认模式（未在 skillSyncModes 中配置的技能使用此模式）
.\setup.ps1 -Mode Copy
```

## 📋 配置规则

### 优先级

1. **skillSyncModes** 中的技能配置（最高优先级）
2. **-Mode** 命令行参数
3. **默认值** `Auto`（尝试 Link，失败则 Copy）

### 示例

```powershell
# 场景 1: 使用配置文件
# understand* 使用 Link（配置文件指定）
# 其他技能使用 Copy（命令行参数）
.\setup.ps1 -Mode Copy

# 场景 2: 全部使用 Link
.\setup.ps1 -Mode Link

# 场景 3: 只有配置文件中指定的使用 Link，其他使用 Auto
.\setup.ps1
```

## 🔍 验证配置

同步后，检查实际使用的模式：

```powershell
# 查看同步状态
Get-Content state\install-map.json | ConvertFrom-Json | 
  Select-Object -ExpandProperty clients | 
  Select-Object -ExpandProperty claude | 
  Select-Object -ExpandProperty skills
```

输出示例：

```json
{
  "understand": {
    "source": "E:\\...\\shared\\skills\\understand",
    "destination": "C:\\Users\\...\\skills\\understand",
    "mode": "Link"
  },
  "grill-me": {
    "source": "E:\\...\\shared\\skills\\grill-me",
    "destination": "C:\\Users\\...\\skills\\grill-me",
    "mode": "Copy"
  }
}
```

## 💡 推荐配置

### 最佳实践

```json
{
  "skillSyncModes": {
    "description": "Understand 系列必须 Link，其他可以 Copy",
    
    "understand": "Link",
    "understand-chat": "Link",
    "understand-dashboard": "Link",
    "understand-diff": "Link",
    "understand-domain": "Link",
    "understand-explain": "Link",
    "understand-knowledge": "Link",
    "understand-onboard": "Link"
  }
}
```

然后运行：

```powershell
# 配置的技能用 Link，其他用 Copy
.\setup.ps1 -Mode Copy
```

## ⚠️ 注意事项

### Understand 系列技能

❌ **错误配置**:
```json
{
  "skillSyncModes": {
    "understand": "Copy"  // 错误！会找不到核心包
  }
}
```

✅ **正确配置**:
```json
{
  "skillSyncModes": {
    "understand": "Link"  // 正确！保持符号链接
  }
}
```

### Windows 符号链接权限

如果创建符号链接失败：

1. **使用管理员权限** 运行 PowerShell
2. **或启用开发者模式**:
   - 设置 → 更新和安全 → 开发者选项 → 开发人员模式

3. **或对这些技能使用 Copy**（不推荐 understand 系列）

## 🔧 故障排查

### 问题：Understand 技能找不到核心包

**症状**:
```
Error: Cannot find the understand-anything plugin root.
```

**解决方案**:
```powershell
# 1. 检查配置
Get-Content setup.json | ConvertFrom-Json | 
  Select-Object -ExpandProperty skillSyncModes

# 2. 确保 understand* 都使用 Link
# 编辑 setup.json，设置为 "Link"

# 3. 重新同步
.\setup.ps1 -Mode Copy
```

### 问题：无法创建符号链接

**症状**:
```
New-Item: Administrator privilege required
```

**解决方案**:

**方案 A** - 使用管理员权限:
```powershell
# 以管理员身份运行 PowerShell
.\setup.ps1 -Mode Link
```

**方案 B** - 启用开发者模式后重试

**方案 C** - 对普通技能使用 Copy:
```json
{
  "skillSyncModes": {
    "understand": "Link",
    "grill-me": "Copy"
  }
}
```

## 📚 相关文档

- [README.md](../README.md) - 主文档
- [UNDERSTAND_ANYTHING_PLUGIN.md](UNDERSTAND_ANYTHING_PLUGIN.md) - Understand 插件详细说明
- [COMMANDS.md](COMMANDS.md) - 常用命令速查
