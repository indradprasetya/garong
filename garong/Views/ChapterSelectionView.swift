import SwiftUI

struct ChapterSelectionView: View {
    let stories: [StoryListStory]
    @ObservedObject private var localization = AppLocalization.shared
    
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
        ZStack {
            Image(.storiesGreenGrid)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ZStack {
                VStack {
                    HStack {
                        Button {
                            SoundManager.shared.play(.backTap)
                            dismiss()
                        } label: {
                            Image("back_ribbon")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 64)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.leading, 46)
                    
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let storyPaperWidth = min(width * 0.82, height * 2)
                        let storyPaperHeight = storyPaperWidth / 1.77
                        let cardSpacing = storyPaperWidth + width * 0.15
                        let paperCenterY = height * 0.48

                        ZStack {
                            // Story Cards Layer
                            ZStack {
                                ForEach(Array(stories.enumerated()), id: \.element.id) { storyIndex, story in
                                    let offsetIndex = CGFloat(storyIndex - selectedStoryIndex)
                                    let cardX = width * 0.50 + offsetIndex * cardSpacing + dragOffset
                                    
                                    if abs(offsetIndex * cardSpacing + dragOffset) < width * 1.5 {
                                        ZStack {
                                            // 1. Paper Background Image
                                            Image("paper_background")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: storyPaperWidth, height: storyPaperHeight)
                                            
                                            // 2. Paper Content Layout (Left & Right Pages)
                                            HStack(spacing: 0) {
                                                // Left Page: Artwork
                                                VStack {
                                                    Image(story.artworkAssetName)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(
                                                            width: storyPaperWidth * 0.40,
                                                            height: storyPaperHeight * 0.75
                                                        )
                                                }
                                                .frame(width: storyPaperWidth * 0.46, height: storyPaperHeight)
                                                
                                                // Right Page: Title + Chapter Buttons
                                                VStack(spacing: storyPaperHeight * 0.02) {
                                                    Text(localization.localized(story.name).uppercased())
                                                        .font(.appFont(size: max(24, storyPaperWidth * 0.048)))
                                                        .bold()
                                                        .foregroundStyle(.black)
                                                        .multilineTextAlignment(.center)
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.65)
                                                        .frame(width: storyPaperWidth * 0.38)
                                                    
                                                    VStack(spacing: storyPaperHeight * 0.015) {
                                                        ForEach(0..<min(story.chapters.count, 3), id: \.self) { chapterIndex in
                                                            chapterButton(
                                                                storyIndex: storyIndex,
                                                                chapterIndex: chapterIndex,
                                                                width: width,
                                                                height: height,
                                                                cardX: cardX,
                                                                storyPaperWidth: storyPaperWidth
                                                            )
                                                        }
                                                    }
                                                }
                                                .frame(width: storyPaperWidth * 0.46, height: storyPaperHeight)
                                            }
                                            .frame(width: storyPaperWidth, height: storyPaperHeight)
                                        }
                                        .position(
                                            x: cardX,
                                            y: paperCenterY
                                        )
                                    }
                                }
                            }
                            .frame(width: width, height: height)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                    .onChanged { value in
                                        let translation = value.translation.width
                                        if (translation < 0 && selectedStoryIndex == stories.count - 1) ||
                                            (translation > 0 && selectedStoryIndex == 0) {
                                            dragOffset = translation * 0.2
                                        } else {
                                            dragOffset = translation
                                        }
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
                            )
                            .zIndex(1)

                            // Navigation Arrows Layer (Symmetrical Overlay)
                            HStack {
                                if selectedStoryIndex > 0 {
                                    storyArrow(direction: .previous, width: width)
                                } else {
                                    Spacer().frame(width: width * 0.070)
                                }
                                
                                Spacer()
                                
                                if selectedStoryIndex < stories.count - 1 {
                                    storyArrow(direction: .next, width: width)
                                } else {
                                    Spacer().frame(width: width * 0.070)
                                }
                            }
                            .padding(.horizontal, 28)
                            .position(x: width * 0.50, y: paperCenterY)
                            .zIndex(2)
                        }
                    }
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
            Image("chevron_right")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.070)
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
        height: CGFloat,
        cardX: CGFloat,
        storyPaperWidth: CGFloat
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
        }
        .buttonStyle(.plain)
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
            
            HStack(spacing: width * 0.008) {
                chapterTitle(storyIndex: storyIndex, chapterIndex: chapterIndex, width: width)
                
                chapterAccessory(status: status, width: width)
                    
            }
            .frame(maxWidth: width * 0.23)
        }
        .frame(width: width * 0.30, height: height * 0.2)
        .opacity(status == .locked ? 0.35 : 1)
    }
    
    @ViewBuilder
    private func chapterButtonBackground(
        status: ChapterProgressStatus,
        width: CGFloat
    ) -> some View {
        switch status {
        case .current:
            Image("chapter_button_yellow")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.27)
            
        case .completed, .locked:
            Image("chapter_button_white")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.27)
        }
    }
    
    @ViewBuilder
    private func chapterAccessory(
        status: ChapterProgressStatus,
        width: CGFloat
    ) -> some View {
        switch status {
        case .completed(let stars):
            starRating(stars, width: width)
                .accessibilityHidden(true)
            
        case .current:
            Image(.chevronButtonBlack)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .padding(.bottom, 8)
            
            
        case .locked:
            EmptyView()
        }
    }
    
    private func starRating(_ stars: Int, width: CGFloat) -> some View {
        let count = min(max(stars, 1), 3)
        
        return VStack(spacing: -width * 0.004) {
            if count == 1 || count == 3 {
                starIcon(width: width)
            }
            
            if count >= 2 {
                HStack(spacing: width * 0.002) {
                    ForEach(0..<2, id: \.self) { _ in
                        starIcon(width: width)
                    }
                }
            }
        }
        .frame(width: width * 0.04, height: width * 0.034)
    }
    
    private func starIcon(width: CGFloat) -> some View {
        Image("StarIcon")
            .resizable()
            .scaledToFit()
            .frame(width: width * 0.016, height: width * 0.016)
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
            .font(.appFont(size: max(20, width * 0.024)))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
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
