import Foundation

enum ChapterTutorialStep: Equatable {
    case inactive
    case approach
    case narratorBox
    case toy
    case wrongAndHint
    case returnToy
    case meter
    case crayon
}

struct ChapterTutorialSession {
    static let completionKey = "hasCompletedChapter1Tutorial"

    private(set) var step: ChapterTutorialStep
    private let defaults: UserDefaults

    init(
        storyNumber: Int,
        chapterNumber: Int,
        chapterAlreadyCompleted: Bool,
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults
        let isEligible = storyNumber == 1 && chapterNumber == 1
        if isEligible && chapterAlreadyCompleted {
            defaults.set(true, forKey: Self.completionKey)
        }
        step = isEligible && !defaults.bool(forKey: Self.completionKey) ? .approach : .inactive
    }

    var isActive: Bool { step != .inactive }

    func allowsTrayAction(_ actionID: String) -> Bool {
        switch step {
        case .inactive: true
        case .approach: actionID == "action_approach"
        case .toy: actionID == "action_toy"
        case .crayon: actionID == "action_crayon"
        case .wrongAndHint, .returnToy, .meter, .narratorBox: false
        }
    }

    func allowsDrop(actionID: String, sceneIndex: Int) -> Bool {
        switch step {
        case .inactive: true
        case .approach: actionID == "action_approach" && sceneIndex == 0
        case .toy: actionID == "action_toy" && sceneIndex == 1
        case .crayon: actionID == "action_crayon" && sceneIndex == 1
        case .wrongAndHint, .returnToy, .meter, .narratorBox: false
        }
    }

    func allowsRemoval(_ actionID: String) -> Bool {
        step == .inactive || (step == .returnToy && actionID == "action_toy")
    }

    mutating func didPlace(actionID: String, sceneIndex: Int) {
        guard allowsDrop(actionID: actionID, sceneIndex: sceneIndex) else { return }
        if step == .approach {
            step = .narratorBox
        } else if step == .toy {
            step = .wrongAndHint
        }
    }

    mutating func didDismissHint() {
        guard step == .wrongAndHint else { return }
        step = .returnToy
    }

    mutating func didDismissNarratorBoxTutorial() {
        guard step == .narratorBox else { return }
        step = .toy
    }

    mutating func didRemove(_ actionID: String) {
        guard step == .returnToy, actionID == "action_toy" else { return }
        step = .meter
    }

    mutating func didAcknowledgeMeter() {
        guard step == .meter else { return }
        step = .crayon
    }

    mutating func didCompleteChapter() {
        guard step == .crayon else { return }
        defaults.set(true, forKey: Self.completionKey)
        step = .inactive
    }

    mutating func resetForRestart() {
        guard isActive, !defaults.bool(forKey: Self.completionKey) else { return }
        step = .approach
    }

    static func resetCompletion(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: completionKey)
    }
}
