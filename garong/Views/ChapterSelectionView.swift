import SwiftUI

struct ChapterSelectionView: View {
    let stories: [StoryListStory]
    @ObservedObject private var localization = AppLocalization.shared
    @ObservedObject private var textSizeManager = AppTextSizeManager.shared
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State private var progressByStoryID: [String: StoryProgressState] = [:]
    @State private var selectedStoryIndex = 0
    @State private var selectedChapter: Chapter?
    @State private var isLoadingGameplay = false
    @State private var showGameplay = false
    @State private var dragOffset: CGFloat = 0.0
    private let progressStore = StoryProgressStore()
    
    
    // MARK: - INIT
    
    init(story: StoryListStory) {
        self.stories = [story]
    }
    
    init(stories: [StoryListStory]) {
        self.stories = stories
    }
    
    private var currentStory: StoryListStory? {
        stories.indices.contains(selectedStoryIndex) ? stories[selectedStoryIndex] : nil
    }
    
    private var chapters: [StoryChapterReference] {
        currentStory?.chapters ?? []
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                Image(.storiesGreenGrid)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ForEach(Array(stories.enumerated()), id: \.element.id) { storyIndex, story in
                    storyPage(story, storyIndex: storyIndex, width: width, height: height)
                        .offset(
                            x: CGFloat(storyIndex - selectedStoryIndex) * width + dragOffset
                        )
                }

                if stories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 42))
                        Text("Story data could not be loaded")
                            .font(.appFont(size: 24))
                    }
                    .foregroundStyle(.black.opacity(0.75))
                }

                Button {
                    SoundManager.shared.play(.backTap)
                    dismiss()
                } label: {
                    Image("back_ribbon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: min(64, height * 0.15))
                }
                .buttonStyle(.plain)
                .position(x: width * 0.10, y: height * 0.07)
                .zIndex(5)

                if selectedStoryIndex > 0 {
                    storyArrow(direction: .previous, width: width)
                        .position(x: width * 0.10, y: height * 0.50)
                        .zIndex(6)
                }

                if selectedStoryIndex < stories.count - 1 {
                    storyArrow(direction: .next, width: width)
                        .position(x: width * 0.925, y: height * 0.50)
                        .zIndex(6)
                }

                if isLoadingGameplay {
                    LoadingView(chapter: selectedChapter, duration: 2.0) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isLoadingGameplay = false
                            showGameplay = selectedChapter != nil
                        }
                    }
                    .transition(.opacity)
                    .zIndex(20)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            loadProgress()
        }
        .navigationDestination(isPresented: $showGameplay) {
            if let selectedChapter {
                GameplayView(chapter: selectedChapter)
            }
        }
    }

    private var storySwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                let translation = value.translation.width
                let isDraggingPastEdge =
                    (translation < 0 && selectedStoryIndex == stories.count - 1) ||
                    (translation > 0 && selectedStoryIndex == 0)
                dragOffset = isDraggingPastEdge ? translation * 0.2 : translation
            }
            .onEnded { value in
                let translation = value.translation.width
                let threshold: CGFloat = 50
                if translation < -threshold && selectedStoryIndex < stories.count - 1 {
                    SoundManager.shared.play(.buttonTap)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedStoryIndex += 1
                    }
                } else if translation > threshold && selectedStoryIndex > 0 {
                    SoundManager.shared.play(.buttonTap)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedStoryIndex -= 1
                    }
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    dragOffset = 0
                }
            }
    }

    private func storyPage(
        _ story: StoryListStory,
        storyIndex: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        ZStack {
            clipboard(story: story, width: width, height: height)
                .contentShape(Rectangle())
                .gesture(storySwipeGesture)
                .position(x: width * 0.33, y: height * 0.535)

            VStack(spacing: 0) {
                ForEach(0..<min(story.chapters.count, 3), id: \.self) { chapterIndex in
                    chapterButton(
                        storyIndex: storyIndex,
                        chapterIndex: chapterIndex,
                        width: width,
                        height: height
                    )
                }
            }
            .frame(width: width * 0.31, height: height * 0.72)
            .position(x: width * 0.73, y: height * 0.54)
        }
        .frame(width: width, height: height)
    }

    private func clipboard(
        story: StoryListStory,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let boardWidth = min(width * 0.47, height * 1.18)
        let boardHeight = min(height * 0.87, boardWidth * 0.84)

        return Image(story.artworkAssetName)
            .resizable()
            .scaledToFit()
            .frame(width: boardWidth, height: boardHeight)
    }
    
    private func storyArrow(
        direction: ChapterPageDirection,
        width: CGFloat
    ) -> some View {
        Button {
            let destination = ChapterPageNavigation.destinationIndex(
                from: selectedStoryIndex,
                direction: direction,
                pageCount: stories.count
            )
            SoundManager.shared.play(.buttonTap)
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedStoryIndex = destination
            }
        } label: {
            Image(.chevronRight)
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.045)
                .rotationEffect(.degrees(direction == .previous ? 180 : 0))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(localization.text(
            direction == .previous ? "selection.previousPage" : "selection.nextPage"
        ))
    }
    
    
    // =========================================================
    // MARK: - CHAPTER BUTTON
    // =========================================================
    
    @ViewBuilder
    private func chapterButton(
        storyIndex: Int,
        chapterIndex: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let status = chapterStatus(storyIndex: storyIndex, chapterIndex: chapterIndex)
        
        switch status {
        case .completed(let stars):
            chapterNavigationLink(storyIndex: storyIndex, chapterIndex: chapterIndex, status: status, width: width, height: height)
                .accessibilityLabel(localization.text(
                    "selection.completed",
                    chapterDisplayName(storyIndex: storyIndex, chapterIndex: chapterIndex),
                    stars
                ))
            
        case .current:
            chapterNavigationLink(storyIndex: storyIndex, chapterIndex: chapterIndex, status: status, width: width, height: height)
                .accessibilityLabel(localization.text(
                    "selection.current",
                    chapterDisplayName(storyIndex: storyIndex, chapterIndex: chapterIndex)
                ))
            
        case .locked:
            chapterButtonLabel(storyIndex: storyIndex, chapterIndex: chapterIndex, status: status, width: width, height: height)
                .allowsHitTesting(false)
                .accessibilityLabel(localization.text(
                    "selection.locked",
                    chapterDisplayName(storyIndex: storyIndex, chapterIndex: chapterIndex)
                ))
        }
    }
    
    private func chapterNavigationLink(
        storyIndex: Int,
        chapterIndex: Int,
        status: ChapterProgressStatus,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Button {
            if storyIndex != selectedStoryIndex {
                SoundManager.shared.play(.buttonTap)
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedStoryIndex = storyIndex
                }
            } else {
                guard stories.indices.contains(storyIndex) else { return }
                let story = stories[storyIndex]
                guard story.chapters.indices.contains(chapterIndex) else { return }
                SoundManager.shared.play(.buttonTap)
                selectedChapter = StoryCatalog.chapter(
                    for: story.chapters[chapterIndex],
                    storyNumber: story.number,
                    language: localization.languageCode
                )
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoadingGameplay = selectedChapter != nil
                }
            }
        } label: {
            chapterButtonLabel(storyIndex: storyIndex, chapterIndex: chapterIndex, status: status, width: width, height: height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
    
    private func chapterButtonLabel(
        storyIndex: Int,
        chapterIndex: Int,
        status: ChapterProgressStatus,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        ZStack {
            chapterButtonBackground(status: status, width: width)

            HStack(spacing: width * 0.006) {
                chapterTitle(
                    storyIndex: storyIndex,
                    chapterIndex: chapterIndex,
                    width: width
                )

                if status == .current {
                    Image(.chevronButtonBlack)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.022)
                }
            }
            .frame(width: width * 0.245, height: height * 0.12)
            .offset(y: height * 0.035)
        }
        .frame(width: width * 0.30, height: height * 0.23)
    }
    
    @ViewBuilder
    private func chapterButtonBackground(
        status: ChapterProgressStatus,
        width: CGFloat
    ) -> some View {
        switch status {
        case .current:
            Image("chapter_box_current")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.28)

        case .completed(let stars):
            Image("chapter_box_completed_\(min(max(stars, 1), 3))")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.28)

        case .locked:
            Image("chapter_box_locked")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.28)
        }
    }
    
    
    // =========================================================
    // MARK: - CHAPTER TITLE
    // =========================================================
    
    private func chapterTitle(
        storyIndex: Int,
        chapterIndex: Int,
        width: CGFloat
    ) -> some View {
        Text(chapterDisplayName(storyIndex: storyIndex, chapterIndex: chapterIndex))
            .font(.appFont(size: max(17, min(24, width * 0.026))))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.48)
    }
    
    private func chapterDisplayName(storyIndex: Int, chapterIndex: Int) -> String {
        guard stories.indices.contains(storyIndex),
              stories[storyIndex].chapters.indices.contains(chapterIndex) else { return "" }
        return localization.localized(stories[storyIndex].chapters[chapterIndex].shortTitle)
    }
    
    
    // =========================================================
    // MARK: - STATUS LOGIC
    // =========================================================
    
    private func chapterStatus(
        storyIndex: Int,
        chapterIndex: Int
    ) -> ChapterProgressStatus {
        guard stories.indices.contains(storyIndex) else { return .locked }
        let story = stories[storyIndex]
        
        let previousStoriesComplete = stories.prefix(storyIndex)
            .flatMap(\.chapters)
            .allSatisfy { reference in
                progressByStoryID[reference.id]?.completion != nil
            }
        let completions = story.chapters.map {
            progressByStoryID[$0.id]?.completion
        }
        return ChapterProgressStatus.resolve(
            at: chapterIndex,
            completions: completions,
            previousStoriesComplete: previousStoriesComplete
        )
    }
    
    private func loadProgress() {
        progressByStoryID = stories.flatMap(\.chapters).reduce(into: [:]) { result, reference in
            guard let state = try? progressStore.state(for: reference.id) else { return }
            result[reference.id] = state
        }
    }
}


// =============================================================
// MARK: - PREVIEW
// =============================================================

struct ChapterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChapterSelectionView(
                stories: StoryCatalog.stories
            )
        }
    }
}
