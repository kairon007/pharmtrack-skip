import re

with open("Sources/SharedUI/SkipViewModifiers.swift", "r") as f:
    text = f.read()

# Add a generic overlay modifier
text = text.replace("}", """
    /// Applies an overlay stroke dynamically based on darkness.
    @ViewBuilder
    func platformOverlayStrokeDark(isDark: Bool) -> some View {
        #if !SKIP
        self.overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0)
        }
        #else
        self
        #endif
    }

    /// Applies an overlay stroke dynamically based on selection and darkness.
    @ViewBuilder
    func platformOverlayStrokeSelected(isSelected: Bool, isDark: Bool) -> some View {
        #if !SKIP
        self.overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(isSelected ? Color.clear : (isDark ? Theme.slate700 : Theme.slate200), lineWidth: 1.0)
        }
        #else
        self
        #endif
    }
}
""")

with open("Sources/SharedUI/SkipViewModifiers.swift", "w") as f:
    f.write(text)

with open("Sources/SharedUI/Medical/AddVitalView.swift", "r") as f:
    content = f.read()

content = re.sub(r'#if !SKIP\n\s*\.overlay \{\n\s*RoundedRectangle\(cornerRadius: 12\.0\)\n\s*\.stroke\(isDark \? Theme\.slate700 : Theme\.slate200, lineWidth: 1\.0\)\n\s*\}\n\s*#endif', r'.platformOverlayStrokeDark(isDark: isDark)', content)
content = re.sub(r'#if !SKIP\n\s*\.overlay \{\n\s*RoundedRectangle\(cornerRadius: 12\.0\)\n\s*\.stroke\(isSelected \? Color\.clear : \(isDark \? Theme\.slate700 : Theme\.slate200\), lineWidth: 1\.0\)\n\s*\}\n\s*#endif', r'.platformOverlayStrokeSelected(isSelected: isSelected, isDark: isDark)', content)

with open("Sources/SharedUI/Medical/AddVitalView.swift", "w") as f:
    f.write(content)

print("Updated AddVitalView")
