//
//  AppTextSize.swift
//  garong
//

import SwiftUI
import Combine

enum AppTextSize: String, CaseIterable, Identifiable {
    case standard = "standard"
    case large = "large"

    var id: String { rawValue }

    var scale: CGFloat {
        switch self {
        case .standard:
            return 1.0
        case .large:
            return 1.2
        }
    }
}

final class AppTextSizeManager: ObservableObject {
    static let shared = AppTextSizeManager()
    static let storageKey = "appTextSize"

    @Published private(set) var textSize: AppTextSize

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.string(forKey: Self.storageKey) ?? AppTextSize.standard.rawValue
        self.textSize = AppTextSize(rawValue: saved) ?? .standard
    }

    func setTextSize(_ size: AppTextSize) {
        guard textSize != size else { return }
        textSize = size
        defaults.set(size.rawValue, forKey: Self.storageKey)
    }

    func toggleTextSize() {
        let next: AppTextSize = (textSize == .standard) ? .large : .standard
        setTextSize(next)
    }
}
