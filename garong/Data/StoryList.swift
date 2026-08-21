import Foundation

struct StoryList: Decodable {
    let schemaVersion: Int
    let stories: [StoryListStory]
}

struct StoryListStory: Decodable, Identifiable {
    let id: String
    let number: Int
    let name: LocalizedStoryText
    let chapters: [StoryChapterReference]
}

struct StoryChapterReference: Decodable, Identifiable {
    let id: String
    let number: Int
    let resource: String
}

enum StoryListLoader {
    enum Error: Swift.Error {
        case invalidManifest
    }

    static func decode(
        _ data: Data,
        resourceExists: (String) -> Bool
    ) throws -> [StoryListStory] {
        let manifest = try JSONDecoder().decode(StoryList.self, from: data)
        guard manifest.schemaVersion == 1 else { throw Error.invalidManifest }

        var storyIDs = Set<String>()
        var storyNumbers = Set<Int>()
        var chapterIDs = Set<String>()
        var resources = Set<String>()

        for story in manifest.stories {
            guard !story.id.isEmpty,
                  !story.name.en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !story.name.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  storyIDs.insert(story.id).inserted,
                  storyNumbers.insert(story.number).inserted else {
                throw Error.invalidManifest
            }

            var chapterNumbers = Set<Int>()
            for chapter in story.chapters {
                guard !chapter.id.isEmpty,
                      !chapter.resource.isEmpty,
                      chapterIDs.insert(chapter.id).inserted,
                      chapterNumbers.insert(chapter.number).inserted,
                      resources.insert(chapter.resource).inserted,
                      resourceExists(chapter.resource) else {
                    throw Error.invalidManifest
                }
            }
        }

        return manifest.stories
            .sorted { $0.number < $1.number }
            .map { story in
                StoryListStory(
                    id: story.id,
                    number: story.number,
                    name: story.name,
                    chapters: story.chapters.sorted { $0.number < $1.number }
                )
            }
    }

    static func load(bundle: Bundle = .main) throws -> [StoryListStory] {
        guard let url = bundle.url(forResource: "story-list", withExtension: "json") else {
            throw Error.invalidManifest
        }
        return try decode(Data(contentsOf: url)) { resource in
            bundle.url(forResource: resource, withExtension: "json") != nil
        }
    }
}
