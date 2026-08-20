#if canImport(CoreText)
import CoreText
#endif
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

enum AppFont {
    private(set) static var fontName: String = "Virels-Regular"

    /// Dynamically registers custom fonts with CoreText on app startup.
    static func registerFonts() {
        #if canImport(CoreText)
        let fontNames = ["Virels-Regular", "Virels"]
        var candidateURLs: [URL] = []

        for name in fontNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf") {
                candidateURLs.append(url)
            }
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") {
                candidateURLs.append(url)
            }
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Resources/Fonts") {
                candidateURLs.append(url)
            }
        }

        if let bundleURLs = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) {
            candidateURLs.append(contentsOf: bundleURLs)
        }

        for url in Set(candidateURLs) {
            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            if success {
                print("AppFont: Successfully registered font from \(url.lastPathComponent)")
            } else if let err = error?.takeRetainedValue() {
                print("AppFont: Registration status for \(url.lastPathComponent): \(err)")
            }
        }

        #if canImport(UIKit)
        for family in UIFont.familyNames {
            if family.localizedCaseInsensitiveContains("virels") {
                let names = UIFont.fontNames(forFamilyName: family)
                if let first = names.first {
                    fontName = first
                    print("AppFont: Using registered font '\(first)' in family '\(family)'")
                    return
                }
                fontName = family
                return
            }
        }
        #endif
        #endif
    }

    static func custom(_ size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        Font.custom(fontName, size: size, relativeTo: textStyle)
    }

    static func regular(size: CGFloat) -> Font {
        Font.custom(fontName, size: size)
    }
    
    static func title(size: CGFloat = 28) -> Font {
        Font.custom(fontName, size: size, relativeTo: .title)
    }
    
    static func headline(size: CGFloat = 18) -> Font {
        Font.custom(fontName, size: size, relativeTo: .headline)
    }
    
    static func body(size: CGFloat = 14) -> Font {
        Font.custom(fontName, size: size, relativeTo: .body)
    }
    
    static func caption(size: CGFloat = 11) -> Font {
        Font.custom(fontName, size: size, relativeTo: .caption)
    }
}

extension Font {
    static func appFont(size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        AppFont.custom(size, relativeTo: textStyle)
    }
}
