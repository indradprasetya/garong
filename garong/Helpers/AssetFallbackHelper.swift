//
//  AssetFallbackHelper.swift
//  garong
//

import SwiftUI

enum AssetFallbackHelper {
    /// Returns the asset image name for character expressions.
    /// Uses the available generic character assets when an expression-specific asset is absent.
    static func imageName(for assetID: String) -> String {
        let lower = assetID.lowercased()
        if lower.contains("rhodey") {
            return "rhodey"
        } else if lower.contains("jojo") {
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
        } else {
            return "globe"
        }
    }
}
