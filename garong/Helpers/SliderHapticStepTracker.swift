struct SliderHapticStepTracker {
    let stepCount: Int
    private var lastStep: Int?

    init(stepCount: Int) {
        precondition(stepCount > 0)
        self.stepCount = stepCount
    }

    mutating func shouldTrigger(for value: Float) -> Bool {
        let step = Int(max(0, min(1, value)) * Float(stepCount))
        guard step != lastStep else { return false }

        lastStep = step
        return true
    }

    mutating func reset() {
        lastStep = nil
    }
}
