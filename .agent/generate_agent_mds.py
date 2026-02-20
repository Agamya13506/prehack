import os

skills = [
    "api-patterns", "app-builder", "architecture", "bash-linux", "behavioral-modes",
    "brainstorming", "clean-code", "code-review-checklist", "competitor-analysis",
    "database-design", "deployment-procedures", "documentation-templates", "docx",
    "frontend-design", "game-development", "geo-fundamentals", "i18n-localization",
    "intelligent-routing", "lint-and-validate", "mcp-builder", "mobile-design",
    "nextjs-react-expert", "nodejs-best-practices", "parallel-agents", "pdf",
    "performance-profiling", "plan-writing", "powershell-windows", "python-patterns",
    "red-team-tactics", "seo-fundamentals", "server-management", "skill-creator",
    "systematic-debugging", "tailwind-patterns", "tdd-workflow", "testing-patterns",
    "ui-ux-pro-max", "vulnerability-scanner", "web-design-guidelines", "webapp-testing",
    "xlsx"
]

template = """---
name: {agent_name}
description: "Specialized agent for {skill_name}."
model: inherit
tools: [Read, Grep, Bash]
activation:
  phrases:
    - "{keyword}"
priority: 50
---

# {skill_title} Agent
This agent is responsible for handling tasks related to {skill_name}.
"""

# Mapping override for specific agents
agent_mapping = {
    "database-design": "database-architect",
    "frontend-design": "frontend-specialist",
    "ui-ux-pro-max": "frontend-specialist",
    "nextjs-react-expert": "frontend-specialist",
    "tailwind-patterns": "frontend-specialist",
    "api-patterns": "backend-specialist",
    "nodejs-best-practices": "backend-specialist",
    "python-patterns": "backend-specialist",
    "mcp-builder": "backend-specialist",
    "systematic-debugging": "debugger",
    "deployment-procedures": "devops-engineer",
    "bash-linux": "devops-engineer",
    "powershell-windows": "devops-engineer",
    "server-management": "devops-engineer",
    "red-team-tactics": "penetration-tester",
    "vulnerability-scanner": "security-auditor",
    "seo-fundamentals": "seo-specialist",
    "geo-fundamentals": "seo-specialist",
    "testing-patterns": "test-engineer",
    "tdd-workflow": "test-engineer",
    "webapp-testing": "qa-automation-engineer",
    "lint-and-validate": "qa-automation-engineer",
    "architecture": "project-planner",
    "plan-writing": "project-planner",
    "brainstorming": "project-planner",
    "game-development": "game-developer",
    "mobile-design": "mobile-developer"
}

def generate():
    for skill in skills:
        folder = os.path.join('.agent/skills', skill)
        if not os.path.exists(folder):
            continue
            
        agent_md = os.path.join(folder, 'agent.md')
        if os.path.exists(agent_md):
            print(f"Skipping {skill} (already exists)")
            continue
            
        agent_name = agent_mapping.get(skill, "orchestrator")
        skill_title = skill.replace("-", " ").title()
        content = template.format(
            agent_name=agent_name,
            skill_name=skill,
            skill_title=skill_title,
            keyword=skill.split("-")[0]
        )
        
        with open(agent_md, 'w') as f:
            f.write(content)
        print(f"Generated {agent_md}")

if __name__ == "__main__":
    generate()
