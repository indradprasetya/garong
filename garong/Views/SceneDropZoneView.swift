//
//  SceneDropZoneView.swift
//  garong
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import UniformTypeIdentifiers

struct SceneDropZoneView: View {
    let scene: GameScene
    let isAnimating: Bool
    let isDraggingAnyItem: Bool
    let onDrop: (GameObject, String?) -> Void
    let onRemoveObject: (GameObject, String?) -> Void
    var onDragStarted: (() -> Void)? = nil
    var onDragEnded: (() -> Void)? = nil

    @State private var isHoveringDrag = false

    var body: some View {
        ZStack {
            // 1. Container Frame Base
            if AssetFallbackHelper.hasAsset(named: containerImageName) {
                Image(containerImageName)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(UIColor.secondarySystemGroupedBackground).opacity(scene.isUnlocked ? 1.0 : 0.6))
            }

            if scene.isUnlocked {
                // 2. Inner Scene Content Inset & Clipped Inside Container Frame
                ZStack(alignment: .bottom) {
                    // Inner Classroom / Scene Background
                    if AssetFallbackHelper.hasAsset(named: scene.backgroundImageName) {
                        Image(scene.backgroundImageName)
                            .resizable()
                            .scaledToFill()
                    }

                    // Character(s) Anchored to Bottom
                    if scene.dropSlots.count > 1 {
                        HStack(spacing: 6) {
                            ForEach(Array(scene.dropSlots.enumerated()), id: \.element.id) { index, slot in
                                let charImage = scene.characterImageNames.indices.contains(index)
                                    ? scene.characterImageNames[index]
                                    : AssetFallbackHelper.imageName(for: slot.targetCharacterID ?? "")
                                
                                CharacterView(
                                    imageName: charImage,
                                    emotion: scene.characterEmotion,
                                    isReacting: isAnimating
                                )
                                .frame(maxHeight: 110)
                                .offset(y: 8)
                            }
                        }
                    } else {
                        let charImage = scene.characterImageNames.first ?? "fallback_globe"
                        CharacterView(
                            imageName: charImage,
                            emotion: scene.characterEmotion,
                            isReacting: isAnimating
                        )
                        .frame(maxHeight: 115)
                        .offset(y: 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }

                    // Top Speech Bubble Banner
                    if let bubble = scene.speechBubbleText, !bubble.isEmpty {
                        VStack(spacing: 0) {
                            ZStack {
                                if AssetFallbackHelper.hasAsset(named: "bubble_respond") {
                                    Image("bubble_respond")
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.18, green: 0.53, blue: 0.44))
                                }
                                
                                Text(bubble)
                                    .font(.appFont(size: 20, relativeTo: .body))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 24)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 69)
                            
                            Spacer(minLength: 0)
                        }
                    }

                    // Corner Drop Item Slot Badge(s) - Only visible when an item is placed in the scene
                    if !scene.dropSlots.isEmpty {
                        HStack {
                            if let firstSlot = scene.dropSlots.first, let placedObj = firstSlot.currentObject {
                                CornerDropSlotBadge(
                                    slot: firstSlot,
                                    placedObject: placedObj,
                                    onTargetChanged: { targeted in isHoveringDrag = targeted },
                                    onDrop: { obj in onDrop(obj, firstSlot.id) },
                                    onRemove: { obj in onRemoveObject(obj, firstSlot.id) }
                                )
                            }
                            
                            Spacer()
                            
                            if scene.dropSlots.count > 1, let secondPlacedObj = scene.dropSlots[1].currentObject {
                                CornerDropSlotBadge(
                                    slot: scene.dropSlots[1],
                                    placedObject: secondPlacedObj,
                                    onTargetChanged: { targeted in isHoveringDrag = targeted },
                                    onDrop: { obj in onDrop(obj, scene.dropSlots[1].id) },
                                    onRemove: { obj in onRemoveObject(obj, scene.dropSlots[1].id) }
                                )
                            }
                        }
                        .padding(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(5)
            } else {
                // Locked Scene Grid Frame
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(scene.name)
                        .font(.appFont(size: 13, relativeTo: .caption))
                        .foregroundColor(.secondary.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .aspectRatio(212.0 / 147.0, contentMode: .fit)
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dropDestination(for: GameObject.self) { items, location in
            guard let firstItem = items.first, let targetSlot = scene.dropSlots.first(where: { $0.currentObject == nil }) ?? scene.dropSlots.first else { return false }
            withAnimation(.spring()) {
                onDrop(firstItem, targetSlot.id)
            }
            return true
        } isTargeted: { targeted in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHoveringDrag = targeted
            }
        }
    }

    private var containerImageName: String {
        if !scene.isUnlocked {
            return "container_lock"
        }
        if isDraggingAnyItem || isHoveringDrag {
            return "container_drag"
        }
        return "container"
    }
}

/// A small rounded square drop badge located in the corner of a scene card (visible when an item is placed).
struct CornerDropSlotBadge: View {
    let slot: GameDropSlot
    let placedObject: GameObject
    var onTargetChanged: ((Bool) -> Void)? = nil
    let onDrop: (GameObject) -> Void
    let onRemove: (GameObject) -> Void

    @State private var isTargeted = false

    var body: some View {
        let hasAsset = !placedObject.symbol.isEmpty && AssetFallbackHelper.hasAsset(named: placedObject.symbol)

        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)

            RoundedRectangle(cornerRadius: 8)
                .stroke(isTargeted ? Color.accentColor : Color.black.opacity(0.7), lineWidth: isTargeted ? 2 : 1.5)

            Group {
                if hasAsset {
                    Image(placedObject.symbol)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                } else {
                    Image(systemName: placedObject.sfSymbol)
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .frame(width: 42, height: 42)
        .scaleEffect(isTargeted ? 1.1 : 1.0)
        .instantDraggable(placedObject) {
            if hasAsset {
                Image(placedObject.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .shadow(radius: 6)
            } else {
                Image(systemName: placedObject.sfSymbol)
                    .font(.system(size: 38))
                    .shadow(radius: 6)
            }
        }
        .dropDestination(for: GameObject.self) { items, location in
            guard let firstItem = items.first else { return false }
            withAnimation(.spring()) {
                onDrop(firstItem)
            }
            return true
        } isTargeted: { targeted in
            withAnimation(.easeInOut(duration: 0.2)) {
                isTargeted = targeted
                onTargetChanged?(targeted)
            }
        }
    }
}

struct SceneDropZoneView_Previews: PreviewProvider {
    static var previews: some View {
        let placedItem = GameObject(
            id: UUID(),
            name: "Apologize",
            symbol: "action_apologize",
            sfSymbol: "hands.sparkles.fill"
        )
        
        let fullAttributeScene = GameScene(
            id: UUID(),
            name: "Grid 1",
            description: "Rhodey is upset",
            dropSlots: [
                GameDropSlot(
                    id: "slot_rhodey",
                    label: "Rhodey",
                    targetCharacterID: "rhodey",
                    currentObject: placedItem
                )
            ],
            characterEmotion: .angry,
            speechBubbleText: "I don't want to go!",
            characterImageNames: ["rhodey_crying"],
            isUnlocked: true,
            backgroundID: "background_classroom"
        )
        
        let twoCharScene = GameScene(
            id: UUID(),
            name: "Grid 2",
            description: "Rhodey and Jojo talking",
            dropSlots: [
                GameDropSlot(
                    id: "slot_jojo",
                    label: "Jojo",
                    targetCharacterID: "jojo",
                    currentObject: GameObject(name: "Candy", symbol: "action_candy", sfSymbol: "heart.fill")
                ),
                GameDropSlot(
                    id: "slot_rhodey",
                    label: "Rhodey",
                    targetCharacterID: "rhodey",
                    currentObject: nil
                )
            ],
            characterEmotion: .happy,
            speechBubbleText: "Thank you for helping me!",
            characterImageNames: ["jojo_happy", "rhodey_happy"],
            isUnlocked: true,
            backgroundID: "background_classroom"
        )

        let lockedScene = GameScene(
            id: UUID(),
            name: "Grid 3",
            description: "Locked scene",
            dropSlots: [GameDropSlot(id: "slot_3", label: "Scene", targetCharacterID: nil, currentObject: nil)],
            characterEmotion: .neutral,
            speechBubbleText: nil,
            characterImageNames: [],
            isUnlocked: false,
            backgroundID: "background_classroom"
        )

        return Group {
            SceneDropZoneView(
                scene: fullAttributeScene,
                isAnimating: false,
                isDraggingAnyItem: false,
                onDrop: { _, _ in },
                onRemoveObject: { _, _ in }
            )
            .frame(width: 212, height: 147)
            .padding()
            .previewDisplayName("Full Attributes (Mockup Style)")

            SceneDropZoneView(
                scene: twoCharScene,
                isAnimating: false,
                isDraggingAnyItem: false,
                onDrop: { _, _ in },
                onRemoveObject: { _, _ in }
            )
            .frame(width: 212, height: 147)
            .padding()
            .previewDisplayName("2-Character Scene")

            SceneDropZoneView(
                scene: lockedScene,
                isAnimating: false,
                isDraggingAnyItem: false,
                onDrop: { _, _ in },
                onRemoveObject: { _, _ in }
            )
            .frame(width: 212, height: 147)
            .padding()
            .previewDisplayName("Locked Scene")
        }
        .previewLayout(.sizeThatFits)
    }
}
