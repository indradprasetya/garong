import AVFoundation

final class BackgroundMusicManager {
    static let shared = BackgroundMusicManager()

    private var player: AVAudioPlayer?

    var volume: Float {
        get {
            if let stored = UserDefaults.standard.object(forKey: "bgmVolume") as? Float {
                return stored
            }
            return 0.8
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "bgmVolume")
            player?.volume = newValue
        }
    }

    private init() {}

    func play() {
        guard player?.isPlaying != true else { return }

        guard let url = Bundle.main.url(
            forResource: "background_music",
            withExtension: "mp3"
        ) else {
            print("Background music file is missing from the app bundle.")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = volume
            audioPlayer.prepareToPlay()
            guard audioPlayer.play() else {
                print("Background music player could not start.")
                return
            }
            player = audioPlayer
        } catch {
            print("Unable to play background music: \(error.localizedDescription)")
        }
    }
}
