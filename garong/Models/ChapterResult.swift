//  ChapterResult.swift
//  garong
//

import Foundation

/// Summary data shown on the chapter completion screen.
struct ChapterResult: Equatable {
    let chapterName: String
    let totalObjects: Int
    let placedObjects: Int
    let placementCount: Int
    let stars: Int
    let completionSummary: String?
    let completionTip: String?
    let sceneStates: [SceneResultEntry]
    let characterName: String
    let meterImageName: String
    
    struct SceneResultEntry: Equatable {
        let sceneName: String
        let objectNames: [String]
        let emotionName: String
    }
}
