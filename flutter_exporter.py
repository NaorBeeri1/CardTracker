import os

def export_flutter_project():
    project_root = os.getcwd()
    output_filename = "flutter_project_full_export.md"
    
    ignore_dirs = {'.git', '.idea', 'build', '.dart_tool', 'ios', 'android', 'linux', 'macos', 'windows', 'web', 'test'}
    ignore_files = {'flutter_project_full_export.md', 'flutter_exporter.py', 'pubspec.lock'}
    
    print(f"Exporting Flutter project from: {project_root}")
    
    export_content = []
    export_content.append("# Flutter Project Full State Export\n")
    export_content.append(f"Project Path: `{project_root}`\n\n")
    
    export_content.append("## 1. Project Directory Structure & Source Code\n")
    
    for root, dirs, files in os.walk(project_root):
        dirs[:] = [d for d in dirs if d not in ignore_dirs]
        
        rel_path = os.path.relpath(root, project_root)
        indent_level = 0 if rel_path == "." else rel_path.count(os.sep) + 1
        indent = "  " * indent_level
        
        folder_name = os.path.basename(root)
        if folder_name != ".":
            export_content.append(f"{indent}- **[DIR]** {folder_name}/\n")
        
        file_indent = "  " * (indent_level + 1)
        for file in sorted(files):
            if file in ignore_files or file.endswith(('.png', '.jpg', '.jpeg', '.gif')):
                continue
                
            export_content.append(f"{file_indent}- **[FILE]** {file}\n")
            
            if file.endswith(('.dart', '.yaml', '.json', '.xml', '.gradle', '.properties', '.md')):
                file_path = os.path.join(root, file)
                ext = file.split('.')[-1]
                if ext == 'gradle': ext = 'groovy'
                
                export_content.append(f"{file_indent}  ```{ext}\n")
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        for line in f:
                            export_content.append(f"{file_indent}  {line.rstrip()}\n")
                except Exception as e:
                    export_content.append(f"{file_indent}  // Error reading file: {e}\n")
                export_content.append(f"{file_indent}  ```\n")

    full_text = "".join(export_content)
    output_path = os.path.join(project_root, output_filename)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(full_text)
        
    print(f"\n[SUCCESS] Entire project successfully exported to '{output_filename}'!")

if __name__ == "__main__":
    export_flutter_project()