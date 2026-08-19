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
    @State private var targetedCharIndex: Int? = nil

    var body: some View {
        GeometryReader { geo in
            let cardW = geo.size.width
            let cardH = geo.size.height
            let cornerRadius = max(6, cardH * 0.095)

            ZStack {
                // 1. Container Frame Base
                if AssetFallbackHelper.hasAsset(named: containerImageName) {
                    Image(containerImageName)
                        .resizable()
                        .scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
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
                                .clipped()
                        }

                        // Determine characters to render (supports multiple character image names or target slots)
                        let displayImages: [String] = {
                            if !scene.characterImageNames.isEmpty {
                                return scene.characterImageNames
                            }
                            let slotChars = scene.dropSlots.compactMap { slot -> String? in
                                guard let charID = slot.targetCharacterID, !charID.isEmpty else { return nil }
                                return AssetFallbackHelper.imageName(for: charID)
                            }
                            return slotChars.isEmpty ? ["fallback_globe"] : slotChars
                        }()

                        let isMultiChar = displayImages.count > 1
                        let charMaxH = isMultiChar ? cardH * 0.55 : cardH * 0.62

                        // Character(s) Anchored to Bottom
                        HStack(spacing: isMultiChar ? -cardW * 0.02 : 0) {
                            ForEach(Array(displayImages.enumerated()), id: \.offset) { index, charImage in
                                let isWiggling = (targetedCharIndex == index)
                                CharacterView(
                                    imageName: charImage,
                                    emotion: scene.characterEmotion,
                                    isReacting: isAnimating,
                                    isWiggling: isWiggling
                                )
                                .frame(maxHeight: charMaxH)
                                .offset(y: cardH * 0.02)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                        // Top Speech Bubble Banner
                        if let bubble = scene.speechBubbleText, !bubble.isEmpty {
                            let bubbleH = cardH * 0.38
                            let fontSize = max(9, min(cardH * 0.09, cardW * 0.08))
                            let bottomPadding = cardH * 0.12
                            let horizPadding = cardW * 0.05

                            VStack(spacing: 0) {
                                ZStack {
                                    if AssetFallbackHelper.hasAsset(named: "bubble_respond") {
                                        Image("bubble_respond")
                                            .resizable()
                                            .scaledToFit()
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(red: 0.18, green: 0.53, blue: 0.44))
                                    }
                                    
                                    Text(bubble)
                                        .font(.appFont(size: fontSize, relativeTo: .body))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        .padding(.horizontal, horizPadding)
                                        .padding(.bottom, bottomPadding)
                                }
                                .frame(maxWidth: cardW * 0.90)
                                .frame(height: bubbleH)
                                .clipped()
                                
                                Spacer(minLength: 0)
                            }
                        }

                        // Drop Target Overlays (Split left/right when multiple slots exist)
                        if scene.dropSlots.count > 1 {
                            HStack(spacing: 0) {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .dropDestination(for: GameObject.self) { items, _ in
                                        guard let firstItem = items.first else { return false }
                                        withAnimation(.spring()) {
                                            targetedCharIndex = nil
                                            onDrop(firstItem, scene.dropSlots[0].id)
                                        }
                                        return true
                                    } isTargeted: { targeted in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            targetedCharIndex = targeted ? 0 : nil
                                            if targeted { isHoveringDrag = true }
                                        }
                                    }
                                
                                Color.clear
                                    .contentShape(Rectangle())
                                    .dropDestination(for: GameObject.self) { items, _ in
                                        guard let firstItem = items.first else { return false }
                                        withAnimation(.spring()) {
                                            targetedCharIndex = nil
                                            onDrop(firstItem, scene.dropSlots[1].id)
                                        }
                                        return true
                                    } isTargeted: { targeted in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            targetedCharIndex = targeted ? 1 : nil
                                            if targeted { isHoveringDrag = true }
                                        }
                                    }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Color.clear
                                .contentShape(Rectangle())
                                .dropDestination(for: GameObject.self) { items, _ in
                                    guard let firstItem = items.first, let slot = scene.dropSlots.first else { return false }
                                    withAnimation(.spring()) {
                                        targetedCharIndex = nil
                                        onDrop(firstItem, slot.id)
                                    }
                                    return true
                                } isTargeted: { targeted in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        targetedCharIndex = targeted ? 0 : nil
                                        isHoveringDrag = targeted
                                    }
                                }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }

                        // Corner Drop Item Slot Badge(s) - Only visible when an item is placed in the scene
                        if !scene.dropSlots.isEmpty {
                            let badgeSize = max(22, cardH * 0.22)
                            HStack {
                                if let firstSlot = scene.dropSlots.first, let placedObj = firstSlot.currentObject {
                                    CornerDropSlotBadge(
                                        slot: firstSlot,
                                        placedObject: placedObj,
                                        badgeSize: badgeSize,
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
                                        badgeSize: badgeSize,
                                        onTargetChanged: { targeted in isHoveringDrag = targeted },
                                        onDrop: { obj in onDrop(obj, scene.dropSlots[1].id) },
                                        onRemove: { obj in onRemoveObject(obj, scene.dropSlots[1].id) }
                                    )
                                }
                            }
                            .padding(cardH * 0.03)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .padding(cardH * 0.035)
                    .clipped()
                } else {
                    // Locked Scene Grid Frame
                    let lockIconSize = max(14, cardH * 0.15)
                    let lockTextSize = max(9, cardH * 0.09)
                    VStack(spacing: cardH * 0.04) {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.system(size: lockIconSize))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text(scene.name)
                            .font(.appFont(size: lockTextSize, relativeTo: .caption))
                            .foregroundColor(.secondary.opacity(0.6))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .aspectRatio(212.0 / 147.0, contentMode: .fit)
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    var badgeSize: CGFloat = 42
    var onTargetChanged: ((Bool) -> Void)? = nil
    let onDrop: (GameObject) -> Void
    let onRemove: (GameObject) -> Void

    @State private var isTargeted = false

    var body: some View {
        let hasAsset = !placedObject.symbol.isEmpty && AssetFallbackHelper.hasAsset(named: placedObject.symbol)
        let cornerRadius = max(4, badgeSize * 0.19)
        let iconFontSize = max(12, badgeSize * 0.48)
        let imagePadding = max(2, badgeSize * 0.095)

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isTargeted ? Color.accentColor : Color.black.opacity(0.7), lineWidth: isTargeted ? 2 : 1.5)

            Group {
                if hasAsset {
                    Image(placedObject.symbol)
                        .resizable()
                        .scaledToFit()
                        .padding(imagePadding)
                } else {
                    Image(systemName: placedObject.sfSymbol)
                        .font(.system(size: iconFontSize))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .frame(width: badgeSize, height: badgeSize)
        .scaleEffect(isTargeted ? 1.1 : 1.0)
        .instantDraggable(placedObject) {
            if hasAsset {
                Image(placedObject.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: badgeSize * 1.14, height: badgeSize * 1.14)
                    .shadow(radius: 6)
            } else {
                Image(systemName: placedObject.sfSymbol)
                    .font(.system(size: iconFontSize * 1.9))
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
            speechBubbleText: "I don't want to draw right now!",
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
            HStack {
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
