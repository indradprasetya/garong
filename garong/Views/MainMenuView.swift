//
//  MainMenuView.swift
//  garong
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        let heroImage = AssetFallbackHelper.imageName(for: "rhodey")
                        if AssetFallbackHelper.hasAsset(named: heroImage) {
                            Image(heroImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .shadow(color: .accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        } else {
                            Image(systemName: "hand.raised.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .foregroundStyle(
                                    LinearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: .accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Text("Garong")
                            .font(.appFont(size: 48, relativeTo: .largeTitle))
                            .foregroundStyle(
                                LinearGradient(colors: [.primary, .secondary], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text("A Drag & Drop Sandbox Adventure")
                            .font(.appFont(size: 18, relativeTo: .title3))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 20) {
                        NavigationLink {
                            if let firstItem = StoryCatalog.stories.first?.chapters.first {
                                GameplayView(chapter: Chapter(storyItem: firstItem))
                            } else {
                                Text("No chapters available")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Game")
                            }
                            .font(.appFont(size: 18, relativeTo: .headline))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(14)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        
                        NavigationLink {
                            ChapterSelectionView()
                        } label: {
                            HStack {
                                Image(systemName: "square.grid.2x2.fill")
                                Text("Chapters")
                            }
                            .font(.appFont(size: 18, relativeTo: .headline))
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
        }
        .navigationViewStyle(.stack)
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
