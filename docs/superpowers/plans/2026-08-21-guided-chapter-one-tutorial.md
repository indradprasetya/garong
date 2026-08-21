# Guided Chapter One Tutorial Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a one-time, interaction-locked tutorial to Story 1 Chapter 1 that teaches Approach, an intentional Toy mistake, Hint, dragging Toy back, the meter, and Crayon.

**Architecture:** A Foundation-only `ChapterTutorialSession` owns the finite-state workflow and its `UserDefaults` completion flag. `DragDropGameViewModel` delegates permission and transition decisions to that session, while the existing gameplay components render enabled, disabled, highlighted, and instructional states without duplicating gameplay logic.

**Tech Stack:** Swift 5, SwiftUI, Foundation `UserDefaults`, existing drag/drop engine, standalone `@main` precondition tests.

**Spec:** `docs/superpowers/specs/2026-08-21-guided-chapter-one-tutorial-design.md`

## Global Constraints

- The tutorial applies only to Story 1 Chapter 1 and runs until successfully completed once.
- Existing completed players skip the tutorial.
- Incomplete tutorial runs restart from a fresh chapter.
- Reset Progress clears the tutorial completion flag.
- No new dependencies and no duplicate gameplay screen.
- Back remains available; out-of-order gameplay actions are blocked.
- English and Indonesian copy are required.
- Reduce Motion removes repeated highlight movement.

---

### Task 1: Tutorial state machine and persistence

**Files:**
- Create: `garong/Helpers/ChapterTutorialSession.swift`
- Create: `Tests/ChapterTutorialSessionTests.swift`

**Interfaces:**
- Produces: `ChapterTutorialStep`, `ChapterTutorialSession`, `allowsTrayAction(_:)`, `allowsDrop(actionID:sceneIndex:)`, `allowsRemoval(_:)`, `didPlace(actionID:sceneIndex:)`, `didDismissHint()`, `didRemove(_:)`, `didAcknowledgeMeter()`, `didCompleteChapter()`, `resetForRestart()`, and `resetCompletion(defaults:)`.
- Consumes: `UserDefaults` only.

- [ ] **Step 1: Write the failing state and persistence test**

```swift
import Foundation

@main
struct ChapterTutorialSessionTests {
    static func main() {
        let suite = "ChapterTutorialSessionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        var session = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        precondition(session.step == .approach)
        precondition(session.allowsTrayAction("action_approach"))
        precondition(!session.allowsTrayAction("action_toy"))
        precondition(!session.allowsDrop(actionID: "action_toy", sceneIndex: 0))

        session.didPlace(actionID: "action_approach", sceneIndex: 0)
        precondition(session.step == .toy)
        session.didPlace(actionID: "action_toy", sceneIndex: 1)
        precondition(session.step == .wrongAndHint)
        session.didDismissHint()
        precondition(session.step == .returnToy)
        precondition(session.allowsRemoval("action_toy"))
        session.didRemove("action_toy")
        precondition(session.step == .meter)
        session.didAcknowledgeMeter()
        precondition(session.step == .crayon)
        session.didPlace(actionID: "action_crayon", sceneIndex: 1)
        precondition(session.step == .crayon)
        session.didCompleteChapter()
        precondition(session.step == .inactive)

        let completed = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        precondition(completed.step == .inactive)

        ChapterTutorialSession.resetCompletion(defaults: defaults)
        let reset = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        precondition(reset.step == .approach)

        let migrated = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 1,
            chapterAlreadyCompleted: true,
            defaults: defaults
        )
        precondition(migrated.step == .inactive)
        precondition(defaults.bool(forKey: ChapterTutorialSession.completionKey))

        let otherChapter = ChapterTutorialSession(
            storyNumber: 1,
            chapterNumber: 2,
            chapterAlreadyCompleted: false,
            defaults: defaults
        )
        precondition(otherChapter.step == .inactive)

        print("ChapterTutorialSessionTests passed")
    }
}
```

