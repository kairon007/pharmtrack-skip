import SwiftUI

#if !SKIP
import UIKit
#endif

public struct HideKeyboardModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                #if !SKIP
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
                #endif
            }
    }
}

public extension View {
    func hideKeyboardOnTap() -> some View {
        self.modifier(HideKeyboardModifier())
    }
}
