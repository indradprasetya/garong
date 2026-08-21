import Foundation

@main
struct AppLocalizationTests {
    static func main() throws {
        let resourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources/localization.json")
        let catalog = try AppLocalizationCatalog(data: Data(contentsOf: resourceURL))

        precondition(catalog.text(for: "settings.title", language: "en") == "SETTING")
        precondition(catalog.text(for: "settings.title", language: "id") == "PENGATURAN")
        precondition(catalog.text(for: "missing.key", language: "id") == "missing.key")

        print("AppLocalizationTests passed")
    }
}
