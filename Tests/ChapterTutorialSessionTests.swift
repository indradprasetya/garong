import Foundation

@main
struct ChapterTutorialSessionTests {
    static func main() {
        let suiteName = "ChapterTutorialSessionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        var session = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        precondition(session.step == .approach, "A first-time Story 1 Chapter 1 run must start with Approach")
        precondition(session.allowsTrayAction("action_approach"))
        precondition(!session.allowsTrayAction("action_toy"), "Only the instructed action may be dragged")
        precondition(!session.allowsDrop(actionID: "action_toy", sceneIndex: 0))

        session.didPlace(actionID: "action_toy", sceneIndex: 0)
        precondition(session.step == .approach, "An out-of-order placement must not advance the tutorial")
        session.didPlace(actionID: "action_approach", sceneIndex: 0)
        precondition(session.step == .narratorBox, "Placing approach must advance to narratorBox")
        precondition(!session.allowsTrayAction("action_toy"), "narratorBox must block tray actions")
        precondition(!session.allowsDrop(actionID: "action_toy", sceneIndex: 1), "narratorBox must block drops")
        session.didDismissNarratorBoxTutorial()
        precondition(session.step == .toy, "Dismissing narrator box tutorial must advance to toy")
        session.didPlace(actionID: "action_toy", sceneIndex: 1)
        precondition(session.step == .wrongAndHint)
        session.didDismissHint()
        precondition(session.step == .returnToy)
        precondition(session.allowsRemoval("action_toy"))
        precondition(!session.allowsRemoval("action_approach"))
        session.didRemove("action_toy")
        precondition(session.step == .meter)
        session.didAcknowledgeMeter()
        precondition(session.step == .crayon)
        precondition(session.allowsDrop(actionID: "action_crayon", sceneIndex: 1))
        session.didPlace(actionID: "action_crayon", sceneIndex: 1)
        precondition(session.step == .crayon, "The tutorial is not complete until the chapter confirms success")
        session.didCompleteChapter()
        precondition(session.step == .inactive)

        let completedReplay = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        precondition(completedReplay.step == .inactive, "A completed tutorial must not repeat")

        ChapterTutorialSession.resetCompletion(defaults: defaults)
        var restarted = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        restarted.didPlace(actionID: "action_approach", sceneIndex: 0)
        restarted.resetForRestart()
        precondition(restarted.step == .approach, "Restart must restart an incomplete tutorial")

        let migrated = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: true,
            defaults: defaults
        )
        precondition(migrated.step == .inactive, "Existing completed players must skip the tutorial")
        precondition(defaults.bool(forKey: ChapterTutorialSession.completionKey))

        ChapterTutorialSession.resetCompletion(defaults: defaults)
        let otherChapter = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 2,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        precondition(otherChapter.step == .inactive, "The tutorial must be scoped to Story 1 Chapter 1")
        precondition(otherChapter.allowsTrayAction("any_action"))
        precondition(otherChapter.allowsDrop(actionID: "any_action", sceneIndex: 99))
        precondition(otherChapter.allowsRemoval("any_action"), "Inactive tutorials must not restrict normal gameplay")

        print("ChapterTutorialSessionTests passed")
    }
}
