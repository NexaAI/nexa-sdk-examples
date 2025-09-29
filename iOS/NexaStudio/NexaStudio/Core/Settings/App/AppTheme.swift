import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, CustomStringConvertible {
    
    case system
    case light
    case dark

    var id: String { rawValue }

    var description: String { title }
    var title: String {
        switch self {
        case .system:
            return "Auto"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppStoreKey {
    static let colorTheme = "appstorekey.colortheme"
    static let offloadWhenEnterBackground = "appstorekey.offloadWhenEnterBackground"
    static let isThinkMode = "appstorekey.thinkMode"

}
