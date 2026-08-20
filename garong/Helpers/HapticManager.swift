//
//  HapticManager.swift
//  garong
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Singleton HapticManager providing tactile haptic feedback for UI taps, drag-and-drop actions, and rewards.
final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Trigger impact haptic feedback (light, medium, heavy, soft, rigid).
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
        #endif
    }
    
    /// Trigger selection haptic feedback (discrete selection change).
    func selection() {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
        #endif
    }
    
    /// Trigger notification haptic feedback (success, warning, error).
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
        #endif
    }
}
