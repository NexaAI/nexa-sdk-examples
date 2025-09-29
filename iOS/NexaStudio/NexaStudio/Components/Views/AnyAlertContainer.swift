import SwiftUI

@MainActor
@Observable
class AnyAlertManager {
    static let shared = AnyAlertManager()
    var alert: AnyAlert?
}

struct AnyAlertContainer<Content: View>: View {
    @State private var alertManager = AnyAlertManager.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .anyAlert(.alert, alert: $alertManager.alert)
    }
}