- [ ] **Step 2: Run the test and verify RED**

Run:

```bash
test_bin=$(mktemp /tmp/chapter-tutorial-red.XXXXXX)
xcrun swiftc -o "$test_bin" Tests/ChapterTutorialSessionTests.swift garong/Helpers/ChapterTutorialSession.swift
```

Expected: compilation fails because `ChapterTutorialSession.swift` does not exist yet.

- [ ] **Step 3: Implement the minimal state machine**

```swift
import Foundation

enum ChapterTutorialStep: Equatable {
    case inactive
    case approach
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
        case .wrongAndHint, .returnToy, .meter: false
        }
    }

    func allowsDrop(actionID: String, sceneIndex: Int) -> Bool {
        switch step {
        case .inactive: true
        case .approach: actionID == "action_approach" && sceneIndex == 0
        case .toy: actionID == "action_toy" && sceneIndex == 1
        case .crayon: actionID == "action_crayon" && sceneIndex == 1
        case .wrongAndHint, .returnToy, .meter: false
        }
    }

    func allowsRemoval(_ actionID: String) -> Bool {
        step == .inactive || (step == .returnToy && actionID == "action_toy")
    }

    mutating func didPlace(actionID: String, sceneIndex: Int) {
        guard allowsDrop(actionID: actionID, sceneIndex: sceneIndex) else { return }
        if step == .approach { step = .toy }
        else if step == .toy { step = .wrongAndHint }
    }

    mutating func didDismissHint() {
        guard step == .wrongAndHint else { return }
        step = .returnToy
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
        guard !defaults.bool(forKey: Self.completionKey), step != .inactive else { return }
        step = .approach
    }

    static func resetCompletion(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: completionKey)
    }
}
```

- [ ] **Step 4: Run the test and verify GREEN**

```bash
test_bin=$(mktemp /tmp/chapter-tutorial-green.XXXXXX)
xcrun swiftc -o "$test_bin" Tests/ChapterTutorialSessionTests.swift garong/Helpers/ChapterTutorialSession.swift
"$test_bin"
```

Expected: `ChapterTutorialSessionTests passed`.

- [ ] **Step 5: Commit**

```bash
git add garong/Helpers/ChapterTutorialSession.swift Tests/ChapterTutorialSessionTests.swift
git commit -m "feat(tutorial): add guided tutorial state"
```

---

### Task 2: Enforce tutorial actions in the gameplay view model

**Files:**
- Modify: `garong/ViewModels/DragDropGameViewModel.swift`
- Modify: `Tests/ChapterTutorialSessionTests.swift`

**Interfaces:**
- Consumes: every `ChapterTutorialSession` interface from Task 1 and existing `StoryProgressStore`, `DragDropGameEngine`, `GameObject`, and `GameScene` APIs.
- Produces: published `tutorialStep`; `canDrag(_:)`, `canDragPlacedObject(_:)`, `isTutorialItem(_:)`, `isTutorialTarget(_:)`, `didDismissTutorialHint()`, and `acknowledgeTutorialMeter()` for SwiftUI.

- [ ] **Step 1: Extend the policy test with restart and invalid-action assertions**

```swift
ChapterTutorialSession.resetCompletion(defaults: defaults)
session = ChapterTutorialSession(
    storyNumber: 1,
    chapterNumber: 1,
    chapterAlreadyCompleted: false,
    defaults: defaults
)
session.didPlace(actionID: "action_toy", sceneIndex: 0)
precondition(session.step == .approach, "Out-of-order actions must not advance tutorial")
session.didPlace(actionID: "action_approach", sceneIndex: 0)
session.resetForRestart()
precondition(session.step == .approach, "Restart must restart an incomplete tutorial")
```

- [ ] **Step 2: Run the focused test and verify it fails if restart behavior is absent or incorrect**

