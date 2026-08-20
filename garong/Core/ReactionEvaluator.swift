//
//  ReactionEvaluator.swift
//  garong
//

import Foundation

/// Protocol defining how scene object states map to character emotions.
protocol ReactionEvaluating {
    /// Evaluates dynamic chained reactions across all 3 scenes simultaneously.
    func evaluateReactions(for scenes: [GameScene]) -> [CharacterEmotion]
    /// Single scene evaluator fallback.
    func evaluate(objects: [GameObject]) -> CharacterEmotion
}

/// Dynamic chained reaction evaluator.
/// Evaluates each scene's emotion based on its own item AND the global combination of items across all 3 scenes.
final class DefaultReactionEvaluator: ReactionEvaluating {
    
    func evaluateReactions(for scenes: [GameScene]) -> [CharacterEmotion] {
        guard !scenes.isEmpty else { return [] }
        
        let item1 = scenes.indices.contains(0) ? scenes[0].currentObject?.name : nil
        let item2 = scenes.indices.contains(1) ? scenes[1].currentObject?.name : nil
        let item3 = scenes.indices.contains(2) ? scenes[2].currentObject?.name : nil
        
        let placedItems = [item1, item2, item3].compactMap { $0 }
        let uniqueItems = Set(placedItems)
        
        // --- Case 1: No items anywhere ---
        if placedItems.isEmpty {
            return scenes.map { _ in .neutral }
        }
        
        // --- Case 2: Same item across all 3 scenes ---
        if placedItems.count == 3 && uniqueItems.count == 1 {
            return [.excited, .excited, .excited]
        }
        
        var emotions: [CharacterEmotion] = []
        
        for (index, scene) in scenes.enumerated() {
            let item = scene.currentObject?.name
            
            // --- Chained Combo 1: Teddy + Apple anywhere ---
            if uniqueItems.contains("Teddy") && uniqueItems.contains("Apple") {
                if item == "Teddy" {
                    emotions.append(.excited)
                } else if item == "Apple" {
                    emotions.append(.happy)
                } else {
                    emotions.append(.curious)
                }
                continue
            }
            
            // --- Chained Combo 2: Teddy + Book anywhere ---
            if uniqueItems.contains("Teddy") && uniqueItems.contains("Book") {
                if item == "Teddy" {
                    emotions.append(.happy)
                } else if item == "Book" {
                    emotions.append(.excited)
                } else {
                    emotions.append(.calm)
                }
                continue
            }
            
            // --- Chained Combo 3: Apple + Book anywhere ---
            if uniqueItems.contains("Apple") && uniqueItems.contains("Book") {
                if item == "Apple" {
                    emotions.append(.excited)
                } else if item == "Book" {
                    emotions.append(.curious)
                } else {
                    emotions.append(.happy)
                }
                continue
            }
            
            // --- Chained Combo 4: Toy Car + Ball anywhere ---
            if uniqueItems.contains("Toy Car") && uniqueItems.contains("Ball") {
                if item == "Toy Car" || item == "Ball" {
                    emotions.append(.excited)
                } else {
                    emotions.append(.happy)
                }
                continue
            }
            
            // --- Chained Combo 5: All 3 scenes filled with 3 distinct items ---
            if placedItems.count == 3 && uniqueItems.count == 3 {
                if index == 0 { emotions.append(.excited) }
                else if index == 1 { emotions.append(.curious) }
                else { emotions.append(.happy) }
                continue
            }
            
            // --- Single Item / Default Base Reaction ---
            if let itemName = item {
                switch itemName {
                case "Teddy":   emotions.append(.happy)
                case "Apple":   emotions.append(.curious)
                case "Book":    emotions.append(.calm)
                case "Toy Car": emotions.append(.excited)
                case "Ball":    emotions.append(.happy)
                default:        emotions.append(.neutral)
                }
            } else {
                // Empty scene when other scenes have items
                emotions.append(placedItems.count >= 2 ? .curious : .neutral)
            }
        }
        
        return emotions
    }
    
    func evaluate(objects: [GameObject]) -> CharacterEmotion {
        guard let first = objects.first else { return .neutral }
        switch first.name {
        case "Teddy":   return .happy
        case "Apple":   return .curious
        case "Book":    return .calm
        case "Toy Car": return .excited
        case "Ball":    return .happy
        default:        return .neutral
        }
    }
}
