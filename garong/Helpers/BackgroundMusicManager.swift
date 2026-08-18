import AVFoundation

final class BackgroundMusicManager {
    static let shared = BackgroundMusicManager()

    private var player: AVAudioPlayer?

    private init() {}

    func play() {
        guard player?.isPlaying != true else { return }

        guard let url = Bundle.main.url(
            forResource: "Steps_in_the_Grass",
            withExtension: "mp3"
        ) else {
            assertionFailure("Background music file is missing from the app bundle.")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = 0.28
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer
        } catch {
            assertionFailure("Unable to play background music: \(error.localizedDescription)")
        }
    }
}
