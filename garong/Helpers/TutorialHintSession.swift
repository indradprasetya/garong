struct TutorialHintSession {
    private var hasShownPeekHint = false

    mutating func shouldShowPeekHint() -> Bool {
        guard !hasShownPeekHint else { return false }
        hasShownPeekHint = true
        return true
    }

    mutating func reset() {
        hasShownPeekHint = false
    }
}
