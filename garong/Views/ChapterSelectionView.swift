//
//  ChapterSelectionView.swift
//  garong
//

import SwiftUI

struct ChapterSelectionView: View {
    let stories = StoryCatalog.stories
    @State private var bestStars: [String: Int] = [:]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    ForEach(stories) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(group.title)
                                    .font(.appFont(size: 22, relativeTo: .title2))
                                    .foregroundColor(.primary)
                                
                                Text(group.description)
                                    .font(.appFont(size: 15, relativeTo: .subheadline))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 32)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(group.chapters) { item in
                                        let chapter = Chapter(storyItem: item)
                                        if item.isUnlocked {
                                            NavigationLink(destination: GameplayView(chapter: chapter)) {
                                                chapterCard(for: item)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded {
                                                SoundManager.shared.play(.buttonTap)
                                            })
                                        } else {
                                            chapterCard(for: item)
                                                .opacity(0.6)
                                        }
                                    }
                                }
                                .padding(.horizontal, 32)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Story Chapters")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let store = StoryProgressStore()
            bestStars = Dictionary(uniqueKeysWithValues: stories.flatMap(\.chapters).compactMap { chapter in
                guard let stars = try? store.state(for: chapter.id).completion?.bestStars else { return nil }
                return (chapter.id, stars)
            })
        }
    }
    
    @ViewBuilder
    private func chapterCard(for item: StoryChapterItem) -> some View {
        let charId = item.storyDefinition?.characters.first?.id ?? ""
        let imageName = AssetFallbackHelper.imageName(for: charId)
        
        ZStack(alignment: .bottomLeading) {
            // Card Image Background
            if !imageName.isEmpty && AssetFallbackHelper.hasAsset(named: imageName) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 240, height: 160)
                    .opacity(0.5)
                    .clipped()
            } else {
                Color(UIColor.secondarySystemGroupedBackground)
                    .overlay(
                        Image(systemName: "globe")
                            .font(.system(size: 44))
                            .foregroundColor(.accentColor.opacity(0.4))
                    )
            }
            
            // Gradient Overlay for High Contrast Legibility
            LinearGradient(
                colors: [Color.black.opacity(0.75), Color.black.opacity(0.0)],
                startPoint: .bottom,
                endPoint: .center
            )
            
            // Card Content (Chapter Title & Number - description removed)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Chapter \(item.chapterNumber)")
                        .font(.appFont(size: 12, relativeTo: .caption))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.accentColor))
                    
                    Spacer()
                    
                    if !item.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    } else if let stars = bestStars[item.id] {
                        HStack(spacing: 2) {
                            ForEach(1...3, id: \.self) { star in
                                Image(systemName: star <= stars ? "star.fill" : "star")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.yellow)
                    }
                }
                
                Text(item.title)
                    .font(.appFont(size: 16, relativeTo: .headline))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: Color.black.opacity(0.6), radius: 2, x: 0, y: 1)
                
            }
            .padding(14)
        }
        .frame(width: 240, height: 160)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.separator).opacity(0.6), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

struct ChapterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChapterSelectionView()
        }
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
