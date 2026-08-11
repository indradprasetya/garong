//
//  ChapterSelectionView.swift
//  garong
//

import SwiftUI

struct ChapterSelectionView: View {
    let chapters = SampleGameData.chapters
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Chapters")
                    .font(.largeTitle.bold())
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(chapters, id: \.id) { chapter in
                            if chapter.isUnlocked {
                                NavigationLink(destination: GameplayView(chapter: chapter)) {
                                    chapterCard(for: chapter)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                chapterCard(for: chapter)
                                    .opacity(0.6)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Chapters")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func chapterCard(for chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Chapter \(chapter.number)")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Spacer()
                if !chapter.isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Text(chapter.name)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer()
            
            Text("\(chapter.scenes.count) Scenes")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 240, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
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
