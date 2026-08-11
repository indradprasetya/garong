//  DragDropPhase.swift
//  garong
//

import Foundation

/// State machine phases for drag-and-drop gameplay.
enum DragDropPhase: Equatable {
    /// Active gameplay — user can drag objects into scenes.
    case playing
    /// Chapter completion triggered.
    case completed
}
