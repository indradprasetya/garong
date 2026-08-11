//  ChapterResult.swift
//  garong
//

import Foundation

/// Summary data shown on the chapter completion screen.
struct ChapterResult: Equatable {
    let chapterName: String
    let totalObjects: Int
    let placedObjects: Int
    let sceneStates: [SceneResultEntry]
    
    struct SceneResultEntry: Equatable {
        let sceneName: String
        let objectNames: [String]
        let emotionName: String
    }
}
