import os
import json

skills = [
    "allpagelogic", "api-patterns", "app-builder", "architecture", "bash-linux", "behavioral-modes",
    "brainstorming", "clean-code", "code-review-checklist", "competitor-analysis",
    "database-design", "deployment-procedures", "documentation-templates", "docx",
    "flutter", "frontend-design", "game-development", "geo-fundamentals", "i18n-localization",
    "intelligent-routing", "lint-and-validate", "mcp-builder", "mobile-design",
    "nextjs-react-expert", "nodejs-best-practices", "parallel-agents", "pdf",
    "performance-profiling", "plan-writing", "powershell-windows", "python-patterns",
    "red-team-tactics", "seo-fundamentals", "server-management", "skill-creator",
    "systematic-debugging", "tailwind-patterns", "tdd-workflow", "testing-patterns",
    "ui-ux-pro-max", "vulnerability-scanner", "web-design-guidelines", "webapp-testing",
    "xlsx"
]

agent_mapping = {
    "allpagelogic": "frontend-specialist",
    "database-design": "database-architect",
    "flutter": "mobile-developer",
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
    manifest_skills = []
    for skill in skills:
        agent_name = agent_mapping.get(skill, "orchestrator")
        keyword = skill.split("-")[0]
        
        manifest_skills.append({
            "skill_name": skill,
            "agent_name": agent_name,
            "activation": {
                "phrases": [skill, skill.replace("-", " "), keyword],
                "regex": f"({skill}|{skill.replace('-', ' ')}|{keyword})"
            },
            "priority": 50,
            "entry_point": f".agent/skills/{skill}/",
            "tools_allowed": ["Read", "Grep", "Bash"]
        })
    
    with open('skills_manifest.json', 'w') as f:
        json.dump({"skills": manifest_skills}, f, indent=2)
    print("Generated .agent/skills_manifest.json")

if __name__ == "__main__":
    generate()
