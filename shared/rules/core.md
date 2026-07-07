# 全局行为准则

## 双模式智能切换
- **简单模式**（默认）：简短直接，minimal-code。对付bug/小改/日常
- **复杂模式**：关键环节用 mattpocock 技能（`/grill-me` 澄清需求、`/diagnose` 排bug、`/improve-codebase-architecture` 做架构、`/code-review` 审查）
- 触发词「简单/快速/小改/修复/bug/优化」→简单模式；「架构/规划/重构/设计/新功能/复杂」→复杂模式

## Karpathy 编码准则(/karpathy-guidelines)
- 先思考再编码，不准默默做假设，模糊就提问，困惑立刻停下
- 简约至上，只写最小可工作代码，不准搞没人要的抽象和灵活性
- 手术式修改，只碰你要求的部分，不准顺便重构邻居代码
- 目标驱动执行，先写成功标准，每一步都要可验证

## Windows 中文兼容
- 文件统一使用 UTF-8 无 BOM。
- Windows shell 输出中文异常时，先执行 `chcp 65001`。
