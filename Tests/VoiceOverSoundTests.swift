import Foundation

@main
struct VoiceOverSoundTests {
    static func main() {
        let soundManager = SoundManager.shared

        // Test expression / image name mappings
        precondition(soundManager.voiceOver(for: "rhodey_crying", emotion: .sad) == .cry)
        precondition(soundManager.voiceOver(for: "rhodey_drawing", emotion: .happy) == .humming)
        precondition(soundManager.voiceOver(for: "rhodey_frustrated", emotion: .angry) == .annoyed)
        precondition(soundManager.voiceOver(for: "jojo_angry", emotion: .angry) == .angry)
        precondition(soundManager.voiceOver(for: "rhodey_injured_sitting", emotion: .sad) == .sniffing)
        precondition(soundManager.voiceOver(for: "rhodey_questioning", emotion: .curious) == .questioning)
        precondition(soundManager.voiceOver(for: "jojo_happy", emotion: .happy) == .happy)
        precondition(soundManager.voiceOver(for: "rhodey_sad", emotion: .sad) == .sad)
        precondition(soundManager.voiceOver(for: "rhodey_calm", emotion: .calm) == .calm)

        precondition(
            soundManager.voiceOver(
                forChangedImageNames: ["jojo_happy", "rhodey_frustrated"],
                from: ["jojo_happy", "rhodey_calm"],
                emotion: .neutral,
                previousEmotion: .neutral
            ) == .annoyed,
            "An unchanged happy face must not override Rhodey's newly frustrated expression"
        )

        // Test fallback by emotion
        precondition(soundManager.voiceOver(for: nil, emotion: .happy) == .happy)
        precondition(soundManager.voiceOver(for: nil, emotion: .sad) == .sad)
        precondition(soundManager.voiceOver(for: nil, emotion: .angry) == .angry)
        precondition(soundManager.voiceOver(for: nil, emotion: .confused) == .questioning)
        precondition(soundManager.voiceOver(for: nil, emotion: .excited) == .humming)
        precondition(soundManager.voiceOver(for: nil, emotion: .calm) == .calm)

        // Ensure all VoiceOver enum cases are accounted for
        for vo in SoundManager.VoiceOver.allCases {
            precondition(!vo.rawValue.isEmpty, "VoiceOver case raw value must not be empty")
        }

        print("VoiceOverSoundTests passed")
    }
}

#if !canImport(UIKit)
final class HapticManager {
    enum Impact { case light, medium }
    enum Notification { case success, warning }

    static let shared = HapticManager()

    func impact(_ style: Impact) {}
    func notification(_ type: Notification) {}
}
#endif
