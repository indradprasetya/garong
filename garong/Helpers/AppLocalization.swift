import SwiftUI
import Combine

struct AppLocalizationCatalog {
    private let strings: [String: LocalizedStoryText]

    init(data: Data) throws {
        strings = try JSONDecoder().decode([String: LocalizedStoryText].self, from: data)
    }

    func text(for key: String, language: String) -> String {
        strings[key]?.localized(language: language) ?? key
    }
}

enum AppLanguage: String {
    case english = "en"
    case indonesian = "id"
}

final class AppLocalization: ObservableObject {
    static let shared = AppLocalization()
    static let languageStorageKey = "appLanguage"

    @Published private(set) var language: AppLanguage

    private let defaults: UserDefaults
    private let catalog: AppLocalizationCatalog?

    private init(defaults: UserDefaults = .standard, bundle: Bundle = .main) {
        self.defaults = defaults
        language = AppLanguage(rawValue: defaults.string(forKey: Self.languageStorageKey) ?? "") ?? .english

        if let url = bundle.url(forResource: "localization", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            catalog = try? AppLocalizationCatalog(data: data)
        } else {
            catalog = nil
        }
    }

    var languageCode: String { language.rawValue }

    func text(_ key: String) -> String {
        text(key, language: languageCode)
    }

    func text(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), arguments: arguments)
    }

    func text(_ key: String, language: String) -> String {
        catalog?.text(for: key, language: language) ?? key
    }

    func text(_ key: String, language: String, _ arguments: CVarArg...) -> String {
        String(format: text(key, language: language), arguments: arguments)
    }

    func localized(_ text: LocalizedStoryText) -> String {
        text.localized(language: languageCode)
    }

    func toggleLanguage() {
        language = language == .english ? .indonesian : .english
        defaults.set(language.rawValue, forKey: Self.languageStorageKey)
    }
}
