//
//  GameplayView.swift
//  garong
//

import SwiftUI

/// Main gameplay screen — landscape layout with 3 scenes, centered object tray, and explicit Finish button.
struct GameplayView: View {
    @StateObject private var viewModel: DragDropGameViewModel
    @ObservedObject private var localization = AppLocalization.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showHintOverlay: Bool = false
    @State private var showResultOverlay: Bool = false
    @State private var isMeterWiggling: Bool = false
    @State private var showCenterMeter: Bool = false
    
    init(chapter: Chapter) {
        _viewModel = StateObject(wrappedValue: DragDropGameViewModel(chapter: chapter))
    }
    
    init(viewModel: DragDropGameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                                .frame(height: 64)
                        } else {
                            Image(systemName: "arrowshape.backward.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, -12)
                    .disabled(viewModel.isGuidedTutorialActive)
                    
                    HStack {
                        
                        Spacer()
                        
                        Text(viewModel.chapterName)
                            .font(.appFont(size: 38))
                        
                        Button {
                            guard viewModel.canUseHint else { return }
                            SoundManager.shared.play(.buttonTap)
                            viewModel.dismissPeekHint()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                showHintOverlay = true
                            }
                        } label: {
                            hintIconView
                        }
                        .disabled(!viewModel.canUseHint)
                        .opacity(viewModel.canUseHint ? 1 : 0.35)
                        .tutorialTarget(viewModel.tutorialStep == .wrongAndHint)
                        .accessibilityHint(
                            viewModel.tutorialStep == .wrongAndHint
                                ? localization.text("tutorial.wrongAndHint")
                                : ""
                        )
                        .overlay(alignment: .leading) {
                            if viewModel.showPeekHint {
                                peekHintView
                                    .fixedSize()
                                    .tutorialWiggle()
                                    .offset(x: 28, y: 16)
                                    .allowsHitTesting(false)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Spacer()
                        
                        if viewModel.phase == .completed && !showResultOverlay {
                            Button {
                                SoundManager.shared.play(.buttonTap)
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    showResultOverlay = true
                                }
                            } label: {
                                if AssetFallbackHelper.hasAsset(named: "next_button") {
                                    Image("next_button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 52)
                                } else {
                                    HStack(spacing: 6) {
                                        Text("Next")
                                            .font(.appFont(size: 28))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.green))
                                }
                            }
                            .buttonStyle(.plain)
                            .phaseAnimator(
                                reduceMotion ? [CGFloat.zero] : [0, 0, 0, 1, 0]
                            ) { content, phase in
                                content
                                    .offset(x: phase * 5)
                                    .scaleEffect(phase == 1 ? 1.02 : 1)
                            } animation: { _ in
                                .easeInOut(duration: 0.5)
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            meterView
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard viewModel.tutorialStep == .meter else { return }
                                    SoundManager.shared.play(.buttonTap)
                                    viewModel.acknowledgeTutorialMeter()
                                }
                                .tutorialTarget(viewModel.tutorialStep == .meter)
                                .accessibilityHint(
                                    viewModel.tutorialStep == .meter
                                        ? localization.text("tutorial.meter")
                                        : ""
                                )
                        }
                    }
                    .padding(.top, 24)
                        
                    
                    
                }
                .ignoresSafeArea(edges: .top)
                
                
                
                Spacer()
                
                
                // Main Scenes Area - 2x2 LazyVGrid for 4 scenes (fitted to container), horizontal layout for others
                Group {
                    
                        HStack(spacing: 8) {
                            ForEach(Array(viewModel.scenes.enumerated()), id: \.element.id) { index, scene in
                                sceneView(for: scene, at: index)
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
                            DraggableObjectView(
                                object: object,
                                isEnabled: viewModel.canDrag(object),
                                isHighlighted: viewModel.isTutorialItem(object),
                                onDragStarted: { viewModel.setDraggingActive(true) }
                            )
                            .accessibilityHint(
                                viewModel.isTutorialItem(object) ? tutorialMessage : ""
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 80)
                .accessibilityHint(
                    viewModel.tutorialStep == .returnToy ? tutorialMessage : ""
                )
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
            if viewModel.phase == .completed && showResultOverlay, let result = viewModel.chapterResult {
                ChapterResultView(
                    result: result,
                    onBack: {
                        dismiss()
                    },
                    onNext: {
                        showResultOverlay = false
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

            if viewModel.phase == .needsBreak, let result = viewModel.chapterResult {
                ChapterResultView(
                    result: result,
                    onBack: {
                        viewModel.restart(playSound: false)
                        dismiss()
                    },
                    onTryAgain: {
                        showResultOverlay = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            viewModel.restart()
                        }
                    },
                    statusMessage: viewModel.placementLimitMessage
                )
                    .transition(.opacity)
                    .zIndex(10)
            }
            
            // Center Mistake Feedback Meter Overlay
            if showCenterMeter && viewModel.phase == .playing {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    meterView
                        .scaleEffect(4.2)
                        .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                }
                .zIndex(9)
                .allowsHitTesting(false)
            }

            // Paper Hint Overlay
            if showHintOverlay {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showHintOverlay = false
                        }
                        viewModel.didDismissTutorialHint()
                    }
                    .zIndex(8)
                
                hintPaperView
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                    .zIndex(9)
            }
        }
        .overlayPreferenceValue(TutorialTargetPreferenceKey.self) { targets in
            GeometryReader { proxy in
                if viewModel.isGuidedTutorialActive && !showHintOverlay {
                    ChapterTutorialOverlayView(
                        step: viewModel.tutorialStep,
                        message: tutorialMessage,
                        targetRects: targets.map { proxy[$0] }
                    ) { target in
                        liftedTutorialTarget(in: target)
                    }
                    .transition(.opacity)
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.default, value: viewModel.phase)
        .animation(.easeInOut(duration: 0.2), value: viewModel.tutorialStep)
        .environment(\.font, .custom("Virels-Regular", size: 14))
        .onAppear {
            BackgroundMusicManager.shared.play(.gameplay)
        }
        .onDisappear {
            BackgroundMusicManager.shared.play(.menu)
        }
        .onChange(of: viewModel.phase) { newPhase in
            if newPhase == .playing {
                showResultOverlay = false
            } else {
                showCenterMeter = false
            }
        }
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
        .onChange(of: viewModel.currentStars) { newStars in
            if newStars < 3 {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                    showCenterMeter = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCenterMeter = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var peekHintView: some View {
        if AssetFallbackHelper.hasAsset(named: "peek_hint") {
            Image("peek_hint")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 70)
        } else {
            HStack(spacing: 4) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("peek a hint")
                    .font(.appFont(size: 16))
                    .foregroundColor(.orange)
            }
        }
    }

    @ViewBuilder
    private var hintIconView: some View {
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
                Text(localization.text("gameplay.hint"))
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
                    Text(localization.text("gameplay.hintFallback"))
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
        .accessibilityLabel(viewModel.placementStateLabel)
    }

    private var tutorialMessage: String {
        let key = switch viewModel.tutorialStep {
        case .approach: "tutorial.approach"
        case .toy: "tutorial.toy"
        case .wrongAndHint: "tutorial.wrongAndHint"
        case .returnToy: "tutorial.returnToy"
        case .meter: "tutorial.meter"
        case .crayon: "tutorial.crayon"
        case .inactive: ""
        }
        return key.isEmpty ? "" : localization.text(key)
    }

    @ViewBuilder
    private func liftedTutorialTarget(in target: CGRect) -> some View {
        switch viewModel.tutorialStep {
        case .approach, .toy, .crayon:
            if let object = tutorialActionObject {
                DraggableObjectView(object: object)
            }
        case .wrongAndHint:
            hintIconView
        case .returnToy:
            if let placement = tutorialToyPlacement {
                CornerDropSlotBadge(
                    slot: placement.slot,
                    placedObject: placement.object,
                    badgeSize: min(target.width, target.height),
                    isDropEnabled: false,
                    onDrop: { _ in },
                    onRemove: { _ in }
                )
            }
        case .meter:
            meterView
        case .inactive:
            EmptyView()
        }
    }

    private var tutorialActionObject: GameObject? {
        let symbol = switch viewModel.tutorialStep {
        case .approach: "action_approach"
        case .toy: "action_toy"
        case .crayon: "action_crayon"
        default: ""
        }
        return viewModel.availableObjects.first { $0.symbol == symbol }
    }

    private var tutorialToyPlacement: (slot: GameDropSlot, object: GameObject)? {
        viewModel.scenes
            .flatMap(\.dropSlots)
            .first { $0.currentObject?.symbol == "action_toy" }
            .flatMap { slot in slot.currentObject.map { (slot, $0) } }
    }

    @ViewBuilder
    private func sceneView(for scene: GameScene, at index: Int) -> some View {
        SceneDropZoneView(
            scene: scene,
            isAnimating: viewModel.animatingSceneID == scene.id,
            isDraggingAnyItem: viewModel.isDraggingItem,
            celebratesWin: viewModel.phase == .completed,
            celebrationDelay: WinCelebrationSequence.delay(
                for: index,
                totalCount: viewModel.scenes.count
            ),
            isTutorialTarget: viewModel.isTutorialTarget(scene),
            highlightedPlacedActionID: viewModel.tutorialStep == .returnToy ? "action_toy" : nil,
            tutorialAccessibilityHint: tutorialMessage,
            isDropEnabled: !viewModel.isGuidedTutorialActive || viewModel.isTutorialTarget(scene),
            canDragPlacedObject: viewModel.canDragPlacedObject,
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

private struct TutorialWiggleModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.phaseAnimator(reduceMotion ? [CGFloat.zero] : [-1, 1]) { view, phase in
            view
                .rotationEffect(.degrees(phase * 3))
                .offset(y: phase * 2)
        } animation: { _ in
            .easeInOut(duration: 0.45)
        }
    }
}

private extension View {
    func tutorialWiggle() -> some View {
        modifier(TutorialWiggleModifier())
    }
}
