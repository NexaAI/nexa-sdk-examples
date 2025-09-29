import Foundation
import NexaAI

struct ProfileModel: Equatable {
    let ttft: Int64
    let acceleration: String
    let speed: Double
    let prefillSpeed: Double
    let peakMemory: Double

    var peakMemoryPair: (value: String, unit: String) {
        let gb = peakMemory / 1024.0
        if gb > 1 {
            return (String(format: "%.02f", gb), "GB")
        } else {
            return (String(format: "%.02f", peakMemory), "MB")
        }
    }
}

extension ProfileModel {
    init?(from data: ProfileData?, peakMemory: Double, acceleration: String) {
        guard let data else {
            return nil
        }
        self.ttft = data.ttft
        self.acceleration = acceleration
        self.prefillSpeed = data.prefillSpeed
        self.speed = data.decodingSpeed
        self.peakMemory = peakMemory
    }
}
