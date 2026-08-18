import Foundation

@main
struct AssetFallbackHelperTests {
    static func main() {
        let actions = [
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
            "action_toy"
        ]

        precondition(actions.allSatisfy { AssetFallbackHelper.actionImageName(for: $0) == $0 })
        precondition(AssetFallbackHelper.actionImageName(for: "action_lollipop") == "action_candy")
        precondition(AssetFallbackHelper.imageName(for: "jojo_happy") == "jojo")
        precondition(AssetFallbackHelper.imageName(for: "rhodey_calm") == "rhodey")
        precondition(AssetFallbackHelper.imageName(for: "unknown") == "fallback_globe")

        print("AssetFallbackHelperTests passed")
    }
}
