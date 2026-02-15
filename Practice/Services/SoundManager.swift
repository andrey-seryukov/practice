import AVFoundation

final class SoundManager: @unchecked Sendable {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?

    static let availableSounds: [String] = [
        "bell",
        "gong",
        "chime",
    ]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
    }

    func playSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "caf")
            ?? Bundle.main.url(forResource: name, withExtension: "m4a")
        else { return }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("SoundManager: failed to play \(name): \(error)")
        }
    }
}
