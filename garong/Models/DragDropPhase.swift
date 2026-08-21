//  DragDropPhase.swift
//  garong
//

import Foundation

/// State machine phases for drag-and-drop gameplay.
enum DragDropPhase: Equatable {
    /// Active gameplay — user can drag objects into scenes.
    case playing
    /// Placement limit reached; the chapter character needs a break.
    case needsBreak
    /// Chapter completion triggered.
    case completed
}

enum PlacementFeedbackState: Equatable {
    case green
    case yellow
    case orange
    case red

    var meterStars: Int {
        switch self {
        case .green: 3
        case .yellow: 2
        case .orange: 1
        case .red: 0
        }
    }
}
