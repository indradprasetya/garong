# Guided Chapter One Tutorial Design

## Goal

Teach the core gameplay through real interactions on Story 1 Chapter 1. The tutorial runs only until the player successfully completes it once. Later plays use normal unrestricted gameplay.

## Chosen approach

Keep the existing `GameplayView` and game engine. Add a small tutorial state machine plus a dedicated overlay view that highlights the currently required control. This keeps tutorial actions real: placements, wrong outcomes, hints, item removal, meter updates, progress, sound, and haptics continue through the production gameplay path.

A separate duplicate gameplay screen is rejected because it would duplicate drag/drop and completion behavior. Passive hints alone are rejected because they cannot enforce the requested action order.

## Eligibility and persistence

- The guided tutorial applies only to Story 1 Chapter 1.
- Store one Boolean completion flag in `UserDefaults`.
- Mark the flag only when the chapter reaches successful completion after the guided steps.
- If the player exits before completion, the tutorial starts again from the beginning next time.
- While the completion flag is false, opening Story 1 Chapter 1 starts fresh instead of restoring a partial tutorial run.
- If Story 1 Chapter 1 was already completed before this feature is installed, treat the tutorial as completed so an existing player is not forced through onboarding during a replay.
- Reset Progress also clears the tutorial completion flag.

## Tutorial states and transitions

1. **Approach**
   - Highlight Approach and the first available scene.
   - Only Approach is draggable; other tray items and unrelated controls are disabled.
   - A valid Approach placement advances to Toy.

2. **Toy**
   - Highlight Toy and the newly unlocked second scene.
   - Only Toy is draggable.
   - A valid Toy placement intentionally produces a wrong outcome and advances to Wrong Explanation.

3. **Wrong Explanation and Hint**
   - Explain that a choice can be wrong and point to the existing Hint button.
   - Only the Hint button and tutorial-required dismissal controls remain interactive.
   - The player opens and closes the existing hint paper, then advances to Return Toy.

4. **Return Toy**
   - Highlight the Toy badge in the scene and the bottom tray.
   - Only the placed Toy can be dragged; dropping it back onto the tray removes it through the existing removal path.
   - Successful removal advances to Meter Explanation.

5. **Meter Explanation**
   - Spotlight the meter on the right and explain that extra attempts can reduce the earned stars.
   - A localized Continue button advances to Crayon.

6. **Crayon**
   - Highlight Crayon and the now-empty second scene.
   - Only Crayon is draggable.
   - A valid placement completes the chapter normally and persists tutorial completion.

## Interaction rules

- Disabled items remain visible but dimmed so the player can understand the available choices.
- Drops that do not match the current tutorial state are rejected without changing progress.
- Back remains available; leaving does not mark the tutorial complete.
- Tutorial overlays must not create replacement gameplay state or directly mutate scenes.
- Existing sound and haptic behavior remains active for every accepted interaction.
- With Reduce Motion enabled, highlights use opacity/outline without repeated movement.

## Localization and accessibility

- Add Indonesian and English strings to the existing localization catalog.
- Each highlighted control receives a concise accessibility hint describing the required action.
- Disabled controls expose their disabled state to assistive technology.
- Tutorial dialogs retain readable contrast and do not rely on color alone.

## Verification

- A focused state-machine test covers every valid transition and rejects out-of-order actions.
- Persistence tests cover first run, incomplete exit, successful completion, existing completed players, and Reset Progress.
- A gameplay integration check verifies that direct normal play remains unrestricted after tutorial completion.
