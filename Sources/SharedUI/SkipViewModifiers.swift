import SwiftUI

public extension View {
    /// Ignores all safe area edges on non-Skip platforms.
    /// On Android (Skip), this is a no-op to avoid breaking layout.
    @ViewBuilder
    func ignoreAllSafeAreas() -> some View {
        #if !SKIP
        self.edgesIgnoringSafeArea(Edge.Set.all)
        #else
        self
        #endif
    }

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
        self.shadow(color: Theme.primary.opacity(0.12), radius: 8.0, x: 0.0, y: 3.0)
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

    /// Applies an overlay stroke on non-Skip platforms.
    @ViewBuilder
    func platformOverlayStroke(isDark: Bool) -> some View {
        #if !SKIP
        self.overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0) }
        #else
        self
        #endif
    }

    /// Applies an overlay rounded rectangle on non-Skip platforms.
    @ViewBuilder
    func platformOverlayRoundedRect() -> some View {
        #if !SKIP
        self.overlay { RoundedRectangle(cornerRadius: 12.0) }
        #else
        self
        #endif
    }

    /// Applies an overlay stroke dynamically based on darkness.
    @ViewBuilder
    func platformOverlayStrokeDark(isDark: Bool) -> some View {
        #if !SKIP
        self.overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0)
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
                .stroke(isSelected ? Color.clear : (isDark ? Theme.borderDark : Theme.borderLight), lineWidth: 1.0)
        }
        #else
        self
        #endif
    }
}
