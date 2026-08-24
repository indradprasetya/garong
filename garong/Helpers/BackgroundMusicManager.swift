import AVFoundation

final class BackgroundMusicManager {
    static let shared = BackgroundMusicManager()

    enum Track: String {
        case menu = "background_music"
        case gameplay = "gameplay_music"
    }

    private var player: AVAudioPlayer?
    private var currentTrack: Track?
    
    /// Base volume multiplier to reduce BGM by 80% so it doesn't drown out voice overs and SFX.
    private let baseVolumeMultiplier: Float = 0.2

    var volume: Float {
        get {
            if let stored = UserDefaults.standard.object(forKey: "bgmVolume") as? Float {
                return stored
            }
            return 0.8
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "bgmVolume")
            player?.volume = newValue * baseVolumeMultiplier
        }
    }

    private init() {}

    func duckForSFXPreview(duration: TimeInterval = 0.2) {
        player?.setVolume(0, fadeDuration: duration)
    }

    func restoreAfterSFXPreview(duration: TimeInterval = 0.3) {
        player?.setVolume(volume * baseVolumeMultiplier, fadeDuration: duration)
    }

    func play(_ track: Track = .menu) {
        if currentTrack == track, player?.isPlaying == true {
            return
        }

        guard let url = Bundle.main.url(
            forResource: track.rawValue,
            withExtension: "mp3"
        ) else {
            print("Background music file '\(track.rawValue).mp3' is missing from the app bundle.")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = volume * baseVolumeMultiplier
            audioPlayer.prepareToPlay()
            guard audioPlayer.play() else {
                print("Background music player could not start.")
                return
            }
            player = audioPlayer
            currentTrack = track
        } catch {
            print("Unable to play background music: \(error.localizedDescription)")
        }
    }
}
