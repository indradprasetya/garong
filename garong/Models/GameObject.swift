//
//  GameObject.swift
//  garong
//

import Foundation
import UniformTypeIdentifiers
import CoreTransferable

/// Represents a draggable object that the player can place into scenes.
///
/// Marked `nonisolated` to satisfy Transferable's Sendable requirement
/// while the project uses MainActor default isolation.
nonisolated
struct GameObject: Identifiable, Equatable, Hashable, Codable, Sendable {
    let id: UUID
    let name: String      // e.g. "Teddy"
    let symbol: String    // e.g. "🧸" (placeholder emoji)
    let sfSymbol: String  // e.g. "teddybear.fill" (SF Symbol fallback)
    
    init(id: UUID = UUID(), name: String, symbol: String, sfSymbol: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.sfSymbol = sfSymbol
    }
}

// MARK: - Transferable for Drag-and-Drop

extension GameObject: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .gameObject)
    }
}

extension UTType {
    static let gameObject = UTType(exportedAs: "com.alfathoshi.garong.gameobject")
}
