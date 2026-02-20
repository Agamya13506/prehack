# 🤖 Harmony Protocol (v1.0)

> **Goal**: Ensure every AI turn is specialized, verified, and transparent.

---

## 🔄 The Harmony Loop (MANDATORY)

Every response must follow this 4-step internal process before writing a single line of code or text.

### 1. Discovery & Routing (Explicit)
- **Invoke Router**: Every turn starts with `.agent/router.py`.
- **Manifest Check**: Match prompt against `.agent/skills_manifest.json`.
- **Specialist Selection**: Identify the single best specialist agent for the task.
- **Socratic Fallback**: If no skill matches (score < 5), ask 1 clarifying question.

### 2. Header Signature (MANDATORY)
- State which agent perspective is being applied.
- Mandatory header: `🤖 Applying knowledge of @[agent-name] (Skill: [skill-name])...`

### 3. Loading & Context (Implicit)
- **Agent Metadata**: Read `agent.md` inside the skill folder.
- **Skill Knowledge**: Read `SKILL.md` for implementation patterns.
- **Skill Discovery**: If a new domain is identified, invoke `skill-creator`.

### 4. Limited Execution
- Perform the task strictly following the specific agent's persona and tool limits.
- If the task crosses domains, the orchestrator MUST coordinate handoffs.

---

## 📝 Response Signature Template

Every turn MUST start with this block:

```markdown
🤖 **Applying knowledge of `@[agent-name]`...**
🧩 **Loaded Skill**: `[skill-name]`
🎯 **Objective**: [1-sentence summary of what this agent will do]
```

---

## 🛑 Boundary Enforcement

- **Frontend-Specialist**: BLOCKED from `server/`, `api/`, `prisma/`.
- **Backend-Specialist**: BLOCKED from `components/`, `styles/`, `pages/`.
- **Test-Engineer**: THE ONLY AGENT allowed to write `**/*.test.*`.
- **Security-Auditor**: MANDATORY for any change to `auth/`, `lib/supabase.ts`, or `.env`.

---

## ⚡ Efficiency Rules

1. **No Generic Responses**: Never answer as a "general AI". If no specialist fits, use `orchestrator`.
2. **Skill-Centric**: If a skill exists for a task, it MUST be the primary source of truth, overriding general knowledge.
3. **Harmony**: If Agent A finishes, they must hand off to Agent B with a clear "Status: Completed - Handing off for [Task Y]".
