//
//  LoadingView.swift
//  garong
//
//  Created by Muhammad Bintang Al-Fath on 20/08/26.
//

import SwiftUI
import Combine

struct LoadingView: View {
    /// Character name prefix for the ID card ("rhodey", "jojo", etc.). Defaults to "rhodey".
    var characterName: String = "rhodey"
    /// Duration of the simulated loading sequence in seconds
    var duration: Double = 2.5
    /// Optional completion handler called when loading completes
    var onComplete: (() -> Void)? = nil

    @State private var progress: CGFloat = 0.0
    @State private var useFrame1: Bool = true
    @State private var timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    init(
        characterName: String = "rhodey",
        duration: Double = 2.5,
        onComplete: (() -> Void)? = nil
    ) {
        self.characterName = characterName
        self.duration = duration
        self.onComplete = onComplete
    }

    init(
        chapter: Chapter?,
        duration: Double = 2.5,
        onComplete: (() -> Void)? = nil
    ) {
        self.characterName = chapter?.primaryCharacterName ?? "rhodey"
        self.duration = duration
        self.onComplete = onComplete
    }

    init(
        storyReference: StoryChapterReference?,
        duration: Double = 2.5,
        onComplete: (() -> Void)? = nil
    ) {
        self.characterName = storyReference?.primaryCharacterName ?? "rhodey"
        self.duration = duration
        self.onComplete = onComplete
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Background
                Image("gameplay_background")
                    .resizable()
                    .scaledToFill()

                VStack(spacing: 24) {
                    // ID Card Character Animation (Alternating frames)
                    ZStack {
                        Image(useFrame1 ? "\(characterName)_id_card_frame1" : "\(characterName)_id_card_frame2")
                            .resizable()
                            .scaledToFit()
                            .animation(.easeInOut(duration: 0.01), value: useFrame1)
                        
                        VStack {
                            HStack {
                                Image(.loadingStar1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Image(.loadingStar2)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                        }
                    }
                    .frame(width: 565)

                    // Loading Progress Bar (loading_full overlaying loading_empty)
                    ZStack(alignment: .leading) {
                        
                        GeometryReader { barGeo in
                            Image("loading_full")
                                .resizable()
                                .scaledToFit()
                                .mask(
                                    HStack(spacing: 0) {
                                        Rectangle()
                                            .frame(width: barGeo.size.width * progress)
                                        Spacer(minLength: 0)
                                    }
                                )
                        }
                        
                        Image("loading_empty")
                            .resizable()
                            .scaledToFit()

                        
                    }
                    .frame(maxWidth: 640, maxHeight: 40)
                }
                .padding(24)
            }
            .frame(width: width)
        }
        .ignoresSafeArea()
        .onAppear {
            startLoading()
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                useFrame1.toggle()
            }
        }
    }

    private func startLoading() {
        progress = 0.0
        withAnimation(.easeInOut(duration: duration)) {
            progress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            onComplete?()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
