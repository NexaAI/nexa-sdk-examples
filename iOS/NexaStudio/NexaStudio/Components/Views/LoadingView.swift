import SwiftUI

struct LoadingView: View {
    var title: String = "Loading..."

    @State private var isRotating: Bool = false
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ProgressView()
                .tint(Color.Text.primary)
                .scaleEffect(1.6)
            Text(title)
                .textStyle(.caption1())
        }
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(0.02))
                isRotating = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
