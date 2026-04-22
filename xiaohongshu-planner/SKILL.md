# xiaohongshu-planner

> 小红书内容规划 Skill — 输入行业/话题，输出完整的内容规划方案。

## 功能

- 分析目标受众和内容方向
- 生成一周/一月内容日历
- 输出每篇笔记的标题、话题标签、正文框架

## 使用方式

```bash
# 在飞书群中 @小龙虾 使用
# @小龙虾 用 xiaohongshu-planner 规划本周时尚内容
```

## 输入

- 行业/领域（如：时尚、美妆、生活方式）
- 目标人群
- 内容数量（每周 N 篇）
- 特殊要求（如果有）

## 输出

1. **内容日历**（周度/月度）
2. **每篇笔记框架**：
   - 标题（吸引眼球的 emoji 风格）
   - 话题标签（#标签1 #标签2 ...）
   - 正文结构（开头/正文/结尾）
   - 配图建议

## 与 AgentCrew 配合

可作为 agentcrew 的 content-review 的上游，先规划再审核：

```bash
# 规划内容
agentcrew crew-run.sh market-research "小红书时尚内容规划"
# 审核内容
agentcrew council-run.sh content-review "评估规划方案"
```

