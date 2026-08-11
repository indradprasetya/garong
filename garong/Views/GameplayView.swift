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
            // Background fill extending into edges
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Content container padded away from device hardware edges and notch
            VStack(spacing: 6) {
                // Top Bar
                HStack(spacing: 16) {
                    Text(viewModel.chapterName)
                        .font(.title3.bold())
                    
                    Spacer()
                    
                    Text(viewModel.progressText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(UIColor.secondarySystemGroupedBackground)))
                    
                    Spacer()
                    
                    // Explicit Finish Button to conclude chapter
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.finishChapter()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline.bold())
                            Text("Finish")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.green))
                        .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
                
                // Main 3 Scenes Area
                HStack(spacing: 14) {
                    ForEach(viewModel.scenes, id: \.id) { scene in
                        SceneDropZoneView(
                            scene: scene,
                            isAnimating: viewModel.animatingSceneID == scene.id,
                            onDrop: { object in
                                viewModel.dropObject(object, intoScene: scene.id)
                            },
                            onRemoveObject: { object in
                                viewModel.removeObject(object, fromScene: scene.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
                
                Divider()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                
                // Bottom Tray (CENTERED Draggable Objects)
                VStack(alignment: .center, spacing: 4) {
                    Text("DRAG ITEMS TO SCENES • TAP PLACED ITEM TO REMOVE")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        ForEach(viewModel.availableObjects, id: \.id) { object in
                            DraggableObjectView(object: object)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 88)
            }
            .padding(.horizontal, 44)
            .padding(.vertical, 10)
            
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
    }
}

struct GameplayView_Previews: PreviewProvider {
    static var previews: some View {
        GameplayView(chapter: SampleGameData.chapters[0])
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
