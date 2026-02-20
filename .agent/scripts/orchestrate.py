import sys
import os

def orchestrate_task(task_description):
    """
    A helper script to analyze a task and recommend the best agents/skills.
    In a real system, this would use an LLM API. 
    Here it acts as a structured guide for the Antigravity system.
    """
    print(f"🤖 Analyzing Task: {task_description[:50]}...")
    
    # Simple keyword mapping for routing logic (demonstration)
    if any(k in task_description.lower() for k in ['ui', 'react', 'css', 'style', 'page']):
        print("🎯 Recommended Agent: @frontend-specialist")
        print("🧩 Primary Skill: frontend-design")
    elif any(k in task_description.lower() for k in ['api', 'server', 'node', 'auth']):
        print("🎯 Recommended Agent: @backend-specialist")
        print("🧩 Primary Skill: nodejs-best-practices")
    elif any(k in task_description.lower() for k in ['db', 'sql', 'prisma', 'schema']):
        print("🎯 Recommended Agent: @database-architect")
        print("🧩 Primary Skill: database-design")
    else:
        print("🎯 Recommended Agent: @orchestrator")
        print("🧩 Primary Skill: behavioral-modes")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        orchestrate_task(" ".join(sys.argv[1:]))
    else:
        print("Usage: python orchestrate.py '<task description>'")
