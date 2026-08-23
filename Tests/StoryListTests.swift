import Foundation

@main
enum StoryListTests {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            fatalError("Pass the story-list.json path")
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
        let resources = Set([
            "story1_chapter1", "story1_chapter2", "story1_chapter3",
            "story2_chapter1", "story2_chapter2", "story2_chapter3"
        ])
        let stories = try StoryListLoader.decode(data) { resources.contains($0) }

        precondition(stories.map(\.id) == ["school", "playground"])
        precondition(stories.map(\.artworkAssetName) == ["story1_img", "story2_img"])
        precondition(stories.map { $0.name.localized(language: "id") } == ["Sekolah", "Taman Bermain"])
        precondition(stories[0].chapters.map { $0.shortTitle.localized(language: "en") } == ["Let's Draw!", "Too Loud to Draw", "My Drawing Tore"])
        precondition(stories[0].chapters.map(\.resource) == ["story1_chapter1", "story1_chapter2", "story1_chapter3"])
        precondition(stories[1].chapters.map(\.id) == ["validate_jojo_feelings", "share_the_slide", "listen_before_helping_rhodey"])
        precondition(stories[0].chapters[1].id == "jojo_settles_down_to_draw")

        try expectFailure(data, resources: resources) { root in
            root["schemaVersion"] = 2
        }
        try expectFailure(data, resources: resources) { root in
            var stories = root["stories"] as! [[String: Any]]
            stories[1]["id"] = stories[0]["id"]
            root["stories"] = stories
        }
        try expectFailure(data, resources: resources) { root in
            var stories = root["stories"] as! [[String: Any]]
            stories[1]["number"] = stories[0]["number"]
            root["stories"] = stories
        }
        try expectFailure(data, resources: resources) { root in
            var stories = root["stories"] as! [[String: Any]]
            var secondChapters = stories[1]["chapters"] as! [[String: Any]]
            let firstChapters = stories[0]["chapters"] as! [[String: Any]]
            secondChapters[0]["id"] = firstChapters[0]["id"]
            stories[1]["chapters"] = secondChapters
            root["stories"] = stories
        }
        try expectFailure(data, resources: resources) { root in
            var stories = root["stories"] as! [[String: Any]]
            var chapters = stories[0]["chapters"] as! [[String: Any]]
            chapters[1]["number"] = chapters[0]["number"]
            stories[0]["chapters"] = chapters
            root["stories"] = stories
        }
        try expectFailure(data, resources: resources) { root in
            var stories = root["stories"] as! [[String: Any]]
            stories[0]["name"] = ["en": "", "id": "Sekolah"]
            root["stories"] = stories
        }
        try expectFailure(data, resources: resources) { root in
            var stories = root["stories"] as! [[String: Any]]
            var chapters = stories[0]["chapters"] as! [[String: Any]]
            chapters[0]["shortTitle"] = ["en": "", "id": "Ayo Menggambar!"]
            stories[0]["chapters"] = chapters
            root["stories"] = stories
        }
        try expectFailure(data, resources: resources) { root in
            var stories = root["stories"] as! [[String: Any]]
            var chapters = stories[0]["chapters"] as! [[String: Any]]
            chapters[0]["resource"] = "missing_chapter"
            stories[0]["chapters"] = chapters
            root["stories"] = stories
        }

        print("story list tests passed")
    }

    private static func expectFailure(
        _ data: Data,
        resources: Set<String>,
        mutate: (inout [String: Any]) -> Void
    ) throws {
        var root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        mutate(&root)
        let mutatedData = try JSONSerialization.data(withJSONObject: root)

        do {
            _ = try StoryListLoader.decode(mutatedData) { resources.contains($0) }
            preconditionFailure("Invalid story list was accepted")
        } catch {
            return
        }
    }
}
