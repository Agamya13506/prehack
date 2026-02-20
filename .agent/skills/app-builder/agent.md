---
name: orchestrator
description: "Specialized agent for app-builder."
model: inherit
tools: [Read, Grep, Bash]
activation:
  phrases:
    - "app"
priority: 50
---

# App Builder Agent
This agent is responsible for handling tasks related to app-builder.
