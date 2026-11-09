import SwiftUI

// Shared building blocks for the redesigned screens.
// One look per element: sections, rows, buttons and empty states all come from here.

public struct SectionHeader: View {
    private let title: String
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let isDark: Bool

    public init(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil, isDark: Bool = false) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
        self.isDark = isDark
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.primary)
                }
                .frame(minHeight: 44.0)
            }
        }
    }
}

public struct CardSurface<Content: View>: View {
    private let isDark: Bool
    private let content: Content

    public init(isDark: Bool, @ViewBuilder content: () -> Content) {
        self.isDark = isDark
        self.content = content()
    }

    public var body: some View {
        content
            .padding(20.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isDark ? Theme.surfaceDark : Color.white)
            .cornerRadius(20.0)
            .overlay {
                RoundedRectangle(cornerRadius: 20.0)
                    .stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0)
            }
    }
}

public struct PrimaryButton: View {
    private let title: String
    private let icon: String?
    private let action: () -> Void

    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8.0) {
                if let icon = icon {
                    AppIcon(name: icon, size: 20.0, tint: .white)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52.0)
            .background(Theme.primary)
            .cornerRadius(16.0)
        }
    }
}

public struct EmptyStateCard: View {
    private let icon: String
    private let title: String
    private let message: String
    private let isDark: Bool

    public init(icon: String, title: String, message: String, isDark: Bool) {
        self.icon = icon
        self.title = title
        self.message = message
        self.isDark = isDark
    }

    public var body: some View {
        VStack(spacing: 12.0) {
            AppIcon(name: icon, size: 32.0, tint: isDark ? Theme.slate400 : Theme.slate300)

            VStack(spacing: 4.0) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Text(message)
                    .font(.caption)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32.0)
        .background(isDark ? Theme.surfaceDark : Color.white)
        .cornerRadius(20.0)
        .overlay {
            RoundedRectangle(cornerRadius: 20.0)
                .stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0)
        }
    }
}

public struct FilterChip: View {
    private let title: String
    private let isSelected: Bool
    private let isDark: Bool
    private let action: () -> Void

    public init(title: String, isSelected: Bool, isDark: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.isDark = isDark
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : (isDark ? Theme.slate300 : Theme.slate600))
                .padding(.horizontal, 16.0)
                .padding(.vertical, 10.0)
                .background(isSelected ? Theme.primary : (isDark ? Theme.surfaceDark : Color.white))
                .cornerRadius(20.0)
                .overlay {
                    Capsule()
                        .stroke(isSelected ? Color.clear : (isDark ? Theme.borderDark : Theme.borderLight), lineWidth: 1.0)
                }
        }
        .frame(minHeight: 44.0)
    }
}

public struct ProgressBar: View {
    private let fraction: Double
    private let isDark: Bool

    public init(fraction: Double, isDark: Bool) {
        self.fraction = fraction
        self.isDark = isDark
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isDark ? Theme.borderDark : Theme.slate100)

                Capsule()
                    .fill(Theme.primary)
                    .frame(width: max(0.0, min(1.0, fraction)) * geo.size.width)
            }
        }
        .frame(height: 6.0)
    }
}

public struct IconCircleButton: View {
    private let icon: String
    private let tint: Color
    private let label: String
    private let action: () -> Void

    public init(icon: String, tint: Color, label: String, action: @escaping () -> Void) {
        self.icon = icon
        self.tint = tint
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            AppIcon(name: icon, size: 18.0, tint: tint)
                .frame(width: 44.0, height: 44.0)
                .background(tint.opacity(0.1))
                .clipShape(Circle())
        }
        .accessibilityLabel(label)
    }
}
