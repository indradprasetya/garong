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

    var body: some View {
        ZStack(alignment: .top) {
            if scene.isUnlocked {
                // Main Content Area: Single Column or Vertically Split Columns (centered character image)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    if scene.dropSlots.count > 1 {
                        HStack(spacing: 0) {
                            ForEach(Array(scene.dropSlots.enumerated()), id: \.element.id) { index, slot in
                                let charImage = scene.characterImageNames.indices.contains(index)
                                    ? scene.characterImageNames[index]
                                    : AssetFallbackHelper.imageName(for: slot.targetCharacterID ?? "")
                                
                                SceneColumnDropZone(
                                    slot: slot,
                                    characterImageName: charImage,
                                    characterEmotion: scene.characterEmotion,
                                    isAnimating: isAnimating,
                                    onDrop: { obj in onDrop(obj, slot.id) },
                                    onRemove: { obj in onRemoveObject(obj, slot.id) }
                                )
                            }
                        }
                    } else if let singleSlot = scene.dropSlots.first {
                        SceneColumnDropZone(
                            slot: singleSlot,
                            characterImageName: scene.characterImageNames.first ?? "Globe",
                            characterEmotion: scene.characterEmotion,
                            isAnimating: isAnimating,
                            onDrop: { obj in onDrop(obj, singleSlot.id) },
                            onRemove: { obj in onRemoveObject(obj, singleSlot.id) }
                        )
                    } else {
                        // Outcome scene grid when unlocked
                        VStack(spacing: 4) {
                            Spacer(minLength: 0)
                            CharacterView(
                                imageName: scene.characterImageNames.first ?? "Globe",
                                emotion: scene.characterEmotion,
                                isReacting: isAnimating
                            )
                            .frame(maxHeight: 110)
                            Spacer(minLength: 0)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                
                // Speech Bubble Overlay if present
                if let bubble = scene.speechBubbleText, !bubble.isEmpty {
                    Text(bubble)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                        )
                        .padding(.top, 4)
                }
            } else {
                // Locked Scene Grid Frame (card remains present in layout, image hidden)
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(scene.name)
                        .font(.caption.bold())
                        .foregroundColor(.secondary.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(scene.isUnlocked ? 0.92 : 0.58))
                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color(UIColor.separator).opacity(0.4),
                    style: StrokeStyle(lineWidth: 1, dash: scene.isUnlocked ? [] : [6, 4])
                )
        )
        .scaleEffect(isAnimating ? 1.02 : 1.0)
    }
}

/// A vertical half-column dropzone inside a scene frame with individual character droppable visual highlights.
struct SceneColumnDropZone: View {
    let slot: GameDropSlot
    let characterImageName: String
    let characterEmotion: CharacterEmotion
    let isAnimating: Bool
    let onDrop: (GameObject) -> Void
    let onRemove: (GameObject) -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 4) {
            Spacer(minLength: 0)
            
            // Character image centered horizontally & vertically in the column
            CharacterView(
                imageName: characterImageName,
                emotion: characterEmotion,
                isReacting: isAnimating
            )
            .frame(maxHeight: 110)
            
            Spacer(minLength: 0)
            
            // Placed Item or Character Slot Badge at bottom
            if let placedObj = slot.currentObject {
                HStack(spacing: 4) {
                    #if canImport(UIKit)
                    if !placedObj.symbol.isEmpty, UIImage(named: placedObj.symbol) != nil {
                        Image(placedObj.symbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    } else {
                        Image(systemName: placedObj.sfSymbol)
                            .font(.system(size: 16))
                            .foregroundColor(GarongTheme.teal)
                    }
                    #else
                    Image(systemName: placedObj.sfSymbol)
                        .font(.system(size: 16))
                        .foregroundColor(GarongTheme.teal)
                    #endif
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                                .fill(GarongTheme.mint)
                )
                .instantDraggable(placedObj) {
                    #if canImport(UIKit)
                    if !placedObj.symbol.isEmpty, UIImage(named: placedObj.symbol) != nil {
                        Image(placedObj.symbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .shadow(radius: 6)
                    } else {
                        Image(systemName: placedObj.sfSymbol)
                            .font(.system(size: 38))
                            .shadow(radius: 6)
                    }
                    #else
                    Image(systemName: placedObj.sfSymbol)
                        .font(.system(size: 38))
                    #endif
                }
            } else if slot.label != "Scene" {
                Text(slot.label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isTargeted ? GarongTheme.teal : .secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(isTargeted ? GarongTheme.teal.opacity(0.18) : Color.clear)
                    )
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isTargeted ? GarongTheme.teal.opacity(0.18) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isTargeted ? GarongTheme.teal : Color.clear,
                    style: StrokeStyle(lineWidth: isTargeted ? 3 : 0, dash: isTargeted ? [5, 3] : [])
                )
        )
        .scaleEffect(isTargeted ? 1.03 : 1.0)
        .dropDestination(for: GameObject.self) { items, location in
            guard let firstItem = items.first else { return false }
            withAnimation(.spring()) {
                onDrop(firstItem)
            }
            return true
        } isTargeted: { targeted in
            withAnimation(.easeInOut(duration: 0.2)) {
                isTargeted = targeted
            }
        }
    }
}

struct SceneDropZoneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneDropZoneView(
            scene: SampleGameData.chapters[0].scenes[0],
            isAnimating: false,
            isDraggingAnyItem: false,
            onDrop: { _, _ in },
            onRemoveObject: { _, _ in }
        )
        .frame(width: 240, height: 220)
        .padding()
    }
}
