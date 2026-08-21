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
    
    /// Helper resolving the URL for audio files across bundle locations and subdirectories.
    private func findAudioURL(for name: String) -> URL? {
        let extensions = ["wav", "mp3", "m4a", "caf", "aac"]
        let subdirectories = ["SFX", "Resources/SFX", "Resources", "garong/Resources/SFX", ""]
        
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
                "SFX/\(name).\(ext)"
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
