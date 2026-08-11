//  CharacterEmotion.swift
//  garong
//

import SwiftUI

/// Represents the emotion of a character in the game.
enum CharacterEmotion: String, CaseIterable, Codable, Sendable {
    case neutral
    case happy
    case sad
    case confused
    case angry
    case excited
    case calm
    case curious
    
    var emoji: String {
        switch self {
        case .neutral: return "😐"
        case .happy: return "😊"
        case .sad: return "😢"
        case .confused: return "😕"
        case .angry: return "😠"
        case .excited: return "🤩"
        case .calm: return "😌"
        case .curious: return "🧐"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .neutral: return "face.smiling"
        case .happy: return "face.smiling.fill"
        case .sad: return "face.dashed"
        case .confused: return "questionmark.face"
        case .angry: return "exclamationmark.triangle"
        case .excited: return "sparkles"
        case .calm: return "leaf.fill"
        case .curious: return "eyes.inverse"
        }
    }
    
    var displayName: String {
        switch self {
        case .neutral: return "Neutral"
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .confused: return "Confused"
        case .angry: return "Angry"
        case .excited: return "Excited"
        case .calm: return "Calm"
        case .curious: return "Curious"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .neutral: return .gray
        case .happy: return .yellow
        case .sad: return .blue
        case .confused: return .orange
        case .angry: return .red
        case .excited: return .pink
        case .calm: return .teal
        case .curious: return .purple
        }
    }
}
