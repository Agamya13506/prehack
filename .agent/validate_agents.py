import json
import os

def check_file_exists(path):
    return os.path.exists(path)

def validate():
    manifest_path = '.agent/skills_manifest.json'
    if not os.path.exists(manifest_path):
        print(f"❌ Error: {manifest_path} not found.")
        return

    with open(manifest_path, 'r') as f:
        manifest = json.load(f)

    print(f"🔍 Auditing {len(manifest['skills'])} skills...")
    errors = 0
    
    for skill in manifest['skills']:
        skill_name = skill['skill_name']
        agent_name = skill['agent_name']
        entry_point = skill['entry_point']
        
        print(f"\n--- Skill: {skill_name} ---")
        
        # 1. Check folder
        skill_folder = os.path.join('.agent/skills', skill_name)
        if not os.path.isdir(skill_folder):
            print(f"❌ Folder missing: {skill_folder}")
            errors += 1
            
        # 2. Check agent.md
        agent_md_path = os.path.join(skill_folder, 'agent.md')
        if not os.path.exists(agent_md_path):
            print(f"⚠️ Warning: {agent_md_path} missing (Standardizing metadata...)")
            # We don't increment error yet as we are still populating
            
        # 3. Check agent definition
        agent_file = os.path.join('.agent/agents', f"{agent_name}.md")
        if not os.path.exists(agent_file):
            print(f"❌ Specialist agent file missing: {agent_file}")
            errors += 1
            
        # 4. Check activation
        if not skill.get('activation', {}).get('phrases') and not skill.get('activation', {}).get('regex'):
            print(f"⚠️ Warning: No activation rules defined for {skill_name}")

    if errors == 0:
        print("\n✅ System validation passed (with warnings for missing metadata).")
    else:
        print(f"\n❌ System validation failed with {errors} errors.")

if __name__ == "__main__":
    validate()
