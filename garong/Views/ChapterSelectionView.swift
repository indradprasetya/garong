import SwiftUI

struct ChapterSelectionView: View {
    let title: String
    let subtitle: String
    let chapters: [Chapter]

    init(story: GameStory) {
        title = story.title
        subtitle = story.subtitle
        chapters = story.chapters
    }

    init(title: String, subtitle: String, chapters: [Chapter]) {
        self.title = title
        self.subtitle = subtitle
        self.chapters = chapters
    }

    var body: some View {
        ZStack {
            GarongTheme.pageBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(GarongTheme.ink)
                        Text(subtitle)
                            .font(.headline)
                            .foregroundStyle(GarongTheme.teal)
                    }

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 250), spacing: 18)],
                        spacing: 18
                    ) {
                        ForEach(chapters) { chapter in
                            chapterDestination(for: chapter)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Chapters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func chapterDestination(for chapter: Chapter) -> some View {
        if chapter.isUnlocked {
            NavigationLink {
                ChapterIntroView(chapter: chapter)
            } label: {
                ChapterCard(chapter: chapter)
            }
            .buttonStyle(.plain)
        } else {
            ChapterCard(chapter: chapter)
                .opacity(0.56)
                .accessibilityLabel("Chapter \(chapter.number), \(chapter.name), locked")
        }
    }
}

private struct ChapterCard: View {
    let chapter: Chapter

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text("LEVEL \(chapter.number)")
                    .font(.caption.weight(.heavy))
                    .tracking(1.2)
                    .foregroundStyle(GarongTheme.coral)
                Spacer()
                Image(systemName: chapter.isUnlocked ? "arrow.up.right" : "lock.fill")
                    .foregroundStyle(chapter.isUnlocked ? GarongTheme.teal : .secondary)
            }

            Text(chapter.name)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(GarongTheme.ink)

            Text(chapter.description)
                .font(.subheadline)
                .foregroundStyle(GarongTheme.ink.opacity(0.68))
                .lineLimit(3)

            Spacer(minLength: 4)

            HStack(spacing: 14) {
                Label("\(chapter.scenes.count) frames", systemImage: "rectangle.stack.fill")
                Label("\(chapter.objects.count) objects", systemImage: "shippingbox.fill")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(GarongTheme.teal)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.9))
                .shadow(color: GarongTheme.ink.opacity(0.09), radius: 14, y: 7)
        )
    }
}

struct ChapterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChapterSelectionView(story: StoryCatalog.gameStories[0])
        }
    }
}
