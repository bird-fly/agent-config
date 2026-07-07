# agent-config

Shared agent configuration repo for Codex, Claude Code, and future clients such as openCode.

## Goals

- Maintain one source of truth for shared rules and custom skills.
- Generate client-specific prompt entry files such as `AGENTS.md` and `CLAUDE.md`.
- Sync shared skills into each client's expected local directory, using the project manifest as the source of truth.
- Prefer links where safe, fall back to copy on Windows.

## Layout

- `shared/`: source of truth for reusable rules, skills, and snippets.
- `clients/`: per-client rules and skill manifests.
- `generated/`: built output files for each client.
- `scripts/`: helper scripts used by `setup.ps1`.
- `state/`: local install metadata and last-known sync mode.
- `docs/`: documentation and guides.

## 🆕 技能管理系统 (New!)

下载了很多技能不知道如何管理？我们提供了完整的技能管理工具：

- 📊 **自动分析工具** - 识别技能分类、依赖关系和启用状态
- 📖 **分类文档** - 完整的技能目录和说明
- 🎯 **快速参考** - 一页纸搞定常用操作

**快速开始：**
```powershell
# 查看技能分析报告
node scripts\analyze-skills.js

# 查看完整文档
Get-Content README_SKILLS.md
```

**相关文档：**
- [技能管理入门](README_SKILLS.md) - 从这里开始
- [快速参考卡](SKILLS_QUICK_REFERENCE.md) - 常用命令速查
- [完整分类目录](SKILLS_CATALOG.md) - 所有技能列表
- [详细管理指南](docs/SKILLS_MANAGEMENT.md) - 深入指南

---

## Bootstrap

Run from the repo root:

```powershell
./setup.ps1
```

`setup.ps1` reads `setup.json` when present, otherwise it falls back to `setup.example.json`.

## Scripts

- `scripts/build-prompts.ps1`: builds `generated/<client>/AGENTS.md` or `CLAUDE.md` from `shared/rules/*.md` plus `clients/<client>/rules/*.md`, then deploys prompt files to configured targets.
- `scripts/sync-skills.ps1`: syncs manifest-listed skills from `shared/skills/` into each configured client skills directory and removes local skills that are not listed in the manifest.
- `scripts/link-or-copy.ps1`: tries directory links by default and falls back to copy; pass `-Mode Copy` for deterministic copy deployment.
- `scripts/import-installed-skills.ps1`: scans installed skill folders, imports unique skills into `shared/skills/`, and appends them to every client manifest.
- `scripts/doctor.ps1`: checks source layout, generated prompts, configured prompt targets, synced skills, and `state/install-map.json`.
- `scripts/test-agent-config.ps1`: runs the scripts against temporary targets under `generated/_test-targets`.

## Import Installed Skills

To import already-installed skills from `.agents`, `.codex`, `.claude`, and `.openCode`:

```powershell
.\scripts\import-installed-skills.ps1 -RepoRoot .
.\setup.ps1 -Mode Copy
```

Or do both in one command:

```powershell
.\setup.ps1 -ImportInstalledSkills -Mode Copy
```

The importer only treats directories containing `SKILL.md` as skills. If the same skill name appears in multiple source folders, the first one wins and later duplicates are skipped. If a skill already exists in `shared/skills/`, it is kept and only the manifests are updated.

Paths in `setup.json` may use Windows environment variables such as `%USERPROFILE%`. Prompt targets are validated against the expected client file name, and skill sync treats each client manifest as authoritative. It overwrites same-name skills with the project version, removes extra local skill directories whose `SKILL.md` metadata matches their directory name, skips non-skill directories such as system folders, and refuses to overwrite unmanaged same-name destinations.

---

# 中文说明

`agent-config` 用来让 Codex、Claude Code 和后续 openCode 共用一套规则与自定义 skills。

## 目录作用

- `shared/rules/`：共享规则源，只改这里，不直接改生成后的 prompt。
- `shared/skills/`：共享 skill 源，所有客户端从这里同步。
- `clients/`：每个客户端自己的专属规则和 `skills.manifest.json`。
- `generated/`：生成结果，可以删除重建，不要手改。
- `scripts/`：生成、同步、导入和检查脚本。
- `state/`：记录上次同步状态。

## 常用命令

从项目根目录执行：

```powershell
cd E:\Project\codexProject\agent-config
.\setup.ps1 -Mode Copy
```

这会生成 prompt、同步 skills，并运行 doctor 校验。同步 skills 时以项目 manifest 为准：项目里有的会覆盖到本机，项目 manifest 里没有的本机 skill 会被删除；系统目录、没有 `SKILL.md` 的目录、metadata 不匹配的目录会跳过，避免误删非 skill 内容。

## 导入已安装 skills

自动扫描这些目录：

```text
%USERPROFILE%\.agents\skills
%USERPROFILE%\.codex\skills
%USERPROFILE%\.claude\skills
%USERPROFILE%\.openCode\skills
```

导入到 `shared/skills/`：

```powershell
.\scripts\import-installed-skills.ps1
.\setup.ps1 -Mode Copy
```

也可以一步完成：

```powershell
.\setup.ps1 -ImportInstalledSkills -Mode Copy
```

导入规则：

- 只有包含 `SKILL.md` 的目录才算 skill。
- `SKILL.md` 中的 `name:` 必须和目录名一致，否则跳过。
- 同名 skill 会过滤，先扫描到的版本保留。
- 如果 `shared/skills/<skill-name>` 已存在，不覆盖，只更新 manifest。
- 导入后会自动追加到每个客户端的 `skills.manifest.json`。

## 修改规则

修改：

```text
shared/rules/core.md
shared/rules/workflow.md
shared/rules/frontend-design.md
clients/codex/rules/codex.md
clients/claude/rules/claude.md
clients/openCode/rules/openCode.md
```

然后重新同步：

```powershell
.\setup.ps1 -Mode Copy
```

## 修改 skill

修改：

```text
shared/skills/<skill-name>/SKILL.md
```

如果 skill 带有 `references/`、`scripts/`、`assets/` 等目录，也放在同一个 skill 目录里。

然后重新同步：

```powershell
.\setup.ps1 -Mode Copy
```

## 校验

只做检查：

```powershell
.\scripts\doctor.ps1 -RepoRoot .
```

运行测试：

```powershell
.\scripts\test-agent-config.ps1 -RepoRoot .
```

## 推荐习惯

平时优先使用：

```powershell
.\setup.ps1 -Mode Copy
```

`Copy` 最稳，不依赖 Windows 链接权限。确认本机链接权限没问题后，再考虑使用默认的 `Auto` 模式。

## Notes

- Treat `generated/` as build output. Edit `shared/` and `clients/` instead.
- On Windows, file prompts default to copy deployment; skill directories can use link-or-copy.
- Use `%USERPROFILE%` in local setup paths instead of hard-coded user profile directories.
