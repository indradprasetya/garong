//
//  garongApp.swift
//  garong
//
//  Created by Indrayana Dian Prasetya on 11/08/26.
//

import SwiftUI

@main
struct garongApp: App {
    init() {
        AppFont.registerFonts()
        #if DEBUG
        Task { @MainActor in
            DragDropGameTests.runAllTests()
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}
