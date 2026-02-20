---
name: orchestrator
description: "Specialized agent for parallel-agents."
model: inherit
tools: [Read, Grep, Bash]
activation:
  phrases:
    - "parallel"
priority: 50
---

# Parallel Agents Agent
This agent is responsible for handling tasks related to parallel-agents.
