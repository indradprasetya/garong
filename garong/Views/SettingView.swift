import SwiftUI

struct SettingView: View {
    var onClose: (() -> Void)? = nil
    var onResetProgress: (() -> Void)? = nil

    @ObservedObject private var localization = AppLocalization.shared
    @State private var sfxVolume: Float = SoundManager.shared.volume
    @State private var bgmVolume: Float = BackgroundMusicManager.shared.volume
    @State private var sfxPreviewThrottle = SFXPreviewThrottle(minimumInterval: 0.15)
    @State private var showResetConfirmation: Bool = false
    @State private var showResetSuccess: Bool = false

    var body: some View {
        ZStack {
            // Dark dimming backdrop
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose?()
                }

            // Main Modal Card (Stamp Frame)
            ZStack(alignment: .topTrailing) {
                // Stamp Background Image
                Image("bg_setting")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 520)

                VStack(spacing: 8) {
                    // Title
                    Text(localization.text("settings.title"))
                        .font(.appFont(size: 50))
                        .foregroundStyle(.red)
                        .padding(.top, 30)
                        .bold()

                    // Blue Settings Panel
                    ZStack {
                        Image("placeholder_setting")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350)

                        VStack(spacing: 18) {
                            // SFX Volume Row
                            HStack {
                                Text(localization.text("settings.sfxVolume"))
                                    .font(.appFont(size: 16))
                                    .foregroundStyle(.white)

                                Spacer()

                                CustomVolumeSlider(
                                    value: $sfxVolume,
                                    trackImage: "sfx_volume_box",
                                    valueImage: "sfx_volume_value",
                                    onEditingChanged: { isEditing in
                                        if isEditing {
                                            BackgroundMusicManager.shared.duckForSFXPreview()
                                        } else {
                                            BackgroundMusicManager.shared.restoreAfterSFXPreview()
                                        }
                                    }
                                )
                            }

                            // BGM Volume Row
                            HStack {
                                Text(localization.text("settings.bgm"))
                                    .font(.appFont(size: 16))
                                    .foregroundStyle(.white)

                                Spacer()

                                CustomVolumeSlider(
                                    value: $bgmVolume,
                                    trackImage: "bgm_volume_box",
                                    valueImage: "bgm_volume_value"
                                )
                            }

                            // Language Row
                            HStack {
                                Text(localization.text("settings.language"))
                                    .font(.appFont(size: 16))
                                    .foregroundStyle(.white)

                                Spacer()

                                Button {
                                    SoundManager.shared.play(.buttonTap)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        localization.toggleLanguage()
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        // Left Arrow (◄)
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(Color(red: 1.0, green: 0.65, blue: 0.0))
                                            .rotationEffect(.degrees(180))

                                        // Centered Language Option Text
                                        Text(localization.text(
                                            localization.language == .english
                                                ? "settings.english"
                                                : "settings.indonesian"
                                        ))
                                            .font(.appFont(size: 13))
                                            .foregroundStyle(Color(red: 1.0, green: 0.65, blue: 0.0))
                                            .frame(minWidth: 135, alignment: .center)

                                        // Right Arrow (▶)
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(Color(red: 1.0, green: 0.65, blue: 0.0))
                                    }
                                }
                                .buttonStyle(.plain)
                            }

                            

                            // Reset Progress Button
                            HStack {
                                Spacer()

                                Button {
                                    showResetConfirmation = true
                                } label: {
                                    Text(localization.text("settings.resetProgress"))
                                        .font(.appFont(size: 16))
                                        .foregroundStyle(Color(red: 1.0, green: 0.55, blue: 0.65))
                                        .underline()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 52)
                        .padding(.vertical, 56)
                        .frame(width: 400)
                    }
                    .frame(maxWidth: 440)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 36)

                // Close Button Top-Right
                Button {
                    onClose?()
                } label: {
                    Image("close_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
            }
            .padding(24)
        }
        .onChange(of: sfxVolume) { newValue in
            SoundManager.shared.volume = newValue
            if sfxPreviewThrottle.shouldPlay(at: ProcessInfo.processInfo.systemUptime) {
                SoundManager.shared.play(named: SoundManager.SoundEffect.itemPickup.rawValue)
            }
        }
        .onChange(of: bgmVolume) { newValue in
            BackgroundMusicManager.shared.volume = newValue
        }
        .onDisappear {
            BackgroundMusicManager.shared.restoreAfterSFXPreview()
        }
        .alert(localization.text("settings.resetTitle"), isPresented: $showResetConfirmation) {
            Button(localization.text("settings.cancel"), role: .cancel) {}
            Button(localization.text("settings.reset"), role: .destructive) {
                StoryProgressStore().resetAll()
                onResetProgress?()
                DispatchQueue.main.async {
                    showResetSuccess = true
                }
            }
        } message: {
            Text(localization.text("settings.resetMessage"))
        }
        .alert(localization.text("settings.resetSuccessTitle"), isPresented: $showResetSuccess) {
            Button(localization.text("settings.ok"), role: .cancel) {}
        } message: {
            Text(localization.text("settings.resetSuccessMessage"))
        }
    }
}

// MARK: - Custom Interactive Volume Slider
private struct CustomVolumeSlider: View {
    @Binding var value: Float
    let trackImage: String
    let valueImage: String
    let thumbImage: String = "volume_slider"
    var onEditingChanged: (Bool) -> Void = { _ in }

    @State private var isEditing = false
    @State private var hapticTracker = SliderHapticStepTracker(stepCount: 20)

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let clampedValue = max(0.0, min(1.0, CGFloat(value)))

            ZStack(alignment: .leading) {
                // 1. Slider Track Background (e.g. sfx_volume_box / bgm_volume_box)
               

                // 2. Filled Volume Progress Bar (sfx_volume_value / bgm_volume_value)
                Image(valueImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: width * clampedValue)
                            Spacer(minLength: 0)
                        }
                    )
                
                Image(trackImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)

                // 3. Red Slider Thumb (volume_slider handle)
                let thumbWidth: CGFloat = max(height * 0.8, 16)
                let maxThumbOffset = max(0, width - thumbWidth)
                Image(thumbImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: thumbWidth, height: height)
                    .offset(x: clampedValue * maxThumbOffset)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isEditing {
                            isEditing = true
                            hapticTracker.reset()
                            onEditingChanged(true)
                        }

                        let locationX = gesture.location.x
                        let newValue = max(0.0, min(1.0, Float(locationX / width)))
                        value = newValue

                        if hapticTracker.shouldTrigger(for: newValue) {
                            HapticManager.shared.selection()
                        }
                    }
                    .onEnded { _ in
                        guard isEditing else { return }
                        isEditing = false
                        hapticTracker.reset()
                        onEditingChanged(false)
                    }
            )
        }
        .frame(width: 170, height: 26)
    }
}

#Preview {
    SettingView()
}