```bash
test_bin=$(mktemp /tmp/chapter-tutorial-policy.XXXXXX)
xcrun swiftc -o "$test_bin" Tests/ChapterTutorialSessionTests.swift garong/Helpers/ChapterTutorialSession.swift
"$test_bin"
```

Expected before completing Task 1 behavior: a precondition failure; after Task 1 it passes and locks the policy before integration.

- [ ] **Step 3: Initialize the session before engine state is published**

In `DragDropGameViewModel.init(chapter:)`, resolve the story group and saved completion first, then initialize the session. If it is active, call `engine.restart()` before copying `engine.scenes` into published properties:

```swift
let group = chapter.storyDefinition.flatMap { definition in
    StoryCatalog.stories.first { $0.chapters.contains { $0.id == definition.id } }
}
let resolvedStoryNumber = group?.number ?? 0
let completion = chapter.storyDefinition.flatMap {
    try? StoryProgressStore().state(for: $0.id).completion
}
var chapterTutorial = ChapterTutorialSession(
    storyNumber: resolvedStoryNumber,
    chapterNumber: chapter.number,
    chapterAlreadyCompleted: completion != nil
)
let engine = DragDropGameEngine(chapter: chapter)
if chapterTutorial.isActive {
    engine.restart()
}
```

Store `chapterTutorial` privately, expose `@Published private(set) var tutorialStep`, and use one helper to copy `chapterTutorial.step` after each transition.

- [ ] **Step 4: Gate tray dragging, scene drops, and placed-item removal**

Use the action asset ID already stored in `GameObject.symbol` and the real scene index:

```swift
func canDrag(_ object: GameObject) -> Bool {
    chapterTutorial.allowsTrayAction(object.symbol)
}

func canDragPlacedObject(_ object: GameObject) -> Bool {
    chapterTutorial.allowsRemoval(object.symbol)
}

func dropObject(_ object: GameObject, intoSlot slotID: String? = nil, intoScene sceneID: UUID) {
    guard let sceneIndex = engine.scenes.firstIndex(where: { $0.id == sceneID }),
          chapterTutorial.allowsDrop(actionID: object.symbol, sceneIndex: sceneIndex) else { return }
    let success = engine.placeObject(object, inSlot: slotID, inScene: sceneID)
    guard success else { return }
    chapterTutorial.didPlace(actionID: object.symbol, sceneIndex: sceneIndex)
    syncTutorialStep()
    // retain the existing sound, animation, and engine synchronization body
}
```

Apply the same `allowsRemoval` guard to both removal entry points. After a successful Toy removal, call `didRemove`, and after chapter completion call `didCompleteChapter`.

- [ ] **Step 5: Add explicit Hint and meter transitions**

```swift
func didDismissTutorialHint() {
    chapterTutorial.didDismissHint()
    syncTutorialStep()
}

func acknowledgeTutorialMeter() {
    chapterTutorial.didAcknowledgeMeter()
    syncTutorialStep()
}
```

On restart, call `chapterTutorial.resetForRestart()`. On `loadNextChapter`, replace the session with an inactive session for the destination chapter.

- [ ] **Step 6: Compile and run the policy test**

```bash
test_bin=$(mktemp /tmp/chapter-tutorial-view-model-policy.XXXXXX)
xcrun swiftc -o "$test_bin" Tests/ChapterTutorialSessionTests.swift garong/Helpers/ChapterTutorialSession.swift
"$test_bin"
```

Expected: `ChapterTutorialSessionTests passed`.

- [ ] **Step 7: Commit**

```bash
git add garong/ViewModels/DragDropGameViewModel.swift Tests/ChapterTutorialSessionTests.swift
git commit -m "feat(tutorial): enforce guided actions"
```

---

### Task 3: Render per-step highlights and instructions

**Files:**
- Create: `garong/Views/ChapterTutorialOverlayView.swift`
- Modify: `garong/Views/GameplayView.swift`
- Modify: `garong/Views/DraggableObjectView.swift`
- Modify: `garong/Views/SceneDropZoneView.swift`
- Modify: `garong/Resources/localization.json`

