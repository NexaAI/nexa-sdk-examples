import SwiftUI

struct VoiceBarsView: View {
    @State var recorder: AudioRecorder
    private let barHeight = 24.0
    var body: some View {
        VStack {
            GeometryReader { geo in
                let width = geo.size.width
                let dotCount = Int(width / 3.5) + 2
                ZStack(alignment: .center) {
                    HStack(spacing: 1.5) {
                        ForEach(0..<dotCount, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 0.5)
                                .fill(Color.Component.Fills.primary)
                                .frame(width: 2, height: 1)
                        }
                    }
                    HStack(spacing: 1.5) {
                        ForEach(0..<dotCount, id: \.self) { i in
                            let index = dotCount - 1 - i
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.Icon.primary)
                                .frame(width: 2, height: barHeight(for: index))
                        }
                    }
                }
                .frame(height: barHeight)
                .animation(.easeOut(duration: 0.05), value: recorder.volumes)
            }
        }
        .frame(height: barHeight)
    }

    private func barHeight(for index: Int) -> CGFloat {
        if index >= recorder.volumes.count {
            return 0
        }
        return CGFloat(recorder.volumes[index] * Float(barHeight))
    }
}

#Preview {
    VoiceBarsView(recorder: .init())
}

