//
//  GuidebookData.swift
//  garong
//

import Foundation

struct GuidebookItem: Identifiable {
    let id: Int
    let titleKey: String
    let leftChar: String?
    let rightChar: String
    let paragraph1Key: String
    let paragraph2Key: String?
    let isBookReference: Bool

    init(
        id: Int,
        titleKey: String = "",
        leftChar: String? = nil,
        rightChar: String = "",
        paragraph1Key: String,
        paragraph2Key: String? = nil,
        isBookReference: Bool = false
    ) {
        self.id = id
        self.titleKey = titleKey
        self.leftChar = leftChar
        self.rightChar = rightChar
        self.paragraph1Key = paragraph1Key
        self.paragraph2Key = paragraph2Key
        self.isBookReference = isBookReference
    }
}

enum GuidebookData {
    static let items: [GuidebookItem] = [
        GuidebookItem(
            id: 1,
            titleKey: "guidebook.item1.title",
            leftChar: "rhodey_crying",
            rightChar: "rhodey_calm",
            paragraph1Key: "guidebook.item1.paragraph1",
        ),
        GuidebookItem(
            id: 2,
            titleKey: "guidebook.item2.title",
            leftChar: "jojo_sad",
            rightChar: "jojo_calm",
            paragraph1Key: "guidebook.item2.paragraph1"
        ),
        GuidebookItem(
            id: 3,
            titleKey: "guidebook.item3.title",
            leftChar: "rhodey_injured_sitting",
            rightChar: "rhodey_bandaged",
            paragraph1Key: "guidebook.item3.paragraph1"
        ),
        GuidebookItem(
            id: 4,
            titleKey: "guidebook.item4.title",
            leftChar: nil,
            rightChar: "jojo_rhodey_handshake",
            paragraph1Key: "guidebook.item4.paragraph1"
        ),
        GuidebookItem(
            id: 5,
            paragraph1Key: "guidebook.item5.paragraph1",
            isBookReference: true
        )
    ]
}
