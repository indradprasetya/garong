struct TutorialHintSession {
    private var hasShownPeekHint = false

    static func showsOnboarding(storyNumber: Int, chapterNumber: Int) -> Bool {
        storyNumber == 1 && chapterNumber == 1
    }

    mutating func shouldShowPeekHint() -> Bool {
        guard !hasShownPeekHint else { return false }
        hasShownPeekHint = true
        return true
    }

    mutating func reset() {
        hasShownPeekHint = false
    }
}
