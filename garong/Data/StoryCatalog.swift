//
//  StoryCatalog.swift
//  garong
//

import Foundation

struct StoryChapterItem: Identifiable {
    let id: String
    let storyNumber: Int
    let chapterNumber: Int
    let fileName: String
    let storyDefinition: StoryDefinition?
    let isUnlocked: Bool
    
    var title: String {
        storyDefinition.map { AppLocalization.shared.localized($0.title) }
            ?? AppLocalization.shared.text("story.chapterFallback", chapterNumber)
    }
    
    var description: String {
        storyDefinition.map { AppLocalization.shared.localized($0.description) } ?? ""
    }
}

enum StoryCatalog {
    static var stories: [StoryListStory] {
        do {
            return try StoryListLoader.load()
        } catch {
            debugPrint("StoryCatalog: \(error)")
            return []
        }
    }

    @MainActor
    static func chapters(
        for story: StoryListStory,
        language: String
    ) -> [Chapter] {
        let chapters = story.chapters.compactMap {
            chapter(for: $0, storyNumber: story.number, language: language)
        }
        return chapters.count == story.chapters.count ? chapters : []
    }

    @MainActor
    static func chapter(
        for reference: StoryChapterReference,
        storyNumber: Int,
        language: String
    ) -> Chapter? {
        guard let definition = try? StoryLoader.load(named: reference.resource),
              definition.id == reference.id else { return nil }
        return Chapter(
            storyItem: StoryChapterItem(
                id: reference.id,
                storyNumber: storyNumber,
                chapterNumber: reference.number,
                fileName: reference.resource,
                storyDefinition: definition,
                isUnlocked: true
            ),
            language: language
        )
    }

    @MainActor static var allChapters: [Chapter] {
        stories.flatMap { chapters(for: $0, language: AppLocalization.shared.languageCode) }
    }
}
