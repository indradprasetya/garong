import Foundation

@main
struct AppTextSizeTests {
    static func main() throws {
        // Test scale factors
        precondition(AppTextSize.standard.scale == 1.0, "Standard text size must have 1.0 scale")
        precondition(AppTextSize.large.scale == 1.2, "Large text size must have 1.2 scale")

        // Test manager with isolated UserDefaults
        let testDefaults = UserDefaults(suiteName: "AppTextSizeTestsSuite")!
        testDefaults.removePersistentDomain(forName: "AppTextSizeTestsSuite")

        let manager = AppTextSizeManager(defaults: testDefaults)
        precondition(manager.textSize == .standard, "Default text size must be standard")

        manager.setTextSize(.large)
        precondition(manager.textSize == .large, "Text size should be large after setTextSize(.large)")
        precondition(testDefaults.string(forKey: AppTextSizeManager.storageKey) == "large", "UserDefaults should store 'large'")

        manager.toggleTextSize()
        precondition(manager.textSize == .standard, "Text size should toggle back to standard")
        precondition(testDefaults.string(forKey: AppTextSizeManager.storageKey) == "standard", "UserDefaults should store 'standard'")

        manager.toggleTextSize()
        precondition(manager.textSize == .large, "Text size should toggle back to large")

        // Test localization keys for text size
        let resourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources/localization.json")
        let catalog = try AppLocalizationCatalog(data: Data(contentsOf: resourceURL))

        precondition(catalog.text(for: "settings.textSize", language: "en") == "TEXT SIZE")
        precondition(catalog.text(for: "settings.textSize", language: "id") == "UKURAN TEKS")
        precondition(catalog.text(for: "settings.textStandard", language: "en") == "STANDARD")
        precondition(catalog.text(for: "settings.textStandard", language: "id") == "STANDAR")
        precondition(catalog.text(for: "settings.textLarge", language: "en") == "LARGE")
        precondition(catalog.text(for: "settings.textLarge", language: "id") == "BESAR")

        testDefaults.removePersistentDomain(forName: "AppTextSizeTestsSuite")
        print("AppTextSizeTests passed successfully")
    }
}
