#!/usr/bin/env node

/**
 * 技能分析工具
 * 用途：分析技能依赖关系、分类和启用状态
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKILLS_DIR = path.join(ROOT, 'shared', 'skills');
const CLIENTS_DIR = path.join(ROOT, 'clients');

// 读取所有技能
function getAllSkills() {
  return fs.readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);
}

// 读取技能的 SKILL.md 文档
function getSkillDoc(skillName) {
  const skillPath = path.join(SKILLS_DIR, skillName, 'SKILL.md');
  if (!fs.existsSync(skillPath)) {
    return null;
  }
  return fs.readFileSync(skillPath, 'utf-8');
}

// 从 SKILL.md 中提取元数据
function parseSkillMetadata(content) {
  if (!content) return {};
  
  const metadata = {};
  const yamlMatch = content.match(/^---\n([\s\S]*?)\n---/);
  
  if (yamlMatch) {
    const yamlContent = yamlMatch[1];
    const nameMatch = yamlContent.match(/name:\s*(.+)/);
    const descMatch = yamlContent.match(/description:\s*(.+)/);
    
    if (nameMatch) metadata.name = nameMatch[1].trim();
    if (descMatch) metadata.description = descMatch[1].replace(/^["']|["']$/g, '').trim();
  }
  
  return metadata;
}

// 检测技能来源和作者
function detectSkillSource(skillName, content, metadata) {
  const sources = [];
  
  // 检查 metadata 中的作者信息
  if (metadata.author) {
    sources.push(`作者: ${metadata.author}`);
  }
  
  // 检查常见来源标识
  if (content) {
    // Matt Pocock 标识
    if (content.includes('mattpocock') || content.includes('matt-pocock') || content.includes('Matt Pocock')) {
      sources.push('Matt Pocock');
    }
    
    // Anthropic 标识
    if (content.includes('anthropic-best-practices') || content.includes('Anthropic')) {
      sources.push('Anthropic');
    }
    
    // Superpowers 标识
    if (content.includes('docs/superpowers/') || content.includes('superpowers:')) {
      sources.push('Superpowers Framework');
    }
    
    // Multica 标识
    if (skillName.startsWith('multica-') || content.includes('multica')) {
      sources.push('Multica Platform');
    }
    
    // GitHub 仓库链接
    const githubMatch = content.match(/github\.com\/([^\/\s]+\/[^\/\s]+)/);
    if (githubMatch) {
      sources.push(`GitHub: ${githubMatch[1]}`);
    }
    
    // 检查引用的其他技能（可能来自同一作者）
    const skillRefs = content.match(/(?:superpowers|mattpocock):([a-z-]+)/gi);
    if (skillRefs && skillRefs.length > 0) {
      sources.push(`关联: ${skillRefs.slice(0, 3).join(', ')}`);
    }
  }
  
  return sources.length > 0 ? sources : ['未知来源'];
}

// 检测技能是否属于 Superpowers
function isSuperpowersSkill(skillName, content) {
  if (!content) return false;
  
  // 明确的 Superpowers 标识
  if (skillName === 'using-superpowers') return true;
  
  // 检查是否使用 docs/superpowers 路径
  if (content.includes('docs/superpowers/')) return true;
  
  // 检查是否使用 ~/.config/superpowers/ 路径
  if (content.includes('~/.config/superpowers/')) return true;
  
  // 检查是否明确引用 superpowers: 前缀
  if (content.includes('superpowers:using-git-worktrees') && skillName === 'using-git-worktrees') return true;
  if (content.includes('superpowers:finishing-a-development-branch') && skillName === 'finishing-a-development-branch') return true;
  
  return false;
}

// 检测技能的依赖关系
function getSkillDependencies(content) {
  if (!content) return [];
  
  const deps = [];
  
  // 匹配 REQUIRED SUB-SKILL / REQUIRED BACKGROUND 等
  const requiredMatches = content.matchAll(/(?:REQUIRED SUB-SKILL|REQUIRED BACKGROUND|Use)\s*:?\s*(?:use\s+)?(?:superpowers:)?([a-z-]+)/gi);
  for (const match of requiredMatches) {
    const dep = match[1].trim();
    if (dep && !deps.includes(dep)) {
      deps.push(dep);
    }
  }
  
  // 匹配 Invoke ... skill
  const invokeMatches = content.matchAll(/Invoke\s+(?:the\s+)?([a-z-]+)\s+skill/gi);
  for (const match of invokeMatches) {
    const dep = match[1].trim();
    if (dep && !deps.includes(dep)) {
      deps.push(dep);
    }
  }
  
  return deps;
}

// 读取客户端配置
function getClientSkills(clientName) {
  const manifestPath = path.join(CLIENTS_DIR, clientName, 'skills.manifest.json');
  if (!fs.existsSync(manifestPath)) {
    return [];
  }
  
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));
  return manifest.skills || [];
}

// 分类技能
function categorizeSkill(skillName, content, metadata) {
  if (isSuperpowersSkill(skillName, content)) {
    return 'superpowers';
  }
  
  if (skillName.startsWith('multica-')) {
    return 'multica';
  }
  
  // Matt Pocock 核心技能
  const mattPocockCore = [
    'grill-me', 'grill-with-docs',
    'diagnose', 'systematic-debugging',
    'improve-codebase-architecture',
    'requesting-code-review', 'receiving-code-review',
    'tdd', 'test-driven-development',
    'to-issues', 'to-prd', 'triage',
    'setup-matt-pocock-skills', 'zoom-out'
  ];
  
  if (mattPocockCore.includes(skillName)) {
    return 'matt-pocock-core';
  }
  
  // 设计与原型
  if (['design-taste-frontend', 'prototype'].includes(skillName)) {
    return 'design';
  }
  
  // 工具与元技能
  if (['find-skills', 'write-a-skill', 'writing-skills'].includes(skillName)) {
    return 'meta';
  }
  
  return 'other';
}

// 主分析函数
function analyzeSkills() {
  const allSkills = getAllSkills();
  const clients = fs.readdirSync(CLIENTS_DIR, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);
  
  const analysis = {
    total: allSkills.length,
    categories: {},
    superpowers: [],
    enabled: {},
    disabled: {},
    dependencies: {},
    sources: {}  // 新增：技能来源信息
  };
  
  // 获取每个客户端启用的技能
  const clientSkills = {};
  clients.forEach(client => {
    clientSkills[client] = getClientSkills(client);
    analysis.enabled[client] = clientSkills[client];
  });
  
  // 分析每个技能
  allSkills.forEach(skillName => {
    const content = getSkillDoc(skillName);
    const metadata = parseSkillMetadata(content);
    const category = categorizeSkill(skillName, content, metadata);
    const deps = getSkillDependencies(content);
    const sources = detectSkillSource(skillName, content, metadata);
    
    // 统计分类
    if (!analysis.categories[category]) {
      analysis.categories[category] = [];
    }
    analysis.categories[category].push(skillName);
    
    // 记录来源
    analysis.sources[skillName] = {
      category: category,
      sources: sources,
      description: metadata.description || 'N/A'
    };
    
    // 记录 Superpowers 技能
    if (category === 'superpowers') {
      analysis.superpowers.push({
        name: skillName,
        description: metadata.description || 'N/A'
      });
    }
    
    // 记录依赖
    if (deps.length > 0) {
      analysis.dependencies[skillName] = deps;
    }
    
    // 检查是否被任何客户端启用
    const enabledIn = clients.filter(client => clientSkills[client].includes(skillName));
    const disabledIn = clients.filter(client => !clientSkills[client].includes(skillName));
    
    if (disabledIn.length > 0) {
      analysis.disabled[skillName] = {
        clients: disabledIn,
        category: category,
        description: metadata.description || 'N/A'
      };
    }
  });
  
  return analysis;
}

// 生成报告
function generateReport(analysis) {
  console.log('\n╔═══════════════════════════════════════════════════════════╗');
  console.log('║           技能分析报告 - Skills Analysis Report          ║');
  console.log('╚═══════════════════════════════════════════════════════════╝\n');
  
  console.log(`📊 总技能数: ${analysis.total}\n`);
  
  console.log('📁 分类统计:');
  Object.entries(analysis.categories).forEach(([category, skills]) => {
    const categoryNames = {
      'superpowers': '⚡ Superpowers 工作流',
      'matt-pocock-core': '🎯 Matt Pocock 核心',
      'multica': '🤝 Multica 协作',
      'design': '🎨 设计与原型',
      'meta': '🛠️ 工具与元技能',
      'other': '🔧 其他独立技能'
    };
    console.log(`  ${categoryNames[category] || category}: ${skills.length}`);
  });
  
  console.log('\n⚡ Superpowers 技能 (应被禁用):');
  if (analysis.superpowers.length === 0) {
    console.log('  ✅ 未发现 Superpowers 技能');
  } else {
    analysis.superpowers.forEach(skill => {
      console.log(`  - ${skill.name}`);
      console.log(`    ${skill.description}`);
    });
  }
  
  console.log('\n❌ 已禁用的技能:');
  const disabledSkills = Object.entries(analysis.disabled);
  if (disabledSkills.length === 0) {
    console.log('  ✅ 所有技能均已启用');
  } else {
    disabledSkills.forEach(([skillName, info]) => {
      console.log(`  - ${skillName} (${info.category})`);
      console.log(`    禁用客户端: ${info.clients.join(', ')}`);
    });
  }
  
  console.log('\n🔗 技能依赖关系:');
  const depsEntries = Object.entries(analysis.dependencies);
  if (depsEntries.length === 0) {
    console.log('  ℹ️ 未发现明显的依赖关系');
  } else {
    depsEntries.forEach(([skillName, deps]) => {
      console.log(`  ${skillName} → ${deps.join(', ')}`);
    });
  }
  
  console.log('\n✅ 启用状态 (按客户端):');
  Object.entries(analysis.enabled).forEach(([client, skills]) => {
    console.log(`  ${client}: ${skills.length} 个技能`);
  });
  
  // 新增：按来源分组显示
  console.log('\n📦 技能来源统计:');
  const sourceGroups = {};
  Object.entries(analysis.sources).forEach(([skillName, info]) => {
    info.sources.forEach(source => {
      if (!sourceGroups[source]) {
        sourceGroups[source] = [];
      }
      sourceGroups[source].push(skillName);
    });
  });
  
  Object.entries(sourceGroups).sort((a, b) => b[1].length - a[1].length).forEach(([source, skills]) => {
    console.log(`  ${source}: ${skills.length} 个技能`);
    if (process.argv.includes('--verbose')) {
      skills.forEach(skill => {
        console.log(`    - ${skill}`);
      });
    }
  });
  
  console.log('\n💡 提示: 使用 --verbose 查看每个来源的详细技能列表');
  console.log('      使用 --skill <name> 查看特定技能的详细信息');
  
  console.log('\n');
}

// 主程序
if (require.main === module) {
  try {
    const analysis = analyzeSkills();
    
    // 检查是否查询特定技能
    const skillIndex = process.argv.indexOf('--skill');
    if (skillIndex !== -1 && process.argv[skillIndex + 1]) {
      const skillName = process.argv[skillIndex + 1];
      const skillInfo = analysis.sources[skillName];
      
      if (!skillInfo) {
        console.error(`\n❌ 技能 "${skillName}" 不存在\n`);
        console.log('可用技能列表:');
        Object.keys(analysis.sources).sort().forEach(name => {
          console.log(`  - ${name}`);
        });
        process.exit(1);
      }
      
      console.log('\n╔═══════════════════════════════════════════════════════════╗');
      console.log(`║                技能详情 - ${skillName}`.padEnd(63) + '║');
      console.log('╚═══════════════════════════════════════════════════════════╝\n');
      
      console.log(`📛 名称: ${skillName}`);
      console.log(`📝 描述: ${skillInfo.description}`);
      console.log(`📁 分类: ${skillInfo.category}`);
      console.log(`📦 来源: ${skillInfo.sources.join(', ')}`);
      
      const deps = analysis.dependencies[skillName];
      if (deps && deps.length > 0) {
        console.log(`🔗 依赖: ${deps.join(', ')}`);
      } else {
        console.log(`🔗 依赖: 无`);
      }
      
      const enabledClients = Object.entries(analysis.enabled)
        .filter(([client, skills]) => skills.includes(skillName))
        .map(([client]) => client);
      
      if (enabledClients.length > 0) {
        console.log(`✅ 启用状态: 已启用于 ${enabledClients.join(', ')}`);
      } else {
        console.log(`❌ 启用状态: 已禁用`);
      }
      
      console.log(`\n📄 文档位置: shared/skills/${skillName}/SKILL.md\n`);
      
      return;
    }
    
    generateReport(analysis);
    
    // 可选：输出 JSON 格式
    if (process.argv.includes('--json')) {
      console.log('\n📄 JSON 输出:\n');
      console.log(JSON.stringify(analysis, null, 2));
    }
  } catch (error) {
    console.error('❌ 错误:', error.message);
    process.exit(1);
  }
}

module.exports = { analyzeSkills, generateReport };
