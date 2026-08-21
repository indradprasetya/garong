//
//  GuidebookData.swift
//  garong
//

import Foundation

struct GuidebookItem: Identifiable {
    let id: Int
    let title: String
    let leftChar: String?
    let rightChar: String
    let paragraph1: String
    let paragraph2: String?
    let isBookReference: Bool

    init(
        id: Int,
        title: String = "",
        leftChar: String? = nil,
        rightChar: String = "",
        paragraph1: String,
        paragraph2: String? = nil,
        isBookReference: Bool = false
    ) {
        self.id = id
        self.title = title
        self.leftChar = leftChar
        self.rightChar = rightChar
        self.paragraph1 = paragraph1
        self.paragraph2 = paragraph2
        self.isBookReference = isBookReference
    }
}

enum GuidebookData {
    static let items: [GuidebookItem] = [
        GuidebookItem(
            id: 1,
            title: "#1 Connect and redirect",
            leftChar: "rhodey_crying",
            rightChar: "rhodey_calm",
            paragraph1: "When a child is upset, meet them emotionally first through touch and reflecting back what you're hearing.",
            paragraph2: "Once they've calmed down, you can shift to logic, problem-solving."
        ),
        GuidebookItem(
            id: 2,
            title: "#2 Name it to Tame it",
            leftChar: "jojo_sad",
            rightChar: "jojo_calm",
            paragraph1: "When emotions are overwhelming, help the child narrate what happened. Putting the experience into words engages the left brain and helps them regain a sense of control.",
            paragraph2: nil
        ),
        GuidebookItem(
            id: 3,
            title: "#3 Engage, dont Enrage",
            leftChar: "rhodey_injured_sitting",
            rightChar: "rhodey_bandaged",
            paragraph1: "In tense moments, invite the child to think and choose rather than just react. Reframe commands as questions that involve their reasoning, then praise them for coming up with alternatives.",
            paragraph2: nil
        ),
        GuidebookItem(
            id: 4,
            title: "#4 Connect through Conflict",
            leftChar: nil,
            rightChar: "jojo_rhodey_handshake",
            paragraph1: "Treat conflict (with siblings, peers, or you) as a teaching opportunity rather than something to avoid. Giving/asking forgiveness help them understand what respectful relationships look like even during disagreements.",
            paragraph2: nil
        ),
        GuidebookItem(
            id: 5,
            title: "",
            paragraph1: "Read more in ‘The Whole-Brain Child’ book by Daniel J. Siegel, M.D. and Tina Payne Bryson, Ph.D.",
            isBookReference: true
        )
    ]
}
