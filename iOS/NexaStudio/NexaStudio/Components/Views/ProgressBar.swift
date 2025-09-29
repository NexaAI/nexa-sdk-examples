import SwiftUI
import UIKit

struct ProgressBar: UIViewRepresentable {
    var progress: Float
    var progressTintColor: UIColor = UIColor.Component.Fills.brand
    var trackTintColor: UIColor = UIColor.Component.Fills.primary

    func makeUIView(context: Context) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = progressTintColor
        progressView.trackTintColor = trackTintColor
        return progressView
    }

    func updateUIView(_ uiView: UIProgressView, context: Context) {
        uiView.setProgress(progress, animated: true)
        uiView.progressTintColor = progressTintColor
        uiView.trackTintColor = trackTintColor
    }
}

struct ContentView: View {
    @State private var value: Float = 0.3

    var body: some View {
        VStack(spacing: 20) {
            ProgressBar(
                progress: value,
                progressTintColor: .systemBlue,
                trackTintColor: .systemGray5
            )
            .frame(height: 4)

            Button("Increase Progress") {
                withAnimation {
                    value = min(value + 0.1, 1.0)
                }
            }
        }
        .padding()
    }
}
