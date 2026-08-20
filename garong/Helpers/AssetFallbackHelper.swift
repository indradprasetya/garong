#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

enum AssetFallbackHelper {
    /// Known asset image set names currently available in Assets.xcassets
    static let knownAssets: Set<String> = [
        "fallback_globe",
        "action_apologize",
        "action_approach",
        "action_ask_quiet",
        "action_asking",
        "action_attention_reset",
        "action_blaming",
        "action_candy",
        "action_crayon",
        "action_give_bandage",
        "action_lecture",
        "action_paper",
        "action_toy",
        "back_button",
        "bubble_respond",
        "classroom_background",
        "gameplay_background",
        "park_background",
        "blue_selector_full",
        "blue_selector_half",
        "green_selector_full",
        "green_selector_half",
        "container",
        "container_drag",
        "container_lock",
        "jojo_angry",
        "jojo_calm",
        "jojo_defensive",
        "jojo_drawing",
        "jojo_frustrated",
        "jojo_happy",
        "jojo_neutral",
        "jojo_questioning",
        "jojo_relieved",
        "jojo_rhodey_handshake",
        "jojo_sad",
        "rhodey_angry",
        "rhodey_bandaged",
        "rhodey_calm",
        "rhodey_crying",
        "rhodey_crying_torn_paper",
        "rhodey_defensive",
        "rhodey_drawing",
        "rhodey_frustrated",
        "rhodey_happy",
        "rhodey_holding_new_paper",
        "rhodey_injured_sitting",
        "rhodey_neutral",
        "rhodey_questioning",
        "rhodey_relieved",
        "rhodey_sad"
    ]

    /// Checks whether an asset is available in the bundle / asset catalog.
    static func hasAsset(named name: String) -> Bool {
        guard !name.isEmpty else { return false }
        if knownAssets.contains(name) {
            return true
        }
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #else
        return false
        #endif
    }

    /// Returns the asset image name for character expressions.
    /// Uses the exact expression asset when present, or generic character assets when absent.
    static func imageName(for assetID: String) -> String {
        let lower = assetID.lowercased()
        if hasAsset(named: lower) {
            return lower
        } else if lower.contains("rhodey") {
            if hasAsset(named: "rhodey_happy") { return "rhodey_happy" }
            if hasAsset(named: "rhodey_calm") { return "rhodey_calm" }
            return "rhodey"
        } else if lower.contains("jojo") {
            if hasAsset(named: "jojo_happy") { return "jojo_happy" }
            if hasAsset(named: "jojo_calm") { return "jojo_calm" }
            return "jojo"
        } else {
            return "fallback_globe"
        }
    }

    /// Returns the asset image name for game actions or items.
    static func actionImageName(for actionID: String) -> String {
        let name = actionID.lowercased()
        guard name.hasPrefix("action_") else { return "fallback_globe" }
        return name == "action_lollipop" ? "action_candy" : name
    }

    /// Returns the background asset image name.
    static func backgroundImageName(for backgroundID: String) -> String {
        let lower = backgroundID.lowercased()
        if (lower.contains("park") || lower.contains("playground")) && hasAsset(named: "park_background") {
            return "park_background"
        }
        if lower.contains("classroom") && hasAsset(named: "classroom_background") {
            return "classroom_background"
        }
        if hasAsset(named: lower) {
            return lower
        }
        return "gameplay_background"
    }

    /// Returns an appropriate SF Symbol fallback for game actions or items.
    static func sfSymbol(for actionID: String) -> String {
        let lower = actionID.lowercased()
        if lower.contains("crayon") || lower.contains("draw") {
            return "pencil.tip.crop.circle"
        } else if lower.contains("toy") || lower.contains("play") {
            return "play.fill"
        } else if lower.contains("approach") || lower.contains("get_nearby") {
            return "figure.walk"
        } else if lower.contains("quiet") || lower.contains("speak") || lower.contains("talk") {
            return "bubble.left.and.bubble.right.fill"
        } else if lower.contains("lecture") || lower.contains("warn") {
            return "exclamationmark.triangle.fill"
        } else if lower.contains("attention") || lower.contains("reset") {
            return "arrow.triangle.2.circlepath"
        } else if lower.contains("bandage") {
            return "cross.case.fill"
        } else if lower.contains("paper") {
            return "doc.fill"
        } else if lower.contains("candy") || lower.contains("lollipop") {
            return "circle.fill"
        } else if lower.contains("apologize") || lower.contains("blaming") || lower.contains("asking") {
            return "person.crop.circle.badge.questionmark"
        } else {
            return "globe"
        }
    }
}
