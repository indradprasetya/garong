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
        storyDefinition?.shortTitle.en ?? "Chapter \(chapterNumber)"
    }
    
    var titleID: String {
        storyDefinition?.shortTitle.id ?? "Bab \(chapterNumber)"
    }
    
    var description: String {
        storyDefinition?.description.en ?? ""
    }
}

struct StoryGroup: Identifiable {
    let id: Int
    let title: String
    let description: String
    let chapters: [StoryChapterItem]
}

enum StoryCatalog {
    static var stories: [StoryGroup] {
        [
            StoryGroup(
                id: 1,
                title: "Story 1: Classroom & Drawing Time",
                description: "Help Rhodey and Jojo feel safe, calm, and ready to participate in drawing activities.",
                chapters: [
                    loadChapter(storyNumber: 1, chapterNumber: 1, fileName: "story1_chapter1", isUnlocked: true),
                    loadChapter(storyNumber: 1, chapterNumber: 2, fileName: "story1_chapter2", isUnlocked: true),
                    loadChapter(storyNumber: 1, chapterNumber: 3, fileName: "story1_chapter3", isUnlocked: true)
                ]
            ),
            StoryGroup(
                id: 2,
                title: "Story 2: Playground Conflicts",
                description: "Guide Rhodey and Jojo through playground interactions, shared toys, and resolving hurt feelings.",
                chapters: [
                    loadChapter(storyNumber: 2, chapterNumber: 1, fileName: "story2_chapter1", isUnlocked: true),
                    loadChapter(storyNumber: 2, chapterNumber: 2, fileName: "story2_chapter2", isUnlocked: true),
                    loadChapter(storyNumber: 2, chapterNumber: 3, fileName: "story2_chapter3", isUnlocked: true)
                ]
            )
        ]
    }

    private static func loadChapter(storyNumber: Int, chapterNumber: Int, fileName: String, isUnlocked: Bool) -> StoryChapterItem {
        let definition = try? StoryLoader.load(named: fileName)
        return StoryChapterItem(
            id: definition?.id ?? fileName,
            storyNumber: storyNumber,
            chapterNumber: chapterNumber,
            fileName: fileName,
            storyDefinition: definition,
            isUnlocked: isUnlocked
        )
    }
}
