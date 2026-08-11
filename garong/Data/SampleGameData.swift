//  SampleGameData.swift
//  garong
//

import Foundation

/// Provides default game data for the prototype.
enum SampleGameData {
    
    // MARK: - Default Objects
    
    static let teddy = GameObject(name: "Teddy", symbol: "🧸", sfSymbol: "teddybear.fill")
    static let apple = GameObject(name: "Apple", symbol: "🍎", sfSymbol: "apple.logo")
    static let book = GameObject(name: "Book", symbol: "📖", sfSymbol: "book.fill")
    static let toyCar = GameObject(name: "Toy Car", symbol: "🪀", sfSymbol: "car.fill")
    static let ball = GameObject(name: "Ball", symbol: "🎈", sfSymbol: "circle.fill")
    
    static let defaultObjects: [GameObject] = [teddy, apple, book, toyCar, ball]
    
    // MARK: - Chapters
    
    static let chapters: [Chapter] = [
        Chapter(
            number: 1,
            name: "The Playroom",
            description: "Help three children feel comfortable by giving them the right objects.",
            scenes: [
                GameScene(
                    name: "Scene 1",
                    description: "A shy child sitting alone in the corner"
                ),
                GameScene(
                    name: "Scene 2",
                    description: "A bored child looking out the window"
                ),
                GameScene(
                    name: "Scene 3",
                    description: "A curious child exploring the room"
                )
            ],
            objects: defaultObjects,
            completionRule: .allObjectsPlaced,
            isUnlocked: true
        ),
        Chapter(
            number: 2,
            name: "The Garden",
            description: "Outdoor exploration with nature and friends.",
            scenes: [
                GameScene(name: "Scene 1", description: "Near the pond"),
                GameScene(name: "Scene 2", description: "Under the tree"),
                GameScene(name: "Scene 3", description: "In the sandbox")
            ],
            objects: defaultObjects,
            completionRule: .allObjectsPlaced,
            isUnlocked: false
        ),
        Chapter(
            number: 3,
            name: "The Kitchen",
            description: "Cooking time! Help children discover food and tools.",
            scenes: [
                GameScene(name: "Scene 1", description: "At the table"),
                GameScene(name: "Scene 2", description: "Near the stove"),
                GameScene(name: "Scene 3", description: "By the fridge")
            ],
            objects: defaultObjects,
            completionRule: .allObjectsPlaced,
            isUnlocked: false
        )
    ]
}
