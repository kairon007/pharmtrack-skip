import SwiftUI

public struct Theme {
    // Calm, clinical palette: teal for primary actions and quiet neutral surfaces.
    public static let primary = ColorHelper.hex("#0F766E")
    public static let secondary = ColorHelper.hex("#115E59")
    public static let backgroundLight = ColorHelper.hex("#F5F8F7")
    public static let backgroundDark = ColorHelper.hex("#101817")
    public static let surfaceLight = ColorHelper.hex("#FFFFFF")
    public static let surfaceDark = ColorHelper.hex("#1B2725")
    public static let borderLight = ColorHelper.hex("#E2EAE8")
    public static let borderDark = ColorHelper.hex("#2B3936")

    // Tailwind Zinc Colors (Approximate)
    public static let slate50 = ColorHelper.hex("#F4F8F7")
    public static let slate100 = ColorHelper.hex("#EAF1EF")
    public static let slate200 = ColorHelper.hex("#DCE6E3")
    public static let slate300 = ColorHelper.hex("#C5D2CE")
    public static let slate400 = ColorHelper.hex("#82938E")
    public static let slate500 = ColorHelper.hex("#667873")
    public static let slate600 = ColorHelper.hex("#4B5D58")
    public static let slate700 = ColorHelper.hex("#374844")
    public static let slate800 = ColorHelper.hex("#263633")
    public static let slate900 = ColorHelper.hex("#1B2725")

    // Brand Colors
    public static let amber500 = ColorHelper.hex("#f59e0b")
    public static let emerald500 = ColorHelper.hex("#10b981")
    public static let purple500 = ColorHelper.hex("#a855f7")
    public static let rose500 = ColorHelper.hex("#f43f5e")
    public static let blue500 = ColorHelper.hex("#3b82f6")

    // Semantic
    public static let success = emerald500
    public static let warning = amber500
    public static let error = rose500
    public static let info = blue500
}

// MARK: - Icon Mapping (SF Symbols to Drawable Resources)
public struct IconMapper {
    // Maps SF Symbol names to Android drawable resource names
    public static func map(_ sfSymbol: String) -> String {
        let mapping: [String: String] = [
            // Navigation
            "chevron.left": "ic_arrow_back",
            "chevron.right": "ic_arrow_forward",
            "arrow.down.right": "ic_trending_down",
            "arrow.uturn.backward": "ic_undo",
            "arrow.uturn.forward": "ic_redo",
            "arrow.counterclockwise": "ic_refresh",
            "arrow.up": "ic_arrow_upward",

            // Actions
            "plus": "ic_add",
            "plus.circle": "ic_add_circle",
            "minus": "ic_remove",
            "checkmark": "ic_check",
            "checkmark.circle.fill": "ic_check_circle",
            "checkmark.circle": "ic_check_circle",
            "trash": "ic_delete",
            "bell": "ic_notifications",
            "bell.fill": "ic_notifications",
            "bell.slash": "ic_notifications_off",
            "xmark": "ic_close",
            "gearshape": "ic_settings",
            "magnifyingglass": "ic_search",
            "info.circle": "ic_info",
            "pencil.circle": "ic_edit",
            "pencil.circle.fill": "ic_edit",
            "pencil": "ic_edit",
            "hand.tap.fill": "ic_touch_app",
            "square.and.arrow.up": "ic_share",

            // People & Health
            "person.fill": "ic_person",
            "shield.righthalf.filled": "ic_shield",
            "doc.text": "ic_description",
            "doc.text.fill": "ic_description",

            // Medical - Tab bar icons (using actual drawable names)
            "heart.text.square.fill": "ic_favorite",
            "cross.case.fill": "ic_medical_services",
            "pills.fill": "ic_pills",
            "scalemass": "ic_monitor_weight",
            "house.fill": "ic_home",
            "heart.fill": "ic_favorite_border",

            // Calendar & Time
            "calendar": "ic_calendar",
            "clock": "ic_schedule",
            "alarm": "ic_alarm",

            // Location
            "mappin.and.ellipse": "ic_location_on",

            // Connectivity
            "wifi.slash": "ic_wifi_off",
            "network": "ic_hub",

            // Charts & Analytics
            "chart.bar.fill": "ic_bar_chart",

            // Lightbulb
            "lightbulb.fill": "ic_lightbulb",

            // Quick Access (Custom)
            "stethoscope": "ic_medical_services",

            // Misc
            "error": "ic_error",
            "circle": "ic_circle",
        ]

        #if SKIP
        return mapping[sfSymbol] ?? "ic_add"  // Use "ic_add" as safe fallback
        #else
        return sfSymbol
        #endif
    }
}

// MARK: - Platform-Safe Icon View

#if SKIP
import SwiftUI

public struct AppIcon: View {
    let name: String
    var size: Double = 12.0
    var tint: Color? = nil

    public init(name: String, size: Double = 12.0, tint: Color? = nil) {
        self.name = name
        self.size = size
        self.tint = tint
    }

    public var body: some View {
        #if SKIP
        ZStack {
            // SKIP REPLACE: skip.ui.DrawableIcon(name = IconMapper.map(name), sizeDp = size.toInt(), tintColor = tint)
            Image(systemName: name)
        }
        #else
        Image(systemName: name)
            .font(.system(size: size))
            .foregroundColor(tint)
        #endif
    }
}
#else
public struct AppIcon: View {
    let name: String
    var size: Double = 12.0
    var tint: Color?

    public init(name: String, size: Double = 12.0, tint: Color? = nil) {
        self.name = name
        self.size = size
        self.tint = tint
    }

    public var body: some View {
        Image(systemName: name)
            .font(.system(size: size))
            .foregroundColor(tint)
    }
}
#endif

// Helper to conditionally apply modifiers
public extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

