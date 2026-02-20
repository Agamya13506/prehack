import os
import re
import sys

def scan_routes(root_dir):
    app_tsx = os.path.join(root_dir, 'App.tsx')
    if not os.path.exists(app_tsx):
        print(f"Error: App.tsx not found at {app_tsx}")
        return

    print(f"--- Scanning Routes in App.tsx ---")
    with open(app_tsx, 'r') as f:
        content = f.read()

    # Simple regex to find <Route path="..." element={<Component />} />
    route_pattern = r'<Route\s+path=["\']([^"\']+)["\']\s+element={([^}]+)}'
    routes = re.findall(route_pattern, content)

    if not routes:
        print("No routes found using standard pattern.")
        return

    print(f"{'Path':<30} | {'Component'}")
    print("-" * 50)
    for path, element in routes:
        # Clean up element string (often looks like <Home /> or <ProtectedRoute><Page /></ProtectedRoute>)
        component_match = re.search(r'<([A-Z][a-zA-Z0-9]+)', element)
        component = component_match.group(1) if component_match else element.strip()
        print(f"{path:<30} | {component}")

    print(f"\nTotal Routes Found: {len(routes)}")

if __name__ == "__main__":
    project_root = sys.argv[1] if len(sys.argv) > 1 else "."
    scan_routes(project_root)
