import re
import json
import os

def load_manifest(path='.agent/skills_manifest.json'):
    try:
        with open(path, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading manifest: {e}")
        return {"skills": []}

def score_skill(prompt, skill):
    score = 0
    text = prompt.lower()
    
    # Phrase matching
    for p in skill.get('activation', {}).get('phrases', []):
        if p.lower() in text:
            score += 10
            
    # Regex matching
    rx = skill.get('activation', {}).get('regex')
    if rx:
        try:
            if re.search(rx, prompt, re.I):
                score += 20
        except re.error:
            pass
            
    # Priority weighting
    return score + skill.get('priority', 0) / 100.0

def select_agents(prompt, manifest, top_n=1, min_score=5):
    scored = []
    for s in manifest.get('skills', []):
        sc = score_skill(prompt, s)
        if sc >= min_score:
            scored.append((sc, s))
    
    # Sort by score descending
    scored.sort(reverse=True, key=lambda x: x[0])
    
    # Filter unique agents
    selected = []
    seen_agents = set()
    for _, skill in scored:
        if skill['agent_name'] not in seen_agents:
            selected.append(skill)
            seen_agents.add(skill['agent_name'])
        if len(selected) >= top_n:
            break
            
    return selected

def main():
    import sys
    if len(sys.argv) < 2:
        print("Usage: python router.py <prompt>")
        return

    prompt = " ".join(sys.argv[1:])
    manifest = load_manifest()
    matched = select_agents(prompt, manifest)

    if matched:
        print(json.dumps(matched, indent=2))
    else:
        # Socratic Gate fallback
        print(json.dumps({
            "fallback": "No specialized skill matched. Please ask a clarifying question.",
            "status": "SOCRATIC_GATE"
        }))

if __name__ == "__main__":
    main()
