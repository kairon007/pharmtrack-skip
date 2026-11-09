import re

with open("Sources/SharedUI/SkipViewModifiers.swift", "r") as f:
    text = f.read()

text = text.replace("}", """
    /// Ignores the top safe area on non-Skip platforms.
    @ViewBuilder
    func ignoreTopSafeArea() -> some View {
        #if !SKIP
        self.edgesIgnoringSafeArea(.top)
        #else
        self
        #endif
    }

    /// Applies a primary shadow on non-Skip platforms.
    @ViewBuilder
    func primaryShadow() -> some View {
        #if !SKIP
        self.shadow(color: Theme.primary.opacity(0.3), radius: 10.0, x: 0.0, y: 5.0)
        #else
        self
        #endif
    }

    /// Applies an ultra-thin material background on non-Skip platforms.
    @ViewBuilder
    func ultraThinBackground() -> some View {
        #if !SKIP
        self.background(.ultraThinMaterial)
        #else
        self
        #endif
    }

    /// Applies an accent color on non-Skip platforms.
    @ViewBuilder
    func platformAccentColor() -> some View {
        #if !SKIP
        self.accentColor(Theme.primary)
        #else
        self
        #endif
    }
}""")

with open("Sources/SharedUI/SkipViewModifiers.swift", "w") as f:
    f.write(text)