**Interfaces:**
- Consumes: `tutorialStep` and permission/highlight methods from Task 2.
- Produces: disabled and highlighted tray items, highlighted target scenes and placed Toy badge, a shared `tutorialHighlight(isActive:reduceMotion:)` modifier, a Hint callout, a meter spotlight, and a localized Continue action.

- [ ] **Step 1: Add localized tutorial copy**

Add these exact keys to `localization.json`:

```json
"tutorial.approach": { "en": "Start by approaching Rhodey.", "id": "Mulai dengan mendekati Rhodey." },
"tutorial.toy": { "en": "Now try giving Rhodey the toy.", "id": "Sekarang coba berikan mainan kepada Rhodey." },
"tutorial.wrongAndHint": { "en": "A choice can be wrong. Open Hint to learn what Rhodey needs.", "id": "Pilihanmu bisa kurang tepat. Buka Petunjuk untuk melihat kebutuhan Rhodey." },
"tutorial.returnToy": { "en": "Drag the toy back to the tray to try again.", "id": "Tarik kembali mainan ke tempat pilihan untuk mencoba lagi." },
"tutorial.meter": { "en": "This meter tracks your attempts. More attempts can reduce your stars.", "id": "Meter ini menghitung percobaanmu. Semakin banyak mencoba, bintangmu bisa berkurang." },
"tutorial.crayon": { "en": "Try the crayon now.", "id": "Sekarang coba gunakan krayon." },
"tutorial.continue": { "en": "Got it", "id": "Mengerti" }
```

- [ ] **Step 2: Make tray items conditionally draggable and highlighted**

Add `isEnabled` and `isHighlighted` parameters to `DraggableObjectView`. Render the same content in both states, attach `instantDraggable` only when enabled, dim disabled items to `0.35`, and apply the shared tutorial highlight only when highlighted.

```swift
let isEnabled: Bool
let isHighlighted: Bool

private var opacity: Double { isEnabled ? 1 : 0.35 }
```

Keep the preview working by defaulting both parameters to `true` and `false` respectively.

- [ ] **Step 3: Gate and highlight placed badges and scene targets**

Add these parameters to `SceneDropZoneView`:

```swift
var isTutorialTarget: Bool = false
var highlightedPlacedActionID: String? = nil
var canDragPlacedObject: (GameObject) -> Bool = { _ in true }
```

Pass `isDragEnabled` and `isHighlighted` into `CornerDropSlotBadge`. Disabled badges remain visible but do not attach `instantDraggable`. Add a rounded outline/glow to the target scene and highlighted Toy badge.

- [ ] **Step 4: Create the focused overlay**

`ChapterTutorialOverlayView` accepts `step`, localized text, Reduce Motion, and `onContinue`. Approach, Toy, Return Toy, and Crayon show a compact non-blocking callout. Wrong-and-Hint and Meter add a light scrim; only Meter displays the Continue button.

```swift
struct ChapterTutorialOverlayView: View {
    let step: ChapterTutorialStep
    let message: String
    let continueTitle: String
    let reduceMotion: Bool
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            if step == .wrongAndHint || step == .meter {
                Color.black.opacity(0.28).ignoresSafeArea().allowsHitTesting(false)
            }
            VStack {
                Spacer()
                Text(message)
                    .font(.appFont(size: 24))
                    .multilineTextAlignment(.center)
                    .padding(18)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                if step == .meter {
                    Button(continueTitle, action: onContinue)
                }
                Spacer().frame(height: 92)
            }
        }
    }
}
```

In the same file, expose `tutorialHighlight(isActive:reduceMotion:)`. It adds a high-contrast rounded outline and glow; when Reduce Motion is false it may use the existing gentle wiggle animation. Resolve `continueTitle` through `AppLocalization` in `GameplayView`.

