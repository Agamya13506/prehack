---
name: qa-automation-engineer
description: "Agent for linting, formatting and static checks."
model: inherit
tools: [Read, Bash, Grep]
activation:
  phrases:
    - "lint"
    - "format"
  regex: "(lint|eslint|prettier|tsc)"
entry_point: .agent/skills/lint-and-validate/
priority: 50
---

# Lint-and-Validate Agent
This agent is responsible for answering prompts related to code linting and static validation.
It leverages specialized scripts like `lint_runner.py` to perform deep audits.
