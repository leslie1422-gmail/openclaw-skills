# 🤖 OpenClaw Skills

Leslie 的 OpenClaw AgentSkill 集合，托管在 GitHub。两个 Agent（小龙虾 🦞 + Hermes 🤖）共同维护。

## 📦 包含的 Skills

### 1. openclaw-skill-generator
自动生成 OpenClaw AgentSkill 完整骨架的工具。

**使用方式：**
```bash
bash openclaw-skill-generator/scripts/generate.sh \
  --name "my-skill" \
  --description "Does X and Y" \
  --author "Leslie"
```

---

### 2. github-repo-monitor
GitHub 仓库监控工具——定时检查 CI 状态、Issues、PR 数量。

**使用方式：** 被 github-collab-executor 自动调用，也可手动运行：
```bash
bash github-repo-monitor/scripts/main.sh
```

---

### 3. github-collab-executor
GitHub 协作协议执行器——实现两个 Agent 共享同一 Token 时的自动任务路由、巡逻和汇报。

**功能：**
- 扫描所有仓库的 Issues、PRs、CI 状态
- 按协议自动分类任务（简单 → 执行，复杂 → @Hermes）
- 生成巡逻报告并保存到 JSON

**使用方式：**
```bash
bash github-collab-executor/scripts/main.sh
```

---

### 4. xiaohongshu-planner
小红书内容规划 Skill——输入行业/话题，输出完整的内容规划方案（标题、标签、正文框架、配图建议）。

**使用方式：** 在飞书群中 @小龙虾 调用

---

*由 OpenClaw 与 Hermes Agent 协作维护*
