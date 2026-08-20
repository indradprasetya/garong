//
//  GameplayView.swift
//  garong
//

import SwiftUI

/// Main gameplay screen — landscape layout with 3 scenes, centered object tray, and explicit Finish button.
struct GameplayView: View {
    @StateObject private var viewModel: DragDropGameViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(chapter: Chapter) {
        _viewModel = StateObject(wrappedValue: DragDropGameViewModel(chapter: chapter))
    }
    
    var body: some View {
        ZStack {
            // Background fill extending into edges - Acts as unattach drop target when dragging placed items outside
            Group {
                if AssetFallbackHelper.hasAsset(named: "gameplay_background") {
                    Image("gameplay_background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                }
            }
            .dropDestination(for: GameObject.self) { items, _ in
                for item in items {
                    withAnimation(.spring()) {
                        viewModel.removeObjectGlobal(item)
                    }
                }
                viewModel.setDraggingActive(false)
                return true
            }

            // Content container padded away from device hardware edges and notch
            VStack(spacing: 6) {
                // Top Bar
                HStack(spacing: 16) {
                    Button {
                        SoundManager.shared.play(.backTap)
                        dismiss()
                    } label: {
                        if AssetFallbackHelper.hasAsset(named: "back_button") {
                            Image("back_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                        } else {
                            Image(systemName: "arrowshape.backward.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(viewModel.chapterName)
                        .font(.appFont(size: 38))
                        .padding(.top, 12)
                    
                    Spacer()
                    
                    // Next Chapter Chevron Button ALWAYS visible beside outcome grid (disabled until unlocked)
                    if let outcomeScene = viewModel.scenes.last {
                        let isReady = outcomeScene.isUnlocked
                        Button {
                            SoundManager.shared.play(.buttonTap)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.goToNextChapterOrFinish()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Next")
                                    .font(.appFont(size: 13, relativeTo: .caption))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isReady ? Color.accentColor : Color(UIColor.tertiaryLabel))
                                    .shadow(color: isReady ? Color.accentColor.opacity(0.4) : Color.clear, radius: 6, x: 0, y: 3)
                            )
                        }
                        .disabled(!isReady)
                        .opacity(isReady ? 1.0 : 0.45)
                    }
                }
                .padding(.horizontal, 8)
                .ignoresSafeArea(edges: .top)
                
                
                
                Spacer()
                
                
                // Main Scenes Area - 2x2 LazyVGrid for 4 scenes (fitted to container), horizontal layout for others
                Group {
                    if viewModel.scenes.count == 4 {
                        GeometryReader { geo in
                            let spacing: CGFloat = 8
                            let cardAspectRatio: CGFloat = 212.0 / 147.0
                            let hFromHeight = max(0, (geo.size.height - spacing) / 1.8)
                            let hFromWidth = max(0, (geo.size.width - spacing) / (2 * cardAspectRatio))
                            let cardH = min(hFromHeight, hFromWidth)
                            let cardW = cardH * cardAspectRatio
                            let gridColumns = [
                                GridItem(.fixed(cardW), spacing: spacing),
                                GridItem(.fixed(cardW), spacing: spacing)
                            ]
                            
                            VStack {
                                Spacer(minLength: 0)
                                LazyVGrid(columns: gridColumns, spacing: spacing) {
                                    ForEach(0..<viewModel.scenes.count, id: \.self) { index in
                                        sceneView(for: viewModel.scenes[index])
                                            .frame(width: cardW, height: cardH)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        }
                    } else {
                        HStack(spacing: 8) {
                            ForEach(viewModel.scenes, id: \.id) { scene in
                                sceneView(for: scene)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Bottom Tray (CENTERED Draggable Objects - also unattached when dropped here)
                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.availableObjects, id: \.id) { object in
                            DraggableObjectView(object: object)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 80)
                .dropDestination(for: GameObject.self) { items, _ in
                    for item in items {
                        withAnimation(.spring()) {
                            viewModel.removeObjectGlobal(item)
                        }
                    }
                    viewModel.setDraggingActive(false)
                    return true
                }
            }
            .padding(.horizontal, 46)
            .padding(.bottom, 6)
            .ignoresSafeArea(edges: .bottom)
            
            // Completion Overlay
            if viewModel.phase == .completed, let result = viewModel.chapterResult {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                ChapterCompleteView(
                    result: result,
                    onDismiss: { dismiss() },
                    onRestart: {
                        withAnimation(.easeInOut) {
                            viewModel.restart()
                        }
                    }
                )
                .padding(24)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .animation(.default, value: viewModel.phase)
        .environment(\.font, .custom("Virels-Regular", size: 14))
    }

    @ViewBuilder
    private func sceneView(for scene: GameScene) -> some View {
        SceneDropZoneView(
            scene: scene,
            isAnimating: viewModel.animatingSceneID == scene.id,
            isDraggingAnyItem: viewModel.isDraggingItem,
            onDrop: { object, slotID in
                viewModel.dropObject(object, intoSlot: slotID, intoScene: scene.id)
            },
            onRemoveObject: { object, slotID in
                viewModel.removeObject(object, fromSlot: slotID, fromScene: scene.id)
            },
            onDragStarted: {
                viewModel.setDraggingActive(true)
            },
            onDragEnded: {
                viewModel.setDraggingActive(false)
            }
        )
    }
}

struct GameplayView_Previews: PreviewProvider {
    static var previews: some View {
        GameplayView(chapter: StoryCatalog.allChapters[0])
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
