import Foundation

@main
struct AppLocalizationTests {
    static func main() throws {
        let resourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources/localization.json")
        let catalog = try AppLocalizationCatalog(data: Data(contentsOf: resourceURL))

        precondition(catalog.text(for: "settings.title", language: "en") == "SETTINGS")
        precondition(catalog.text(for: "settings.title", language: "id") == "PENGATURAN")
        precondition(catalog.text(for: "missing.key", language: "id") == "missing.key")

        let naturalIndonesianCopy = [
            "settings.english": "INGGRIS",
            "settings.resetProgress": "atur ulang progres",
            "guidebook.item1.title": "Tenangkan, lalu arahkan",
            "guidebook.item2.title": "Kenali perasaan agar lebih tenang",
            "guidebook.item3.title": "Ajak berpikir, jangan memperkeruh emosi",
            "guidebook.item4.title": "Tetap terhubung saat berkonflik",
            "gameplay.scenesFilled": "%d / %d adegan selesai",
            "selection.current": "%@, siap dimainkan",
            "chapter.enter": "Mulai Bermain",
            "scene.grid": "Tahap %d"
        ]
        for (key, expected) in naturalIndonesianCopy {
            precondition(
                catalog.text(for: key, language: "id") == expected,
                "\(key) must use natural Indonesian copy"
            )
        }

        print("AppLocalizationTests passed")
    }
}
