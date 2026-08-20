import Foundation

/// Presentation-ready prototype content based on the GARONG GDD.
/// Dyan's state engine can replace these values without changing Nimah's navigation views.
enum SampleGameData {
    // Legacy aliases retained for Dyan/Bintang's current engine tests and previews.
    static let teddy = GameObject(name: "Teddy", symbol: "🧸", sfSymbol: "teddybear.fill")
    static let apple = GameObject(name: "Apple", symbol: "🍎", sfSymbol: "apple.logo")
    static let book = GameObject(name: "Book", symbol: "📖", sfSymbol: "book.fill")

    // MARK: - Story 1 Objects

    static let cushion = GameObject(name: "Cushion", symbol: "🛋️", sfSymbol: "square.fill")
    static let stringToy = GameObject(name: "String Toy", symbol: "🧶", sfSymbol: "lasso")
    static let playMat = GameObject(name: "Play Mat", symbol: "🟩", sfSymbol: "rectangle.fill")
    static let sandTimer = GameObject(name: "Sand Timer", symbol: "⏳", sfSymbol: "hourglass")
    static let largePencil = GameObject(name: "Large Pencil", symbol: "✏️", sfSymbol: "pencil")
    static let pictureTape = GameObject(name: "Picture Tape", symbol: "🩹", sfSymbol: "bandage.fill")
    static let feelingCards = GameObject(name: "Feeling Cards", symbol: "🃏", sfSymbol: "rectangle.stack.fill")
    static let redRibbon = GameObject(name: "Red Ribbon", symbol: "🎀", sfSymbol: "gift.fill")
    static let freshPaper = GameObject(name: "Fresh Paper", symbol: "📄", sfSymbol: "doc.fill")

    // MARK: - Story 2 Objects

    static let familiarCloth = GameObject(name: "Familiar Cloth", symbol: "🧣", sfSymbol: "square.grid.3x3.fill")
    static let featherToy = GameObject(name: "Feather Toy", symbol: "🪶", sfSymbol: "leaf.fill")
    static let fabricBall = GameObject(name: "Fabric Ball", symbol: "🟠", sfSymbol: "circle.fill")
    static let turnTimer = GameObject(name: "Turn Timer", symbol: "⏱️", sfSymbol: "timer")
    static let playTunnel = GameObject(name: "Play Tunnel", symbol: "🛝", sfSymbol: "oval.portrait.fill")
    static let visualTimer = GameObject(name: "Visual Timer", symbol: "🕒", sfSymbol: "clock.fill")
    static let nowNextCard = GameObject(name: "Now–Next Card", symbol: "🔁", sfSymbol: "arrow.right.square.fill")
    static let labeledBasket = GameObject(name: "Labeled Basket", symbol: "🧺", sfSymbol: "basket.fill")
    static let toyCamera = GameObject(name: "Toy Camera", symbol: "📷", sfSymbol: "camera.fill")

    // MARK: - Chapters

    static let firstInvitation = Chapter(
        number: 1,
        name: "The First Invitation",
        description: "Approach Mochi gently and introduce the activity without rushing closeness.",
        scenes: scenes(
            "Behind the Box",
            "One Paw Outside"
        ),
        objects: [cushion, stringToy],
        isUnlocked: true
    )

    static let roomGetsLoud = Chapter(
        number: 2,
        name: "The Room Gets Loud",
        description: "Support Mochi and Lala when noise and movement make the activity harder.",
        scenes: scenes(
            "A Sound Behind the Table",
            "Mochi Joins the Noise",
            "Back to the Page"
        ),
        objects: [playMat, sandTimer, largePencil],
        isUnlocked: true
    )

    static let tornPicture = Chapter(
        number: 3,
        name: "The Torn Picture",
        description: "Help Mochi, Lala, and Kiko move through a mistake without blame.",
        scenes: scenes(
            "Rip!",
            "Everyone Is Looking",
            "Mochi Breaks Down",
            "Is Lala Still Angry?"
        ),
        objects: [pictureTape, feelingCards, redRibbon, freshPaper],
        isUnlocked: true
    )

    static let quietHello = Chapter(
        number: 1,
        name: "A Quiet Hello",
        description: "Let Mochi choose the distance while meeting in a new outdoor space.",
        scenes: scenes(
            "Under the Bench",
            "At the Edge of the Shade"
        ),
        objects: [familiarCloth, featherToy],
        isUnlocked: true
    )

    static let oneBallTwoCats = Chapter(
        number: 2,
        name: "One Ball, Two Cats",
        description: "Respond to a toy conflict without forcing both children into the same solution.",
        scenes: scenes(
            "The Grab",
            "Pulling From Both Sides",
            "What Happens Next?"
        ),
        objects: [fabricBall, turnTimer, playTunnel],
        isUnlocked: true
    )

    static let whyStop = Chapter(
        number: 3,
        name: "Why Do We Have to Stop?",
        description: "Help three children move from playtime to the next activity at different speeds.",
        scenes: scenes(
            "Five More Minutes",
            "But It Isn’t Finished!",
            "The Track Comes Apart",
            "Can We Build It Again?"
        ),
        objects: [visualTimer, nowNextCard, labeledBasket, toyCamera],
        isUnlocked: true
    )

    static let stories: [GameStory] = [
        GameStory(
            id: "first-lesson",
            number: 1,
            title: "Mochi’s First Lesson",
            subtitle: "Learning to stay connected",
            synopsis: "Meet Mochi, navigate a noisy activity, and help repair a difficult moment with friends.",
            symbol: "book.pages.fill",
            chapters: [firstInvitation, roomGetsLoud, tornPicture],
            isUnlocked: true
        ),
        GameStory(
            id: "friend-for-mochi",
            number: 2,
            title: "A Friend for Mochi",
            subtitle: "Space, boundaries, and transitions",
            synopsis: "Build trust outdoors, respond to a toy conflict, and support the end of playtime.",
            symbol: "figure.2.and.child.holdinghands",
            chapters: [quietHello, oneBallTwoCats, whyStop],
            isUnlocked: true
        )
    ]

    /// Compatibility for existing gameplay previews and tests.
    static let chapters = stories.flatMap(\.chapters)

    private static func scenes(_ names: String...) -> [GameScene] {
        names.enumerated().map { index, name in
            GameScene(
                name: "Frame \(index + 1)",
                description: name
            )
        }
    }
}
