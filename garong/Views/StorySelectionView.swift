import SwiftUI

struct StorySelectionView: View {
    let stories: [GameStory]

    var body: some View {
        ZStack {
            GarongTheme.pageBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 300), spacing: 20)],
                        spacing: 20
                    ) {
                        ForEach(stories) { story in
                            storyDestination(for: story)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Stories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose a story")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(GarongTheme.ink)

            Text("Follow Mochi through connected moments. There are no right or wrong answers—watch what changes and choose what to try next.")
                .font(.body)
                .foregroundStyle(GarongTheme.ink.opacity(0.7))
                .frame(maxWidth: 720, alignment: .leading)
        }
    }

    @ViewBuilder
    private func storyDestination(for story: GameStory) -> some View {
        if story.isUnlocked {
            NavigationLink {
                ChapterSelectionView(story: story)
            } label: {
                StoryCard(story: story)
            }
            .buttonStyle(.plain)
        } else {
            StoryCard(story: story)
                .opacity(0.58)
                .accessibilityLabel("\(story.title), locked")
        }
    }
}

private struct StoryCard: View {
    let story: GameStory

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(GarongTheme.sun.opacity(0.3))
                    Image(systemName: story.symbol)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(GarongTheme.coral)
                }
                .frame(width: 72, height: 72)

                Spacer()

                if story.isUnlocked {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(GarongTheme.teal)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("STORY \(story.number)")
                    .font(.caption.weight(.bold))
                    .tracking(1.3)
                    .foregroundStyle(GarongTheme.teal)
                Text(story.title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(GarongTheme.ink)
                Text(story.subtitle)
                    .font(.headline)
                    .foregroundStyle(GarongTheme.coral)
            }

            Text(story.synopsis)
                .font(.subheadline)
                .foregroundStyle(GarongTheme.ink.opacity(0.72))
                .lineLimit(3)

            Text(story.progressText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(GarongTheme.ink.opacity(0.58))
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 290, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.9))
                .shadow(color: GarongTheme.ink.opacity(0.1), radius: 16, y: 8)
        )
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

struct StorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StorySelectionView(stories: SampleGameData.stories)
        }
    }
}
