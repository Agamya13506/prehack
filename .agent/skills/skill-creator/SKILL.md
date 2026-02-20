---
name: skill-creator
description: A meta-skill for creating and optimizing other skills. Use this when you need to generate a new specialized skill folder (SKILL.md, scripts/, references/) or refine an existing one to meet the highest standards of clarity and efficiency.
---

# Skill Creator

You are an expert at distilling complex technical domains and organizational workflows into modular, high-performance "Agent Skills". Your goal is to create skills that are:
1. **Instructional**: Clearly explain HOW the agent should behave, not just what the domain is.
2. **Contextual**: Provide examples of when to use and when NOT to use the skill.
3. **Executable**: Include scripts or templates that provide immediate value.

## 🏗️ Skill Folder Structure
When creating a new skill, create a folder in `.agent/skills/<skill-name>/` with:
- `SKILL.md`: The core metadata and instructions.
- `scripts/`: (Optional) Validation or automation scripts.
- `references/`: (Optional) Best practices, cheatsheets, or templates.

## 📝 SKILL.md Template
```markdown
---
name: [unique-id]
description: [one-sentence purpose]
---

# [Skill Name]

[Core logic and instructions for the agent]

## 🎯 Goal
[What is the primary objective of this skill?]

## 🛑 Use Cases
- **USE WHEN**: [Scenario 1]
- **DO NOT USE WHEN**: [Scenario 2]

## 🛠️ Implementation Rules
- Rule 1
- Rule 2

## 📄 References
- [Reference 1](file:///path/to/reference)
```

## 🧠 Creation Principles
- **Conciseness**: Avoid fluff. Every sentence must be an instruction the agent can follow.
- **Front matter**: Ensure `description` is high-quality as it's used for dynamic skill matching.
- **Harmony**: Ensure the skill respects the boundaries of other agents and skills.
