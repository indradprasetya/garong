//
//  SoundManager.swift
//  garong
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

/// Singleton SoundManager providing audio playback for UI navigation, gameplay actions, and completion rewards.
final class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isMuted: Bool = false
    
    private var players: [String: AVAudioPlayer] = [:]
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        #if canImport(UIKit)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundManager: Failed to configure AVAudioSession: \(error)")
        }
        #endif
    }
    
    enum SoundEffect: String {
        case buttonTap = "ui_button_tap"
        case backTap = "ui_back_tap"
        case itemPickup = "sfx_item_pickup"
        case itemRemove = "sfx_item_remove"
        case chapterComplete = "sfx_chapter_complete"
        case chapterRetry = "sfx_chapter_retry"
    }
    
    /// Play a sound effect by enum type.
    func play(_ effect: SoundEffect) {
        triggerHaptic(for: effect)
        play(named: effect.rawValue)
    }
    
    var volume: Float {
        get {
            if let stored = UserDefaults.standard.object(forKey: "sfxVolume") as? Float {
                return stored
            }
            return 1.0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sfxVolume")
        }
    }
    
    /// Play a sound effect by file name (without extension).
    func play(named soundName: String) {
        guard !isMuted else { return }
        
        guard let url = findAudioURL(for: soundName) else {
            print("SoundManager: Sound file '\(soundName)' not found.")
            return
        }
        
        let currentVolume = volume
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = currentVolume
                player.prepareToPlay()
                player.play()
                
                DispatchQueue.main.async {
                    self?.players[soundName] = player
                }
            } catch {
                print("SoundManager: Error playing sound '\(soundName)': \(error.localizedDescription)")
            }
        }
    }
    
    private func triggerHaptic(for effect: SoundEffect) {
        switch effect {
        case .buttonTap, .backTap:
            HapticManager.shared.impact(.light)
        case .itemPickup:
            HapticManager.shared.impact(.medium)
        case .itemRemove:
            HapticManager.shared.impact(.light)
        case .chapterComplete:
            HapticManager.shared.notification(.success)
        case .chapterRetry:
            HapticManager.shared.notification(.warning)
        }
    }
    
    enum VoiceOver: String, CaseIterable {
        case angry = "vo_angry"
        case annoyed = "vo_annoyed"
        case calm = "vo_calm"
        case cry = "vo_crying"
        case happy = "vo_happy"
        case humming = "vo_humming"
        case questioning = "vo_questioning"
        case sad = "vo_sad"
        case sniffing = "vo_sniffing"
    }

    /// Play a voice over sound effect by enum type.
    func playVoiceOver(_ vo: VoiceOver) {
        play(named: vo.rawValue)
    }

    /// Plays voice over sound effect if an image name or emotion reaction is present. Returns true if played.
    @discardableResult
    func playVoiceOverIfPresent(for imageNames: [String], emotion: CharacterEmotion) -> Bool {
        for name in imageNames {
            if let vo = voiceOver(for: name) {
                playVoiceOver(vo)
                return true
            }
        }
        if let vo = voiceOver(for: nil, emotion: emotion) {
            playVoiceOver(vo)
            return true
        }
        return false
    }

    /// Play voice over sound effect based on array of character image names or emotion fallback.
    func playVoiceOver(for imageNames: [String], emotion: CharacterEmotion) {
        _ = playVoiceOverIfPresent(for: imageNames, emotion: emotion)
    }

    /// Play voice over sound effect based on character image name or emotion fallback.
    func playVoiceOver(for imageName: String?, emotion: CharacterEmotion) {
        if let vo = voiceOver(for: imageName, emotion: emotion) {
            playVoiceOver(vo)
        }
    }

    /// Resolves the appropriate VoiceOver enum case specifically for a character image name.
    func voiceOver(for imageName: String?) -> VoiceOver? {
        guard let name = imageName?.lowercased() else { return nil }
        if name.contains("crying") || name.contains("cry") { return .cry }
        if name.contains("drawing") || name.contains("humming") { return .humming }
        if name.contains("frustrated") || name.contains("defensive") || name.contains("annoyed") { return .annoyed }
        if name.contains("angry") { return .angry }
        if name.contains("injured") || name.contains("sniffing") { return .sniffing }
        if name.contains("questioning") || name.contains("confused") { return .questioning }
        if name.contains("happy") || name.contains("handshake") || name.contains("holding_new_paper") { return .happy }
        if name.contains("sad") { return .sad }
        if name.contains("calm") || name.contains("relieved") || name.contains("bandaged") { return .calm }
        return nil
    }

    /// Resolves the appropriate VoiceOver enum case for a character image name and emotion fallback.
    func voiceOver(for imageName: String?, emotion: CharacterEmotion) -> VoiceOver? {
        if let vo = voiceOver(for: imageName) {
            return vo
        }
        
        switch emotion {
        case .happy: return .happy
        case .sad: return .sad
        case .angry: return .angry
        case .confused, .curious: return .questioning
        case .excited: return .humming
        case .calm: return .calm
        case .neutral: return nil
        }
    }
    
    /// Helper resolving the URL for audio files across bundle locations and subdirectories.
    private func findAudioURL(for name: String) -> URL? {
        let extensions = ["qta", "wav", "mp3", "m4a", "caf", "aac"]
        let subdirectories = [
            "SFX", "Resources/SFX", "Resources", "garong/Resources/SFX",
            "Voice Over", "Resources/Voice Over", "garong/Resources/Voice Over",
            ""
        ]
        
        for ext in extensions {
            for sub in subdirectories {
                if sub.isEmpty {
                    if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                        return url
                    }
                } else {
                    if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: sub) {
                        return url
                    }
                }
            }
        }
        
        for ext in extensions {
            let relativePaths = [
                "garong/Resources/SFX/\(name).\(ext)",
                "Resources/SFX/\(name).\(ext)",
                "SFX/\(name).\(ext)",
                "garong/Resources/Voice Over/\(name).\(ext)",
                "Resources/Voice Over/\(name).\(ext)",
                "Voice Over/\(name).\(ext)"
            ]
            for relPath in relativePaths {
                if let resourcePath = Bundle.main.resourcePath {
                    let fullPath = (resourcePath as NSString).appendingPathComponent(relPath)
                    if FileManager.default.fileExists(atPath: fullPath) {
                        return URL(fileURLWithPath: fullPath)
                    }
                }
            }
        }
        
        return nil
    }
}
