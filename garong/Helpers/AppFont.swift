#if canImport(CoreText)
import CoreText
#endif
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

enum AppFont {
    private(set) static var fontName: String = "Virels-Regular"
    private(set) static var boldFontName: String = "Virels-Bold"

    /// Dynamically registers custom fonts with CoreText on app startup.
    static func registerFonts() {
        #if canImport(CoreText)
        let fontNames = ["Virels-Regular", "Virels-Bold", "Virels"]
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
        if UIFont(name: fontName, size: 12) != nil {
            print("AppFont: Using registered font '\(fontName)'")
        }
        if UIFont(name: boldFontName, size: 12) != nil {
            print("AppFont: Using registered bold font '\(boldFontName)'")
        }
        #endif
        #endif
    }

    private static var scaleFactor: CGFloat {
        AppTextSizeManager.shared.textSize.scale
    }

    static func custom(_ size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        Font.custom(fontName, size: size * scaleFactor, relativeTo: textStyle)
    }

    static func regular(size: CGFloat) -> Font {
        Font.custom(fontName, size: size * scaleFactor)
    }

    static func bold(size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        Font.custom(boldFontName, size: size * scaleFactor, relativeTo: textStyle)
    }
    
    static func title(size: CGFloat = 28) -> Font {
        Font.custom(fontName, size: size * scaleFactor, relativeTo: .title)
    }
    
    static func headline(size: CGFloat = 18) -> Font {
        Font.custom(fontName, size: size * scaleFactor, relativeTo: .headline)
    }
    
    static func body(size: CGFloat = 14) -> Font {
        Font.custom(fontName, size: size * scaleFactor, relativeTo: .body)
    }
    
    static func caption(size: CGFloat = 11) -> Font {
        Font.custom(fontName, size: size * scaleFactor, relativeTo: .caption)
    }
}

extension Font {
    static func appFont(size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        AppFont.custom(size, relativeTo: textStyle)
    }

    static func appFontBold(size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        AppFont.bold(size: size, relativeTo: textStyle)
    }
}
