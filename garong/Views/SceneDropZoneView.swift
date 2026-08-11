//
//  SceneDropZoneView.swift
//  garong
//

import SwiftUI
import UniformTypeIdentifiers

struct SceneDropZoneView: View {
    let scene: GameScene
    let isAnimating: Bool
    let onDrop: (GameObject) -> Void
    let onRemoveObject: (GameObject) -> Void
    
    @State private var isTargeted = false
    
    var body: some View {
        VStack(spacing: 6) {
            // Scene Title & Description
            VStack(spacing: 2) {
                Text(scene.name)
                    .font(.subheadline.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(scene.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
            
            // Character View with Reaction Animation
            CharacterView(emotion: scene.characterEmotion, isReacting: isAnimating)
                .frame(height: 85)
                .padding(.vertical, 2)
            
            Spacer(minLength: 2)
            
            // Single Placed Item Container
            HStack {
                if let placedObj = scene.currentObject {
                    HStack(spacing: 8) {
                        Text(placedObj.symbol)
                            .font(.system(size: 26))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(placedObj.name)
                                .font(.caption.bold())
                                .foregroundColor(.primary)
                            Text("Tap to remove")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer(minLength: 4)
                        
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.tertiarySystemGroupedBackground))
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            onRemoveObject(placedObj)
                        }
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.square.dashed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Drop item here")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 6)
            .background(Color(UIColor.secondarySystemGroupedBackground).opacity(0.7))
            .cornerRadius(10)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: isTargeted ? Color.accentColor.opacity(0.5) : Color.black.opacity(0.08), radius: isTargeted ? 8 : 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isTargeted ? Color.accentColor : Color(UIColor.separator).opacity(0.5), lineWidth: isTargeted ? 3 : 1)
        )
        .scaleEffect(isAnimating ? 1.03 : 1.0)
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
            onDrop: { _ in },
            onRemoveObject: { _ in }
        )
        .frame(width: 220, height: 220)
        .padding()
    }
}
