import Foundation

@main
struct TutorialHintSessionTests {
    static func main() {
        var session = TutorialHintSession()

        precondition(session.shouldShowPeekHint(), "The first wrong ending in a level session must reveal the hint")
        precondition(!session.shouldShowPeekHint(), "The hint must not repeat during the same level session")

        session.reset()
        precondition(session.shouldShowPeekHint(), "A restarted or newly loaded level must reveal the hint again")

        print("TutorialHintSessionTests passed")
    }
}
