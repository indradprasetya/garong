//
//  GameplayView.swift
//  garong
//

import SwiftUI

/// Main gameplay screen — landscape layout with 3 scenes, centered object tray, and explicit Finish button.
struct GameplayView: View {
    @StateObject private var viewModel: DragDropGameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showHintOverlay: Bool = false
    @State private var isMeterWiggling: Bool = false
    
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
                    .padding(.top, -12)
                    
                    HStack {
                        
                        Spacer()
                        
                        Text(viewModel.chapterName)
                            .font(.appFont(size: 38))
                        
                        Button {
                            SoundManager.shared.play(.buttonTap)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                showHintOverlay = true
                            }
                        } label: {
                            if AssetFallbackHelper.hasAsset(named: "hint_icon") {
                                Image("hint_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 48)
                            } else {
                                Image(.hintIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 48)
                            }
                        }
                        
                        Spacer()
                        
                        // Next Chapter Chevron Button when finished, Meter when not finished
                        if let outcomeScene = viewModel.scenes.last {
                            let isReady = outcomeScene.isUnlocked
                            if isReady {
                                Button {
                                    SoundManager.shared.play(.buttonTap)
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        viewModel.goToNextChapterOrFinish()
                                    }
                                } label: {
                                    if AssetFallbackHelper.hasAsset(named: "next_button") {
                                        Image("next_button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 48)
                                    } else {
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
                                                .fill(Color.accentColor)
                                                .shadow(color: Color.accentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                                        )
                                    }
                                }
                            } else {
                                meterView
                            }
                        }
                    }
                    .padding(.top, 24)
                        
                    
                    
                }
                .ignoresSafeArea(edges: .top)
                
                
                
                Spacer()
                
                
                // Main Scenes Area - 2x2 LazyVGrid for 4 scenes (fitted to container), horizontal layout for others
                Group {
                    
                        HStack(spacing: 8) {
                            ForEach(viewModel.scenes, id: \.id) { scene in
                                sceneView(for: scene)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
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
            .padding(.leading, 46)
            .padding(.trailing, 12)
            .padding(.bottom, 24)
            .ignoresSafeArea(edges: .bottom)
            
            // Completion Overlay
            if viewModel.phase == .completed, let result = viewModel.chapterResult {
                ChapterResultView(
                    result: result,
                    onBack: {
                        dismiss()
                    },
                    onNext: {
                        if viewModel.hasNextChapter {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.loadNextChapter()
                            }
                        } else {
                            dismiss()
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(10)
            }
            
            // Paper Hint Overlay
            if showHintOverlay {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showHintOverlay = false
                        }
                    }
                
                hintPaperView
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .navigationBarHidden(true)
        .animation(.default, value: viewModel.phase)
        .environment(\.font, .custom("Virels-Regular", size: 14))
        .onChange(of: viewModel.wrongAttempts) { _ in
            if viewModel.wrongAttempts > 0 {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                    isMeterWiggling = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        isMeterWiggling = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var hintPaperView: some View {
        ZStack {
            if AssetFallbackHelper.hasAsset(named: "paper_hint") {
                Image("paper_hint")
                    .resizable()
                    .scaledToFit()
            } else {
                Image(.paperHint)
                    .resizable()
                    .scaledToFit()
            }
            
            VStack(spacing: 8) {
                Text("HINT")
                    .font(.appFont(size: 50))
                    .foregroundColor(.blue)
                
                if let hint = viewModel.hintText, !hint.isEmpty {
                    Text(hint)
                        .font(.appFont(size: 32))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 36)
                } else {
                    Text("Pay attention to how each action affects the characters' feelings.")
                        .font(.appFont(size: 18))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 36)
                }
            }
            .padding(.leading, 32)
            .padding(.trailing, 20)
            .padding(.vertical, 24)
        }
        .frame(maxWidth: 480, maxHeight: 320)
        .onTapGesture {
            // No-op to prevent taps on paper hint from dismissing overlay
        }
    }

    @ViewBuilder
    private var meterView: some View {
        let imageName = viewModel.meterImageName
        Group {
            if AssetFallbackHelper.hasAsset(named: imageName) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 52)
            } else {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
        }
        .rotationEffect(.degrees(isMeterWiggling ? 14 : 0))
        .scaleEffect(isMeterWiggling ? 1.18 : 1.0)
        .animation(.spring(response: 0.15, dampingFraction: 0.3), value: isMeterWiggling)
    }

    @ViewBuilder
    private func sceneView(for scene: GameScene) -> some View {
        SceneDropZoneView(
            scene: scene,
            isAnimating: viewModel.animatingSceneID == scene.id,
            isDraggingAnyItem: viewModel.isDraggingItem,
            onDrop: { object, slotID in
                viewModel.dropObject(object, intoSlot: slotID, intoScene: scene.id)
                viewModel.setDraggingActive(false)
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
