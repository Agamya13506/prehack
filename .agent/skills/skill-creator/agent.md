---
name: orchestrator
description: "Specialized agent for skill-creator."
model: inherit
tools: [Read, Grep, Bash]
activation:
  phrases:
    - "skill"
priority: 50
---

# Skill Creator Agent
This agent is responsible for handling tasks related to skill-creator.
