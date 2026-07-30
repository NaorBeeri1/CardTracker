import os
import json

# Define the extensions you want to include
ALLOWED_EXTENSIONS = {'.dart', '.yaml', '.json', '.gradle', '.xml', '.properties'}

# Folders to skip to keep the JSON clean and small
EXCLUDED_DIRS = {'build', '.dart_tool', '.git', '.idea', 'ios', 'android/app/build', 'windows', 'linux', 'macos'}

def export_project_to_json(root_dir, output_file='project_dump.json'):
    project_data = {}
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        # Modify dirnames in-place to skip excluded directories
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIRS]
        
        for file in filenames:
            ext = os.path.splitext(file)[1]
            if ext in ALLOWED_EXTENSIONS:
                full_path = os.path.join(dirpath, file)
                rel_path = os.path.relpath(full_path, root_dir)
                
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        project_data[rel_path] = f.read()
                except Exception as e:
                    print(f"Skipping {rel_path} due to error: {e}")

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(project_data, f, indent=4)
    
    print(f"Project successfully exported to {output_file}")

if __name__ == '__main__':
    # Run this from your project root directory (e.g., where pubspec.yaml is)
    export_project_to_json('.')