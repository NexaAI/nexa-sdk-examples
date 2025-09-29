import SwiftUI

struct SeparatorView: View {
    let height: CGFloat
    init(height: CGFloat = 0.5) {
        self.height = height
    }

    var body: some View {
        Divider().frame(height: 0.5).background(Color.Stroke.primary)
    }
}
