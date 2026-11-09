import os
import re

dir_path = "Sources/SharedUI/Medical/"

replacements = [
    (r'#if !SKIP\n\s*\.edgesIgnoringSafeArea\(Edge\.Set\.all\)\n\s*#endif', r'.ignoreAllSafeAreas()'),
    (r'#if !SKIP\n\s*\.edgesIgnoringSafeArea\(\.top\)\n\s*#endif', r'.ignoreTopSafeArea()'),
    (r'#if !SKIP\n\s*\.edgesIgnoringSafeArea\(Edge\.Set\.top\)\n\s*#endif', r'.ignoreTopSafeArea()'),
    (r'#if !SKIP\n\s*\.shadow\(color: Theme\.primary\.opacity\(0\.3\), radius: 10\.0, x: 0\.0, y: 5\.0\)\n\s*#endif', r'.primaryShadow()'),
    (r'#if !SKIP\n\s*\.background\(\.ultraThinMaterial\)\n\s*#endif', r'.ultraThinBackground()'),
    (r'#if !SKIP\n\s*\.accentColor\(Theme\.primary\)\n\s*#endif', r'.platformAccentColor()'),
    (r'#if !SKIP\n\s*\.overlay \{ RoundedRectangle\(cornerRadius: 12\.0\)\.stroke\(isDark \? Theme\.slate700 : Theme\.slate200, lineWidth: 1\.0\) \}\n\s*#endif', r'.platformOverlayStroke(isDark: isDark)'),
    (r'#if !SKIP\n\s*\.overlay \{\n\s*RoundedRectangle\(cornerRadius: 12\.0\)\n\s*\}\n\s*#endif', r'.platformOverlayRoundedRect()')
]

for filename in os.listdir(dir_path):
    if filename.endswith(".swift"):
        file_path = os.path.join(dir_path, filename)
        with open(file_path, "r") as f:
            content = f.read()

        original = content
        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content)

        if content != original:
            with open(file_path, "w") as f:
                f.write(content)
            print(f"Updated {filename}")
