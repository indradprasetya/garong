//
//  MainMenuView.swift
//  garong
//

import SwiftUI

struct MainMenuView: View {
    private enum Destination: Hashable {
        case game
        case chapters
    }

    @State private var destination: Destination?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(
                                LinearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .shadow(color: .accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("Garong")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.primary, .secondary], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text("A Drag & Drop Sandbox Adventure")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 20) {
                        Button {
                            destination = .game
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Game")
                            }
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(14)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        
                        Button {
                            destination = .chapters
                        } label: {
                            HStack {
                                Image(systemName: "square.grid.2x2.fill")
                                Text("Chapters")
                            }
                            .font(.title3.bold())
                            .foregroundColor(.accentColor)
                            .frame(width: 200, height: 50)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            }
            .navigationDestination(item: $destination) { destination in
                switch destination {
                case .game:
                    if let firstChapter = SampleGameData.chapters.first {
                        GameplayView(chapter: firstChapter)
                    } else {
                        Text("No chapters available")
                    }
                case .chapters:
                    ChapterSelectionView()
                }
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
