import AVFoundation

@Observable
class AudioPlayerManager {
    static var currentPlayer: AVAudioPlayer?

    private(set) var player: AVAudioPlayer?
    private(set) var isPlaying = false
    private(set) var totalTime: TimeInterval = 0.0
    private(set) var currentTime: TimeInterval = 0.0

    let audioURL: URL
    init(audioURL: URL) {
        self.audioURL = audioURL
    }

    func setupAudio(withURL url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            totalTime = player?.duration ?? 0.0
        } catch {
            Log.error(error)
        }
    }

    var currentTimeFormat: String {
        formatTime(currentTime)
    }

    var totalTimeFormat: String {
        formatTime(totalTime)
    }

    var progress: CGFloat {
        if totalTime == 0 {
            return 0
        }
        return currentTime / totalTime
    }

    func togglePlay() {
        Self.synthesizer.stopSpeaking(at: .immediate)
        if isPlaying {
            player?.pause()
        } else {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default, options: [.interruptSpokenAudioAndMixWithOthers])
            try? session.setActive(true)
            if let current = Self.currentPlayer {
                current.pause()
            }
            player?.play()
            Self.currentPlayer = player
        }
        isPlaying.toggle()
    }

    func stop() {
        player?.stop()
    }

    func updateProgress() {
        guard let player = player else { return }
        if player.isPlaying {
            currentTime = player.currentTime
        } else {
            isPlaying = false
            if Int(currentTime) == Int(totalTime) {
                currentTime = 0
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        let minutes = Int(time) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static private let synthesizer: AVSpeechSynthesizer = .init()
    static func speak(_ content: String) {
        currentPlayer?.stop()
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let preferredLanguage = Locale.preferredLanguages.first ?? "en-US"
        let voice = AVSpeechSynthesisVoice(language: preferredLanguage) ??
        (AVSpeechSynthesisVoice(language: "en-US") ??
         AVSpeechSynthesisVoice(language: "zh-CN"))
        let utterance = AVSpeechUtterance(string: content)
        utterance.voice = voice
        synthesizer.speak(utterance)
      }
}
