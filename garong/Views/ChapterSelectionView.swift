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
            let storyBackgroundWidth = min(width * 0.79, height * 1.72)
            let storyArrowOffset = storyBackgroundWidth / 2 + width * 0.015

            ZStack {

                // =====================================================
                // BACKGROUND
                // =====================================================

                Image("StoriesGreenGrid")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: width,
                        height: height
                    )
                    .clipped()
                    .ignoresSafeArea()


                // =====================================================
                // STORY ARTWORK + TITLE
                // =====================================================

                if let currentStory {
                    Image("story\(currentStory.number)_background")
                        .resizable()
                        .scaledToFit()
                        .frame(width: storyBackgroundWidth)
                        .position(
                            x: width * 0.50,
                            y: height * 0.49
                        )

                    ForEach(0..<min(chapters.count, 3), id: \.self) { index in
                        chapterButton(
                            index: index,
                            width: width,
                            height: height
                        )
                        .position(
                            x: width * 0.675,
                            y: height * (0.445 + CGFloat(index) * 0.14)
                        )
                    }
                }


                // =====================================================
                // BACK BUTTON
                // =====================================================

                Button {
                    dismiss()
                } label: {

                    Image("back_ribbon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 64)
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.075,
                    y: 20
                )


                // =====================================================
                // NEXT STORY ARROW
                // =====================================================

                if selectedStoryIndex > 0 {
                    storyArrow(direction: .previous, width: width)
                    .position(
                        x: width * 0.5 - storyArrowOffset,
                        y: height * 0.54
                    )
                }

                if selectedStoryIndex < stories.count - 1 {
                    storyArrow(direction: .next, width: width)
                        .position(
                            x: width * 0.5 + storyArrowOffset,
                            y: height * 0.54
                        )
                }

                if isLoadingGameplay {
                    LoadingView(duration: 2.0) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isLoadingGameplay = false
                            showGameplay = selectedChapter != nil
                        }
                    }
                    .transition(.opacity)
                    .zIndex(20)
                }
            }
            .frame(
                width: width,
                height: height
            )
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
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedStoryIndex = destination
            }
        } label: {
            Image("NextArrow")
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
        index: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let status = chapterStatus(index: index)

        switch status {
        case .completed(let stars):
            chapterNavigationLink(index: index, status: status, width: width, height: height)
                .accessibilityLabel(localization.text(
                    "selection.completed",
                    chapterDisplayName(index: index),
                    stars
                ))

        case .current:
            chapterNavigationLink(index: index, status: status, width: width, height: height)
                .accessibilityLabel(localization.text(
                    "selection.current",
                    chapterDisplayName(index: index)
                ))

        case .locked:
            chapterButtonLabel(index: index, status: status, width: width, height: height)
                .allowsHitTesting(false)
                .accessibilityLabel(localization.text(
                    "selection.locked",
                    chapterDisplayName(index: index)
                ))
        }
    }

    private func chapterNavigationLink(
        index: Int,
        status: ChapterProgressStatus,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Button {
            guard let story = currentStory, story.chapters.indices.contains(index) else { return }
            SoundManager.shared.play(.buttonTap)
            selectedChapter = StoryCatalog.chapter(
                for: story.chapters[index],
                storyNumber: story.number,
                language: localization.languageCode
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoadingGameplay = selectedChapter != nil
            }
        } label: {
            chapterButtonLabel(index: index, status: status, width: width, height: height)
        }
        .buttonStyle(.plain)
    }

    private func chapterButtonLabel(
        index: Int,
        status: ChapterProgressStatus,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        ZStack {
            chapterButtonBackground(status: status, width: width)

            HStack(spacing: width * 0.008) {
                chapterTitle(index: index, width: width)

                chapterAccessory(status: status, width: width)
                    .fixedSize()
            }
            .frame(maxWidth: width * 0.23)
        }
        .frame(width: width * 0.30, height: height * 0.18)
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
            Image(systemName: "chevron.right")
                .font(.system(size: max(16, width * 0.018), weight: .black))
                .foregroundStyle(.black)

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
        index: Int,
        width: CGFloat
    ) -> some View {
        Text(chapterDisplayName(index: index))
            .font(.appFont(size: max(20, width * 0.024)))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
    }

    private func chapterDisplayName(index: Int) -> String {
        localization.localized(chapters[index].shortTitle)
    }


    // =========================================================
    // MARK: - STATUS LOGIC
    // =========================================================

    private func chapterStatus(
        index: Int
    ) -> ChapterProgressStatus {
        let previousStoriesComplete = stories.prefix(selectedStoryIndex)
            .flatMap(\.chapters)
            .allSatisfy { reference in
                progressByStoryID[reference.id]?.completion != nil
            }
        let completions = currentStory?.chapters.map {
            progressByStoryID[$0.id]?.completion
        } ?? []
        return ChapterProgressStatus.resolve(
            at: index,
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
