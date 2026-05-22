# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

这是一个个人健身项目的根目录。用户是 20 岁男性 (172cm/75kg)，健身房纯小白，目标减脂。核心产物是 `fitness-dashboard.html`，一个单文件 HTML 应用（手机端看板），涵盖训练动作编排、组间计时、食谱推荐、历史复盘。

## 环境约束

- **Windows 11**，Shell 为 bash (Git Bash / MSYS2)
- **无 Python**（`python`/`python3` 均为 Microsoft Store 占位，exit code 49）
- Node.js 通过 `winget install OpenJS.NodeJS.LTS` 安装，**使用前需要 `export PATH="$PATH:/c/Program Files/nodejs"`**
- **pandoc** 可用，是读取 EPUB 的唯一方式
- curl 可用

## 核心文件

| 文件 | 作用 |
|------|------|
| `fitness-dashboard.html` | 主看板：训练模式 + 食谱模式 + 复盘模式，单文件 Tailwind + 原生 JS |
| `epub_read.sh` | pandoc 包装脚本，用于 EPUB 提取文本 |
| `我的要求.txt` | 初始需求文档（3 步规划：数据采集→饮食设计→看板生成） |
| `数据.txt` | 用户身体数据 + TDEE 计算过程 |

## 看板架构 (`fitness-dashboard.html`)

约 1000 行纯 HTML。零依赖除 CDN Tailwind 和 SheetJS（Excel 导出）。

**3 个模式标签页：**
1. **训练模式** — 3 天循环（Day A 推主导 / Day B 拉主导 / Day C 腿核心），每天 5 动作 × 3 组。组间 90 秒全屏倒计时。动作勾选打钩。localStorage 持久化。
2. **食谱模式** — 7 天 JavaScript 渲染（3 训练日 + 4 休息日），手掌估算法。训练日 2100 kcal / 休息日 1850-1900 kcal。
3. **复盘模式** — 训练历史列表 + 周统计 + 容量趋势。导出为 4 工作表 Excel（SheetJS）。导入合并去重。

**关键全局数据：**
- `workoutDays[]` — 3 天的动作数据
- `weeklyMeals[]` — 7 天食谱数据
- `data{}` — 当前训练进度（key: `{dayIndex}_{exerciseIndex}`），存 localStorage `fitness_dashboard`
- `trainingHistory[]` — 每次"完成训练"存的记录数组，存 localStorage `fitness_history`

**每日推荐运动量卡片**基于 NASM 新手标准（12-18 组/次，2000-4000 kg 容量，RPE 7-8）。

## EPUB 阅读

```bash
# 列出目录
bash epub_read.sh "书名.epub" -l
# 搜索关键词
bash epub_read.sh "书名.epub" -s "关键词"
# 导出全文
bash epub_read.sh "书名.epub" -o /tmp/output.txt
```

核心依赖：`pandoc "$EPUB" -t plain --wrap=none`。不要尝试用 Python 读取 EPUB。

## LobeHub Skills Marketplace

已安装 `lobehub-skills-search-engine` 技能到 `.claude/skills/`。使用前确保 Node PATH 已设置：
```bash
export PATH="$PATH:/c/Program Files/nodejs"
npx -y @lobehub/market-cli skills search --q "关键词"
npx -y @lobehub/market-cli skills install <id> --agent claude-code
```
