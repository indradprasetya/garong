import Foundation

/// Presentation model for GARONG's story and chapter navigation.
struct GameStory: Identifiable, Equatable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let synopsis: String
    let symbol: String
    let chapters: [Chapter]
    let isUnlocked: Bool

    var progressText: String {
        AppLocalization.shared.text(
            "story.progress",
            chapters.filter(\.isUnlocked).count,
            chapters.count
        )
    }
}
