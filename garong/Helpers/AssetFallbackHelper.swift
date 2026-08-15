//
//  AssetFallbackHelper.swift
//  garong
//

import SwiftUI

enum AssetFallbackHelper {
    /// Returns the asset image name for character expressions.
    /// Uses available catalog assets (`"Rhodey"`, `"Jojo"`, `"Globe"`).
    static func imageName(for assetID: String) -> String {
        let lower = assetID.lowercased()
        if lower.contains("rhodey") {
            return "Rhodey"
        } else if lower.contains("jojo") {
            return "Jojo"
        } else {
            return "Globe"
        }
    }

    /// Returns the asset image name for game actions or items.
    static func actionImageName(for actionID: String) -> String {
        let lower = actionID.lowercased()
        if lower.contains("approach") {
            return "Approach"
        } else if lower.contains("apologize") {
            return "Apologize"
        } else if lower.contains("ask_quiet") {
            return "AskQuiet"
        } else if lower.contains("asking") || lower.contains("ask") {
            return "Asking"
        } else if lower.contains("attention") || lower.contains("reset") {
            return "AttentionReset"
        } else if lower.contains("blam") {
            return "Blaming"
        } else if lower.contains("candy") || lower.contains("lollipop") {
            return "Candy"
        } else if lower.contains("crayon") || lower.contains("draw") {
            return "Crayon"
        } else if lower.contains("bandage") {
            return "GiveBandage"
        } else if lower.contains("lecture") {
            return "Lecture"
        } else if lower.contains("paper") {
            return "Paper"
        } else if lower.contains("toy") {
            return "Toy"
        } else {
            return "Globe"
        }
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

