---
name: orchestrator
description: "Specialized agent for pdf."
model: inherit
tools: [Read, Grep, Bash]
activation:
  phrases:
    - "pdf"
priority: 50
---

# Pdf Agent
This agent is responsible for handling tasks related to pdf.
