import Foundation

@main
struct CompletedMessageTests {
    static func main() throws {
        let resourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources/story1_chapter1.json")
        let story = try JSONDecoder().decode(StoryDefinition.self, from: Data(contentsOf: resourceURL))

        precondition(story.completedMessage(for: 1, language: "en") == "Rhodey feels better.")
        precondition(story.completedMessage(for: 2, language: "id") == "Rhodey senang.")
        precondition(story.completedMessage(for: 3, language: "en") == "Rhodey is satisfied.")
        precondition(story.completedMessage(for: 0, language: "en") == nil)

        print("CompletedMessageTests passed")
    }
}
