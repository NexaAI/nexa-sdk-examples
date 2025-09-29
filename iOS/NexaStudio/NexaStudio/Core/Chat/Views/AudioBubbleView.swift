import SwiftUI

struct AudioBubbleView: View {

    @State var manager: AudioPlayerManager

    let audioURL: URL
    init(audioURL: URL) {
        self.audioURL = audioURL
        _manager = State(initialValue: AudioPlayerManager(audioURL: audioURL))
    }

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(.fileAudio)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.brand7)
                    .aspectRatio(contentMode: .fill)
                    .square(24)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text(audioURL.name)
                        .textStyle(.caption1())
                        .lineLimit(1)

                    Text("\(manager.currentTimeFormat) / \(manager.totalTimeFormat)")
                        .textStyle(.caption2(textColor: Color.Text.tertiary))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)

                Image(manager.isPlaying ? .pause : .play)
                    .resizable()
                    .primaryStyle()
                    .frame(width: 16, height: 16)
                    .padding(10)
                    .offset(x: 10)
                    .contentShape(Rectangle())
                    .anyButton {
                        manager.togglePlay()
                    }
            }

            ProgressView(value: manager.progress, total: 1.0)
                .progressViewStyle(.linear)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .stroke(Color.Component.Border.primary, lineWidth: 1)
        )
        .frame(width: 220)
        .onAppear {
            manager.setupAudio(withURL: audioURL)
        }
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            manager.updateProgress()
        }
        .onDisappear {
            manager.stop()
        }
    }


}

#Preview("AudioBubbleView") {
    AudioBubbleView(audioURL: .init(string: "https://www.hello.com/test3.mp3")!)
}
