import Foundation

@main
enum Story3PoolTests {
    static func main() throws {
        let resourcesURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources")

        let chapter1 = try load("story3_chapter1", from: resourcesURL)
        precondition(chapter1.id == "jojo_afraid_to_swim")
        precondition(chapter1.gridCount == 4)
        precondition(chapter1.choiceCount == 3)
        precondition(chapter1.actions.map(\.name.en) == ["Ask", "Push", "Recall", "Swim"])
        let chapter1Runner = try StoryRunner(story: chapter1)
        precondition(chapter1Runner.outcome(for: [
            "action_asking",
            "action_recall",
            "action_swim"
        ])?.isIdeal == true)

        let chapter2 = try load("story3_chapter2", from: resourcesURL)
        precondition(chapter2.id == "rhodey_afraid_of_slide")
        precondition(chapter2.gridCount == 4)
        precondition(chapter2.choiceCount == 3)
        precondition(chapter2.actions.map(\.name.en) == ["Slide", "Push", "Example", "Ask"])
        let chapter2Runner = try StoryRunner(story: chapter2)
        precondition(chapter2Runner.outcome(for: [
            "action_asking",
            "action_example",
            "action_slide"
        ])?.isIdeal == true)

        let chapter3 = try load("story3_chapter3", from: resourcesURL)
        precondition(chapter3.id == "jojo_shares_floatie")
        precondition(chapter3.gridCount == 4)
        precondition(chapter3.choiceCount == 4)
        precondition(chapter3.actions.map(\.name.en) == ["Empathy", "Ask", "Lecture", "Comfort", "Explain"])
        precondition(chapter3.grids[0].dropSlots?.map(\.id) == ["slot_jojo", "slot_rhodey"])
        let chapter3Runner = try StoryRunner(story: chapter3)
        precondition(chapter3Runner.outcome(for: [
            "action_asking",
            "action_comfort",
            "action_explain",
            "action_empathy"
        ])?.isIdeal == true)

        print("Story3PoolTests passed")
    }

    private static func load(_ name: String, from resourcesURL: URL) throws -> StoryDefinition {
        let url = resourcesURL.appendingPathComponent("\(name).json")
        let story = try JSONDecoder().decode(StoryDefinition.self, from: Data(contentsOf: url))
        _ = try StoryRunner(story: story)
        return story
    }
}
