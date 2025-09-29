import AVFoundation

@Observable
@MainActor
class AudioRecorder {
    private var recorder: AVAudioRecorder?
    private var volumeTimer: Timer?

    var isRecording = false
    var recordedFileURL: URL?
    var errorMsg: String?
    var volumes: [Float] = .init()

    func startRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            if session.isInputGainSettable {
                try? session.setInputGain(1.0)
            }
            AVAudioApplication.requestRecordPermission { [unowned self] allowed in
                if allowed {
                    do {
                        try _startRecording()
                    } catch {
                        errorMsg = "Failed to start recording: \(error)"
                    }
                } else {
                    errorMsg = "Request Record Permissionr Failed"
                }
            }
        } catch {
            errorMsg = "Failed to start recording: \(error)"
        }
    }

    private func _startRecording() throws {
        let fileName = UUID().uuidString + ".m4a"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recordedFileURL = url
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
        recorder?.record()
        isRecording = true
        startMetering()
    }

    func stopRecording(_ clear: Bool = false) {
        volumes = []
        recorder?.stop()
        if clear, let recordedFileURL {
            try? FileManager.default.removeItem(at: recordedFileURL)
        }
        stopMetering()
        isRecording = false
    }

    private func startMetering() {
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task {
                await self?.updateMeters()
            }
        }
    }

    private func updateMeters() {
        guard let recorder else {
            return
        }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        let normalizedVolume = normalizedPowerLevel(fromDecibels: power)
        volumes.insert(normalizedVolume, at: 0)
    }

    private func stopMetering() {
        volumeTimer?.invalidate()
        volumeTimer = nil
    }

    private func normalizedPowerLevel(fromDecibels decibels: Float) -> Float {
        let minDb: Float = -80
        if decibels < minDb {
            return 0.0
        } else if decibels >= 0 {
            return 1.0
        }
        return pow((decibels - minDb) / -minDb, 2)
    }
}
