//  CharacterEmotion.swift
//  garong
//

import SwiftUI

/// Represents the emotion of a character in the game.
enum CharacterEmotion: String, CaseIterable, Codable, Sendable {
    case neutral
    case happy
    case sad
    case crying
    case angry
    case annoyed
    case questioning
    case calm
    case excited
    case humming
    case sniffing
    case confused
    case curious
    
    var emoji: String {
        switch self {
        case .neutral: return "😐"
        case .happy: return "😊"
        case .sad: return "😢"
        case .crying: return "😭"
        case .angry: return "😠"
        case .annoyed: return "😤"
        case .questioning: return "🤨"
        case .calm: return "😌"
        case .excited: return "🤩"
        case .humming: return "🎶"
        case .sniffing: return "🥺"
        case .confused: return "😕"
        case .curious: return "🧐"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .neutral: return "face.smiling"
        case .happy: return "face.smiling.fill"
        case .sad: return "face.dashed"
        case .crying: return "drop.triangle.fill"
        case .angry: return "exclamationmark.triangle"
        case .annoyed: return "smoke.fill"
        case .questioning: return "questionmark.circle"
        case .calm: return "leaf.fill"
        case .excited: return "sparkles"
        case .humming: return "music.note"
        case .sniffing: return "bandage.fill"
        case .confused: return "questionmark.face"
        case .curious: return "eyes.inverse"
        }
    }
    
    var displayName: String {
        switch self {
        case .neutral: return "Neutral"
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .crying: return "Crying"
        case .angry: return "Angry"
        case .annoyed: return "Annoyed"
        case .questioning: return "Questioning"
        case .calm: return "Calm"
        case .excited: return "Excited"
        case .humming: return "Humming"
        case .sniffing: return "Sniffing"
        case .confused: return "Confused"
        case .curious: return "Curious"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .neutral: return .gray
        case .happy: return .yellow
        case .sad: return .blue
        case .crying: return .indigo
        case .angry: return .red
        case .annoyed: return .orange
        case .questioning: return .purple
        case .calm: return .teal
        case .excited: return .pink
        case .humming: return .mint
        case .sniffing: return .brown
        case .confused: return .orange
        case .curious: return .purple
        }
    }
}
