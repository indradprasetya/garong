//
//  GameScene.swift
//  garong
//

import Foundation

/// Defines a specific drop slot within a scene grid (e.g. "For Jojo", "For Rhodey", or general "Scene").
struct GameDropSlot: Identifiable, Equatable {
    let id: String                // e.g. "slot_jojo", "slot_rhodey", "slot_scene"
    let label: String             // e.g. "Jojo", "Rhodey", "Scene"
    let targetCharacterID: String?// e.g. "jojo", "rhodey"
    var currentObject: GameObject?
}

/// Represents one of the interactive scenes in the gameplay view.
/// Each scene can hold 1 or more character drop slots and multiple characters.
struct GameScene: Identifiable, Equatable {
    let id: UUID
    let name: String           // e.g. "Grid 1"
    let description: String    // e.g. "Scene 1 of 4"
    var dropSlots: [GameDropSlot]
    var characterEmotion: CharacterEmotion  // Current reaction
    var speechBubbleText: String?
    var characterImageNames: [String]
    var isUnlocked: Bool
    var backgroundID: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        dropSlots: [GameDropSlot] = [GameDropSlot(id: "slot_scene", label: "Scene", targetCharacterID: nil)],
        characterEmotion: CharacterEmotion = .neutral,
        speechBubbleText: String? = nil,
        characterImageNames: [String] = [],
        isUnlocked: Bool = true,
        backgroundID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.dropSlots = dropSlots
        self.characterEmotion = characterEmotion
        self.speechBubbleText = speechBubbleText
        self.characterImageNames = characterImageNames
        self.isUnlocked = isUnlocked
        self.backgroundID = backgroundID
    }
    
    /// Convenience initializer for single object / single image backward compatibility.
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        currentObject: GameObject?,
        characterEmotion: CharacterEmotion = .neutral,
        speechBubbleText: String? = nil,
        characterImageName: String? = nil,
        isUnlocked: Bool = true,
        backgroundID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.dropSlots = [GameDropSlot(id: "slot_scene", label: "Scene", targetCharacterID: nil, currentObject: currentObject)]
        self.characterEmotion = characterEmotion
        self.speechBubbleText = speechBubbleText
        self.characterImageNames = characterImageName != nil ? [characterImageName!] : []
        self.isUnlocked = isUnlocked
        self.backgroundID = backgroundID
    }

    /// Helper resolving the image name for the scene background.
    var backgroundImageName: String {
        AssetFallbackHelper.backgroundImageName(for: backgroundID ?? "background_classroom")
    }

    /// Single image name backward compatibility helper.
    var characterImageName: String? {
        get { characterImageNames.first }
        set {
            if let val = newValue {
                characterImageNames = [val]
            } else {
                characterImageNames = []
            }
        }
    }

    /// Single object getter/setter for backward compatibility.
    var currentObject: GameObject? {
        get { dropSlots.first?.currentObject }
        set {
            if !dropSlots.isEmpty {
                dropSlots[0].currentObject = newValue
            }
        }
    }
    
    /// Helper array representation for compatibility.
    var objects: [GameObject] {
        dropSlots.compactMap(\.currentObject)
    }
    
    /// Whether this scene currently contains any object.
    var hasObjects: Bool {
        dropSlots.contains { $0.currentObject != nil }
    }

    /// Number of objects placed in this scene.
    var objectCount: Int {
        dropSlots.reduce(0) { $0 + ($1.currentObject != nil ? 1 : 0) }
    }
}
