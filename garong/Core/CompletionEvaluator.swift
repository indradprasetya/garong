//  CompletionEvaluator.swift
//  garong
//

import Foundation

/// Evaluates whether a chapter's completion conditions are met.
final class CompletionEvaluator {
    
    func isComplete(
        rule: CompletionRule,
        scenes: [GameScene],
        totalObjects: Int
    ) -> Bool {
        switch rule {
        case .allObjectsPlaced:
            let placedCount = scenes.reduce(0) { $0 + $1.objects.count }
            return placedCount >= totalObjects
            
        case .specificObjectsInScenes:
            // Future: check specific object-scene combos
            return false
        }
    }
}