- [ ] **Step 5: Wire GameplayView to the tutorial state**

- Pass `viewModel.canDrag(object)` and the current highlighted action into every tray item.
- Pass target-scene and placed-item gating into every `SceneDropZoneView`.
- During `.wrongAndHint`, leave Back and Hint interactive, highlight Hint, and call `viewModel.didDismissTutorialHint()` when the hint paper closes.
- During `.meter`, highlight the existing right-side meter and call `viewModel.acknowledgeTutorialMeter()` from Continue.
- Remove the old first-item-only arrows when the guided tutorial is active; retain the one-shot peek hint for ordinary gameplay.
- Apply `.accessibilityHint` to the highlighted item, target, Hint, Toy badge, and meter.

- [ ] **Step 6: Validate localization JSON and compile the state/UI boundary**

```bash
jq empty garong/Resources/localization.json
test_bin=$(mktemp /tmp/chapter-tutorial-ui-policy.XXXXXX)
xcrun swiftc -o "$test_bin" Tests/ChapterTutorialSessionTests.swift garong/Helpers/ChapterTutorialSession.swift
"$test_bin"
```

Expected: `jq` exits 0 and `ChapterTutorialSessionTests passed`.

- [ ] **Step 7: Commit**

```bash
git add garong/Views/ChapterTutorialOverlayView.swift garong/Views/GameplayView.swift garong/Views/DraggableObjectView.swift garong/Views/SceneDropZoneView.swift garong/Resources/localization.json
git commit -m "feat(tutorial): add guided highlights"
```

---

### Task 4: Reset integration and full verification

**Files:**
- Modify: `garong/Views/SettingView.swift`
- Modify: `Tests/ChapterTutorialSessionTests.swift`

**Interfaces:**
- Consumes: `ChapterTutorialSession.resetCompletion(defaults:)` from Task 1.
- Produces: Reset Progress resets both game progress and tutorial onboarding.

- [ ] **Step 1: Assert Reset Progress semantics in the focused test**

After completing a session, call `ChapterTutorialSession.resetCompletion(defaults:)`, create a new eligible session, and assert `.approach`. This assertion already exists in Task 1 and must remain in the final test.

- [ ] **Step 2: Clear tutorial completion from Settings**

```swift
Button(localization.text("settings.reset"), role: .destructive) {
    StoryProgressStore().resetAll()
    ChapterTutorialSession.resetCompletion()
    onResetProgress?()
    DispatchQueue.main.async {
        showResetSuccess = true
    }
}
```

- [ ] **Step 3: Run all locally runnable focused checks**

```bash
tutorial_test_bin=$(mktemp /tmp/chapter-tutorial-final.XXXXXX)
xcrun swiftc -o "$tutorial_test_bin" Tests/ChapterTutorialSessionTests.swift garong/Helpers/ChapterTutorialSession.swift
"$tutorial_test_bin"
progress_test_bin=$(mktemp /tmp/story-progress-final.XXXXXX)
xcrun swiftc -o "$progress_test_bin" Tests/StoryProgressStoreTests.swift garong/Core/StoryProgressStore.swift garong/Models/StoryProgress.swift
"$progress_test_bin"
jq empty garong/Resources/localization.json
git diff --check
```

Expected: both executables print `passed`, `jq` exits 0, and `git diff --check` prints nothing.

- [ ] **Step 4: Run the iOS build where full Xcode is available**

```bash
xcodebuild -project garong.xcodeproj -scheme garong -sdk iphonesimulator -configuration Debug build
```

Expected: `** BUILD SUCCEEDED **`. If the current machine only has Command Line Tools, record that limitation and do not claim a full application build.

- [ ] **Step 5: Commit**

```bash
git add garong/Views/SettingView.swift Tests/ChapterTutorialSessionTests.swift
git commit -m "fix(tutorial): reset onboarding with progress"
```
